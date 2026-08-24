# Versiones, LTS y compatibilidad — verificación en vivo

## Por qué esto existe

Un LLM no puede saber la versión actual de nada. Su conocimiento se congeló en una fecha; hoy no es esa fecha. Escribir `<version>3.2.0</version>` "de memoria" en un `pom.xml` es la causa número uno de builds rotos en proyectos generados por IA.

La regla es simple: **verificar o no escribir**.

---

## Java (Maven / Gradle)

Fuente autoritativa: `maven-metadata.xml` de Maven Central.

```bash
~/.local/share/hermes/tools/mvnlatest org.springframework.boot:spring-boot-starter-parent
~/.local/share/hermes/tools/mvnlatest org.postgresql:postgresql
~/.local/share/hermes/tools/mvnlatest <groupId>:<artifactId> --all   # historial reciente
```

Varias de una vez:
```bash
~/.local/share/hermes/tools/mvnlatest \
  org.springframework.boot:spring-boot-starter-parent \
  org.flywaydb:flyway-core \
  org.postgresql:postgresql \
  org.projectlombok:lombok
```

Sin el helper, a mano:
```bash
curl -s https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-parent/maven-metadata.xml \
  | grep -E '<latest>|<release>'
```

### NO uses solrsearch para decidir versiones

```bash
# ✗ mentira comprobada
curl -s 'https://search.maven.org/solrsearch/select?q=g:"org.springframework.boot"&rows=1&wt=json'
```
El 2026-07-22 este endpoint devolvía `latestVersion: 3.5.3` mientras `maven-metadata.xml` daba `4.1.0` (publicado 2026-06-25). Su índice va meses atrasado. Sirve para descubrir que un artefacto existe, no para fijar su versión.

### Auditar un proyecto ya existente
```bash
cd <proyecto>
./mvnw versions:display-dependency-updates
./mvnw versions:display-plugin-updates
./mvnw dependency:tree -Dverbose        # conflictos y versiones efectivas
```

Con Spring Boot, **no fijes versiones de las dependencias que gestiona el BOM**. El `spring-boot-starter-parent` ya resuelve Jackson, Hibernate, Postgres driver, etc. Fijarlas a mano es cómo se rompe la coherencia del stack. Solo pon `<version>` en lo que el BOM no cubre.

---

## Node / npm

```bash
npm view <paquete> version          # última publicada
npm view <paquete> dist-tags        # latest, next, lts
npm view <paquete> engines          # qué Node exige
node -v && npm -v                   # qué hay instalado aquí
```

Node LTS son las versiones **pares** (20, 22, 24…). Las impares son de desarrollo — nunca en producción.

Compatibilidad real antes de instalar:
```bash
npm install --dry-run <paquete>
npm ls <paquete>                    # árbol y conflictos de peer deps
```

---

## Python

```bash
pip index versions <paquete>
python3 -V
uv pip compile requirements.in      # resolución determinista
```

Aquí hay `uv` instalado — prefiérelo a pip para resolver dependencias; es mucho más rápido y su resolutor es más estricto.

---

## Docker

```bash
docker image ls
skopeo list-tags docker://docker.io/library/postgres 2>/dev/null | head -30
```
Sin `skopeo`, consulta los tags en el registry. **Nunca uses `:latest` en producción** — fija la versión mayor.menor (`postgres:17-alpine`, no `postgres:latest`).

---

## Política de elección

**Producción → LTS.** Siempre.

| Ecosistema | Qué elegir |
|---|---|
| Java | LTS vigente (Java 25 en 2026; 21 si hay que soportar legado) |
| Node | LTS par vigente |
| Python | La estable menos una si hay muchas deps nativas; la última si el stack es puro |
| Postgres | Mayor estable, no la recién salida |
| Spring Boot | Última `.x` de la rama estable, nunca `-M*` ni `-RC*` |

**Nunca en producción:** `-M1`, `-RC1`, `-SNAPSHOT`, `alpha`, `beta`, `:latest`.

Antes de subir de versión mayor: lee las release notes de los *breaking changes*, no solo el número. Un salto de mayor en Spring Boot o Hibernate suele romper algo.

---

## Matriz de compatibilidad — qué cruzar siempre

Antes de fijar el stack de un proyecto Java, comprueba estas cuatro relaciones:

1. **Java ↔ Spring Boot** — cada rama de Boot declara su rango de JDK soportado.
2. **Spring Boot ↔ Hibernate/JPA** — lo fija el BOM; no lo toques a mano.
3. **Driver JDBC ↔ versión del motor** — el driver de Postgres es compatible hacia atrás, pero verifica si usas features nuevas.
4. **Maven/Gradle ↔ Java** — Maven 3.9.x soporta los JDK modernos; un Maven viejo con JDK nuevo falla con errores crípticos de bytecode.

Comando de comprobación real, no teórica:
```bash
./mvnw -q clean verify
```
Si compila y los tests pasan, el stack es compatible. Si no, el error dice cuál de las cuatro relaciones rompiste.

---

## Fuente que NO funciona

`endoflife.date` — probada el 2026-07-22, tanto `/api/java.json` como `/api/v1/products/java/` devolvían HTML de página no encontrada. Si alguna vez vuelve, es buena fuente para fechas de fin de soporte; hoy no la uses.
