# Tests y depuración

## Principio

Un test que nunca ha fallado no ha demostrado nada. Después de escribirlo, **rompe el código a propósito** y comprueba que el test se pone en rojo. Si sigue verde, el test es decorativo.

---

## Pirámide

```
      /\       E2E — pocos, lentos, frágiles. Solo caminos críticos.
     /  \
    /----\     Integración — BD real, HTTP real. Decenas.
   /      \
  /--------\   Unitarios — dominio puro, milisegundos. Cientos.
```

Invertirla (muchos E2E, pocos unitarios) da suites de 40 minutos que fallan por motivos aleatorios y que el equipo acaba ignorando.

---

## Unitarios — Java

JUnit 5 + AssertJ. Sin Spring, sin BD.

```java
class CalculadoraPrecioTest {

    private final CalculadoraPrecio calculadora = new CalculadoraPrecio();

    @Test
    void aplica_descuento_por_volumen_a_partir_de_10_unidades() {
        var pedido = new Pedido(List.of(new Linea("SKU-1", 10, new BigDecimal("100"))));

        var total = calculadora.calcular(pedido);

        assertThat(total).isEqualByComparingTo("900.00");
    }

    @Test
    void rechaza_cantidad_negativa() {
        assertThatThrownBy(() -> new Linea("SKU-1", -1, BigDecimal.TEN))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("cantidad");
    }
}
```

- Nombre del test = la regla de negocio en una frase. `test1()` no sirve a nadie.
- `isEqualByComparingTo` para `BigDecimal`: `isEqualTo` compara escala y `100.0 != 100.00`.
- Un concepto por test. Si necesitas tres `assert` de cosas distintas, son tres tests.

### Parametrizados
```java
@ParameterizedTest
@CsvSource({ "1, 100.00", "10, 900.00", "100, 8000.00" })
void escalona_descuento(int cantidad, BigDecimal esperado) {
    assertThat(calculadora.calcular(pedidoDe(cantidad))).isEqualByComparingTo(esperado);
}
```

### Mockito — con criterio
Mockea lo que cruza un límite (BD, HTTP, reloj). No mockees value objects ni la clase bajo test.

```java
@ExtendWith(MockitoExtension.class)
class CrearPedidoServiceTest {

    @Mock PedidoRepository repo;
    @Mock PasarelaPago pasarela;
    @InjectMocks CrearPedidoService service;

    @Test
    void no_guarda_el_pedido_si_el_pago_es_rechazado() {
        when(pasarela.cobrar(any())).thenReturn(new Rechazado("fondos"));

        assertThatThrownBy(() -> service.crear(comando()))
            .isInstanceOf(PagoRechazado.class);

        verify(repo, never()).guardar(any());
    }
}
```

Un test lleno de mocks encadenados suele indicar que el diseño tiene demasiado acoplamiento. El dolor del test es información sobre el código.

---

## Integración — Testcontainers, no H2

H2 miente: distinto dialecto, distintas funciones, distinto comportamiento de índices. Un test verde en H2 y roto en Postgres es tiempo perdido dos veces.

```java
@SpringBootTest
@Testcontainers
@AutoConfigureMockMvc
class PedidoIntegracionTest {

    @Container
    @ServiceConnection                                // Boot cablea el datasource solo
    static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:17-alpine");

    @Autowired MockMvc mockMvc;

    @Test
    void crea_pedido_y_lo_devuelve_por_id() throws Exception {
        mockMvc.perform(post("/api/pedidos")
                .contentType(APPLICATION_JSON)
                .content("""
                    { "clienteId": "C-1", "total": 150.00 }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.id").exists());
    }
}
```

`@ServiceConnection` (Boot 3.1+) elimina el `@DynamicPropertySource` manual. El contenedor `static` se reutiliza entre tests de la clase.

### Slices — mucho más rápidos que `@SpringBootTest`
```java
@WebMvcTest(PedidoController.class)   // solo la capa web, servicios mockeados
@DataJpaTest                          // solo JPA + BD
@JsonTest                             // solo serialización
```

Usa `@SpringBootTest` solo cuando de verdad necesites el contexto completo. Levantarlo en cada test convierte la suite en algo que nadie ejecuta en local.

---

## Depuración sistemática

Depurar no es cambiar cosas hasta que funcione. Es reducir el espacio de hipótesis.

### 1. Reproducir
Sin repro fiable no hay fix, hay coincidencia. Consigue los pasos exactos, los datos exactos, el entorno exacto. Si solo pasa en producción, esa es la primera pista.

### 2. Leer el error entero
El stack trace suele nombrar el archivo y la línea. La causa real está en el **`Caused by:` más profundo**, no en la primera línea.

```bash
journalctl --user -u hermes-gateway --since '10 min ago' | grep -A 30 'Caused by'
```

### 3. Bisecar
Reduce hasta el mínimo caso que falla. Si el bug apareció entre dos versiones:
```bash
git bisect start
git bisect bad HEAD
git bisect good v1.2.0
# git te da commits; marca cada uno good/bad
```
`git bisect` encuentra el commit culpable en log₂(n) pasos.

### 4. Hipótesis + medición
Formula: "creo que falla porque X". Luego **mide** si X es cierto. Un log, un breakpoint, un `assert`. No cambies código para "ver si eso era".

### 5. Arreglar la causa
Si el `NullPointerException` se arregla con un `if (x != null)`, pregúntate por qué era null. Un guard que tapa el síntoma deja el bug vivo aguas arriba.

### 6. Test de regresión
Todo bug arreglado deja un test que habría fallado antes del fix. Sin eso, vuelve.

---

## Herramientas Java

```bash
jps -l                          # JVMs corriendo
jstack <pid>                    # volcado de hilos: deadlocks, hilos bloqueados
jcmd <pid> GC.heap_info         # estado del heap
jcmd <pid> Thread.print
jmap -histo:live <pid> | head   # qué objetos ocupan memoria
```

Perfilado real: JFR, sin coste apreciable, sirve en producción.
```bash
java -XX:StartFlightRecording=duration=60s,filename=perfil.jfr -jar app.jar
```

SQL que se ejecuta de verdad:
```yaml
logging.level.org.hibernate.SQL: DEBUG
logging.level.org.hibernate.orm.jdbc.bind: TRACE   # los parámetros
```
Desactívalo en producción — llena el disco y filtra datos.

---

## Síntomas frecuentes

| Síntoma | Primera sospecha |
|---|---|
| Lento con muchos registros | N+1. Activa `generate_statistics` y cuenta queries |
| `LazyInitializationException` | Relación lazy fuera de transacción. Fetch explícito |
| `@Transactional` ignorado | Auto-invocación o método privado |
| OOM en contenedor | Falta `MaxRAMPercentage`; la JVM no ve el límite del cgroup |
| Falla solo en CI | Dependencia del orden de tests, zona horaria o estado compartido |
| Verde en local, rojo en producción | H2 vs Postgres, o configuración distinta |
| Test intermitente | `Thread.sleep` en vez de espera por condición; o estado entre tests |

---

## Ejecutar

```bash
./mvnw test                          # unitarios
./mvnw verify                        # + integración
./mvnw test -Dtest=PedidoServiceTest # una clase
./mvnw test -Dtest=PedidoServiceTest#crea_pedido   # un método
./mvnw -q clean verify                # lo que debe pasar antes de decir "listo"
```

Cobertura con JaCoCo, pero **la cobertura no es calidad**. 90% de líneas cubiertas con asserts inútiles es peor que 60% con tests que de verdad verifican reglas. Usa la cobertura para encontrar lo que no está probado, no como objetivo.
