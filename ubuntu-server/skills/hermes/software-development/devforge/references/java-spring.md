# Java + Spring Boot a fondo

Línea base medida en esta máquina el **2026-07-22**: Java **25.0.3**, Maven **3.9.16**, Spring Boot **4.1.0**. Re-verifica con `mvnlatest` antes de escribir un pom nuevo.

---

## Proyecto nuevo

```bash
cd ~/java-projects
BOOT=$(~/.local/share/hermes/tools/mvnlatest org.springframework.boot:spring-boot-starter-parent | cut -f2)
echo "Spring Boot resuelto: $BOOT"

curl -s https://start.spring.io/starter.zip \
  -d type=maven-project -d language=java \
  -d bootVersion=$BOOT -d javaVersion=25 \
  -d groupId=com.sahacloud -d artifactId=mi-api \
  -d dependencies=web,data-jpa,postgresql,validation,actuator,flyway,testcontainers \
  -o mi-api.zip && unzip -q mi-api.zip -d mi-api && rm mi-api.zip
```

`start.spring.io` solo acepta versiones que existen — si la rechaza, la versión estaba mal.

Después: `git init`, `CLAUDE.md`, y `./mvnw -q clean verify` para confirmar que el esqueleto compila **antes** de escribir lógica.

---

## Java 25 — lo que sí conviene usar

```java
// records para DTOs y value objects
public record CrearPedido(@NotBlank String clienteId, @Positive BigDecimal total) {}

// sealed + pattern matching para estados cerrados
public sealed interface ResultadoPago permits Aprobado, Rechazado, Pendiente {}

String mensaje = switch (resultado) {
    case Aprobado a  -> "OK " + a.referencia();
    case Rechazado r -> "Rechazado: " + r.motivo();
    case Pendiente p -> "Esperando";
};   // sin default: el compilador exige cubrir todos los casos

// text blocks para SQL/JSON
var sql = """
    SELECT p.id, p.total FROM pedido p
    WHERE p.estado = ? AND p.creado_en > ?
    """;

// virtual threads: I/O-bound sin tocar el código
// application.yml → spring.threads.virtual.enabled: true
```

**Ojo con virtual threads:** rinden en cargas de I/O. No ayudan en CPU-bound, y `synchronized` bloquea el carrier thread — usa `ReentrantLock` en secciones críticas dentro de tareas virtuales.

**Lombok:** úsalo con moderación. `@Getter`/`@Builder` bien; `@Data` en entidades JPA genera `equals`/`hashCode` sobre todos los campos, incluidas las relaciones lazy — provoca `LazyInitializationException` y bucles infinitos. En entidades escribe `equals`/`hashCode` a mano sobre el id.

---

## JPA — las trampas que sí importan

### N+1: el problema real de rendimiento
```java
// ✗ 1 query + N queries
List<Pedido> pedidos = repo.findAll();
pedidos.forEach(p -> p.getLineas().size());

// ✓ una query
@Query("SELECT DISTINCT p FROM Pedido p LEFT JOIN FETCH p.lineas")
List<Pedido> findAllConLineas();

// ✓ o con entity graph
@EntityGraph(attributePaths = "lineas")
List<Pedido> findByEstado(EstadoPedido estado);
```

Detéctalo antes de que llegue a producción:
```yaml
# application-dev.yml
spring.jpa.properties.hibernate.generate_statistics: true
logging.level.org.hibernate.stat: DEBUG
```

### LazyInitializationException
Ocurre al tocar una relación lazy fuera de la transacción. La solución **no** es `spring.jpa.open-in-view: true` (por defecto está activo y es una mala idea: mantiene la conexión abierta durante todo el render). Desactívalo y trae explícitamente lo que necesites:

```yaml
spring.jpa.open-in-view: false
```

### @Transactional que no funciona
```java
// ✗ auto-invocación: Spring no puede interceptar, no hay transacción
public void a() { this.b(); }
@Transactional public void b() { }

// ✗ métodos privados: idem
@Transactional private void guardar() { }
```
El proxy solo intercepta llamadas **desde fuera** a métodos **públicos**. Si necesitas transacción interna, separa a otro bean.

`@Transactional(readOnly = true)` en consultas: Hibernate se salta el dirty checking. Gratis y notable.

### Nunca `ddl-auto: update` fuera de local
```yaml
spring.jpa.hibernate.ddl-auto: validate   # producción
```
El esquema lo manda Flyway. `update` en producción tarde o temprano borra o altera algo sin avisar.

---

## Flyway

```
src/main/resources/db/migration/
├── V1__crear_pedido.sql
├── V2__indice_pedido_estado.sql
└── V3__anadir_columna_moneda.sql
```

- Las migraciones aplicadas son **inmutables**. Nunca edites una V ya desplegada — Flyway compara checksums y falla. Corrige con una V nueva.
- Todo cambio de esquema pasa por migración. Sin excepciones.
- Índices también son migraciones.

---

## Validación y errores

```java
@PostMapping
ResponseEntity<PedidoResponse> crear(@Valid @RequestBody CrearPedido req) { ... }
```

Manejo global — el dominio lanza sus excepciones, el borde las traduce:

```java
@RestControllerAdvice
class ManejadorErrores {

    @ExceptionHandler(PedidoNoEncontrado.class)
    ProblemDetail noEncontrado(PedidoNoEncontrado e) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ProblemDetail validacion(MethodArgumentNotValidException e) {
        var pd = ProblemDetail.forStatus(HttpStatus.BAD_REQUEST);
        pd.setProperty("errores", e.getBindingResult().getFieldErrors().stream()
            .collect(toMap(FieldError::getField, FieldError::getDefaultMessage, (a, b) -> a)));
        return pd;
    }
}
```

`ProblemDetail` es RFC 7807 y viene en Spring. No inventes tu propio formato de error.

**Nunca** devuelvas el stack trace al cliente: filtra rutas internas y versiones.

---

## Seguridad

```java
@Bean
SecurityFilterChain filtros(HttpSecurity http) throws Exception {
    return http
        .csrf(csrf -> csrf.disable())                       // solo si es API stateless pura
        .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
        .authorizeHttpRequests(a -> a
            .requestMatchers("/actuator/health").permitAll()
            .requestMatchers("/api/admin/**").hasRole("ADMIN")
            .anyRequest().authenticated())
        .oauth2ResourceServer(o -> o.jwt(withDefaults()))
        .build();
}
```

- Contraseñas: `BCryptPasswordEncoder` o Argon2. Nunca MD5/SHA sin salt.
- Secretos por variable de entorno. Nada de credenciales en `application.yml` versionado.
- Actuator: expón solo `health` e `info` públicamente. `/actuator/env` filtra configuración entera.
- Valida en el servidor aunque el cliente ya valide.

---

## Perfiles y configuración

```
application.yml            # común
application-dev.yml
application-prod.yml
```

```yaml
spring:
  datasource:
    url: ${DB_URL:jdbc:postgresql://localhost:5432/midb}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
```

`${VAR:default}` da default solo en local. En producción, si falta la variable, **que falle al arrancar** — mejor que arrancar con un valor silenciosamente incorrecto.

---

## Observabilidad

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

- Health checks reales, con dependencias: `/actuator/health/readiness`.
- Métricas Micrometer → Prometheus.
- Logs estructurados en JSON para producción, con correlation id por petición.
- Nunca loguees contraseñas, tokens ni PII.

---

## Docker

```dockerfile
FROM eclipse-temurin:25-jdk-alpine AS build
WORKDIR /app
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw -B dependency:go-offline      # capa cacheada: no se reconstruye si el pom no cambia
COPY src/ src/
RUN ./mvnw -B clean package -DskipTests

FROM eclipse-temurin:25-jre-alpine
RUN addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
USER app
EXPOSE 8080
ENTRYPOINT ["java","-XX:MaxRAMPercentage=75","-jar","app.jar"]
```

- Multi-stage: la imagen final lleva JRE, no JDK ni fuentes.
- Usuario no-root.
- `MaxRAMPercentage` en vez de `-Xmx` fijo: la JVM respeta el límite del contenedor. Importante en esta VM de 6 GB.
- `dependency:go-offline` antes de copiar `src/` — sin eso cada cambio de código re-descarga todo Maven.

---

## Checklist antes de decir "listo"

```bash
./mvnw -q clean verify
```

- [ ] Compila y los tests pasan (salida real, no supuesta)
- [ ] `ddl-auto: validate`, esquema por Flyway
- [ ] `open-in-view: false`
- [ ] Sin secretos en el repo
- [ ] Errores con `ProblemDetail`, sin stack traces al cliente
- [ ] Actuator restringido
- [ ] Versiones resueltas con `mvnlatest`, no escritas de memoria
- [ ] Dockerfile multi-stage, no-root
