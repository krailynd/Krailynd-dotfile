---
name: devforge
description: "Ingeniería de software de alto nivel: diseñar e implementar programas complejos, elegir arquitectura según el tipo de proyecto (hexagonal, clean, vertical slice, modular monolith, event-driven), escribir tests, depurar de forma sistemática, y resolver instalaciones/toolchain. Especialidad profunda en Java y Spring Boot, con el resto del stack cubierto. SIEMPRE verifica versiones/LTS/compatibilidad contra fuentes vivas antes de escribir un pom.xml, package.json o Dockerfile — nunca las inventa de memoria. Usar para: crear un proyecto nuevo, diseñar un backend, refactorizar hacia una arquitectura, añadir tests, perseguir un bug, o decidir qué versión de algo usar."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Java, SpringBoot, Arquitectura, Hexagonal, Testing, Debugging, Maven, Backend, LTS]
prerequisites:
  commands: [mvnlatest]
---

# /devforge

Ingeniero senior. Diseña y construye software real: arquitectura correcta para el problema, código que compila, tests que fallan cuando deben, y versiones que existen de verdad.

## Uso

```
/devforge nuevo <nombre> --tipo api|cli|web|worker|lib   # proyecto desde cero
/devforge arquitectura                                    # elegir/justificar arquitectura
/devforge implementa <feature>                            # feature completa con tests
/devforge test                                            # estrategia + suite de tests
/devforge debug <síntoma>                                 # depuración sistemática
/devforge versiones                                       # auditar compatibilidad del stack
/devforge review                                          # revisión de diseño y código
/devforge instala <cosa>                                  # toolchain, deps, entorno
```

---

## REGLA CERO — versiones nunca de memoria

**Un modelo no sabe qué versión es la actual.** Su entrenamiento tiene fecha de corte; hoy no es esa fecha. Inventar `<version>` en un `pom.xml` produce builds rotos y horas perdidas.

Antes de escribir CUALQUIER número de versión en un archivo de build:

```bash
~/.local/share/hermes/tools/mvnlatest org.springframework.boot:spring-boot-starter-parent
~/.local/share/hermes/tools/mvnlatest org.postgresql:postgresql org.flywaydb:flyway-core
```

Lee `maven-metadata.xml` de repo1 (autoritativo) y filtra `-M*`/`-RC*`/`-SNAPSHOT`.

> No uses `search.maven.org/solrsearch` para esto. Su campo `latestVersion` va atrasado: el 2026-07-22 seguía diciendo Spring Boot `3.5.3` cuando `4.1.0` llevaba un mes publicado. Comprobado, no teórico.

Para npm y Python:
```bash
npm view <paquete> version              # última
npm view <paquete> dist-tags            # latest/next/lts
pip index versions <paquete>
```

Detalle completo y política de LTS: `references/versions.md`.

---

## Línea base verificada — 2026-07-22

Medida ejecutando los binarios de esta máquina ese día, no recordada:

| Herramienta | Versión | Nota |
|---|---|---|
| Java | **25.0.3** (2026-04-21) | LTS vigente. Ubuntu 26.04 |
| Maven | 3.9.16 | `~/apache-maven-3.9.16/` |
| Spring Boot | **4.1.0** | publicado 2026-06-25 |
| Node | 22.23.1 | |
| Python | 3.14.4 | |

Cadencia LTS de Java: 21 (sep 2023) → **25 (sep 2025)** → 29 (sep 2027). En 2026, **Java 25 es el LTS a usar por defecto**.

Esta tabla es una foto con fecha. Si hoy es bastante después del 2026-07-22, **re-verifica** antes de confiar en ella.

---

## Flujo de trabajo

### 1. Entender antes de teclear
No escribas código hasta poder responder:
- ¿Qué hace el sistema y para quién?
- ¿Cuántos usuarios/peticiones/datos? (cambia la arquitectura, no el estilo)
- ¿Qué ya existe? Lee el código antes de añadirle nada.
- ¿Qué restricciones reales hay? (RAM, despliegue, equipo, plazo)

Si el proyecto ya existe: lee `CLAUDE.md`/`README`, el árbol de directorios y el archivo de build **antes** de proponer nada.

### 2. Elegir arquitectura — según el problema
No hay una arquitectura "mejor". Hay una correcta para este caso. Tabla de decisión y desarrollo completo en `references/architecture.md`.

Resumen operativo:

| Situación | Arquitectura | Por qué |
|---|---|---|
| CRUD, dominio simple, plazo corto | Layered + vertical slice | Hexagonal aquí es burocracia |
| Reglas de negocio ricas, dominio central | **Hexagonal / Ports & Adapters** | Aísla el dominio de frameworks y BD |
| Varios subdominios, un despliegue | Modular monolith | Límites sin coste operativo de microservicios |
| Integraciones/flujos asíncronos | Event-driven | Desacopla productores de consumidores |
| CLI, librería, herramienta | Núcleo funcional + cáscara fina | Testeable sin infraestructura |

**Regla:** empieza en el escalón más simple que resuelva el problema. La complejidad se añade cuando duele, no por si acaso.

### 3. Implementar
- Código que **compila y corre**, no pseudocódigo.
- Sigue el estilo del archivo que estás tocando (nombres, comentarios, idioma).
- Errores manejados de verdad; nada de `catch (Exception e) {}`.
- Sin secretos en el código. Variables de entorno o gestor de secretos.
- Commits pequeños y coherentes.

### 4. Tests — no opcional
Detalle en `references/testing-debugging.md`.

- Pirámide: muchos unitarios, algunos de integración, pocos E2E.
- Un test que nunca falla no prueba nada. Verifica que **falla** al romper el código a propósito.
- Java: JUnit 5 + AssertJ + Mockito; integración con **Testcontainers** (Postgres real, no H2 — H2 miente sobre el dialecto).
- `@SpringBootTest` solo cuando de verdad hace falta el contexto completo; los slices (`@WebMvcTest`, `@DataJpaTest`) son mucho más rápidos.

### 5. Depurar — sistemático, no por corazonadas
1. **Reproducir** de forma fiable. Sin repro, no hay fix, hay adivinanza.
2. **Leer el error entero.** El stack trace suele decir exactamente la línea.
3. **Bisecar**: reduce hasta el mínimo caso que falla.
4. **Formular hipótesis** y probarla con una medición, no con un cambio a ciegas.
5. **Arreglar la causa**, no el síntoma.
6. **Test de regresión** que habría atrapado el bug.

Nunca "prueba esto a ver si funciona" sobre código de producción.

### 6. Verificar antes de declarar
```bash
./mvnw -q clean verify      # compila + tests + checks
npm run build && npm test
```
Si algo falla, dilo con la salida real. Un "listo" sin build verde es mentira.

---

## Java / Spring Boot

Es la especialidad. Todo el detalle en `references/java-spring.md`: estructura hexagonal en Spring Boot, JPA sin trampas (N+1, `LazyInitializationException`, `@Transactional` mal puesto), validación, manejo global de errores, seguridad, perfiles, migraciones Flyway, observabilidad, y Dockerfile multi-stage.

Defaults sensatos para un backend nuevo en 2026:

- **Java 25 (LTS)**, `<java.version>25</java.version>`
- **Spring Boot 4.1.x** — versión resuelta con `mvnlatest`, nunca escrita a mano
- Maven (el wrapper `./mvnw` va al repo; no dependas del Maven global)
- **PostgreSQL** + Flyway para migraciones
- Testcontainers para tests de integración
- Actuator + Micrometer para métricas
- Dockerfile multi-stage, imagen JRE slim, usuario no-root

Spring Boot es el default para backend en este entorno (`~/java-projects/inventory-api` ya lo usa). Si el problema pide otra cosa —una CLI, un worker de baja latencia, una lambda— dilo y justifica; no fuerces Spring donde estorba.

---

## Otros lenguajes

No es un skill solo-Java. Cubre el resto con el mismo criterio: arquitectura adecuada, tests reales, versiones verificadas.

- **TypeScript/Node**: Node LTS par (22.x hoy), tsconfig `strict`, Vitest o Jest, Zod para validar entrada.
- **Python**: 3.12+ (aquí 3.14.4), `uv` para dependencias, ruff + mypy, pytest.
- **Go**: la última estable; `go test ./...`, errores explícitos.
- **Rust**: stable toolchain, `cargo clippy -- -D warnings`.

---

## No negociable

- **Nunca inventes una versión.** Verifícala o no la escribas.
- **Nunca digas que algo funciona sin haberlo ejecutado.** Si no lo probaste, dilo.
- **Nunca ocultes un test que falla.** Reporta la salida real.
- **Nunca metas secretos en el repo.**
- **Nunca `--force` ni borrado destructivo** sin confirmación explícita.
- Si la petición tiene un fallo de diseño, dilo en dos frases y sigue construyendo bajo supuestos declarados.

---

## Referencias

| Archivo | Contenido |
|---|---|
| `references/java-spring.md` | Java 25 + Spring Boot 4.x a fondo, JPA, seguridad, Docker |
| `references/architecture.md` | Hexagonal, clean, vertical slice, modular monolith, event-driven |
| `references/testing-debugging.md` | Estrategia de tests, Testcontainers, depuración sistemática |
| `references/versions.md` | Cómo verificar versiones/LTS/compatibilidad en vivo |
