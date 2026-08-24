# Arquitectura — elegir la correcta, no la de moda

## Tabla de decisión

Antes de elegir, responde tres preguntas:
1. ¿Las reglas de negocio son **ricas** (cálculos, invariantes, estados) o el sistema mueve datos de A a B?
2. ¿Cuántos **subdominios** distintos hay?
3. ¿La infraestructura va a **cambiar** (cambiar de BD, de proveedor de pagos, de cola)?

| Respuestas | Arquitectura | Coste |
|---|---|---|
| Datos simples, 1 dominio, infra estable | **Layered + vertical slice** | Bajo |
| Reglas ricas, infra puede cambiar | **Hexagonal (Ports & Adapters)** | Medio |
| Varios subdominios, un solo despliegue | **Modular monolith** | Medio |
| Flujos asíncronos, muchas integraciones | **Event-driven** | Alto |
| Escala/equipos independientes de verdad | Microservicios | Muy alto |

**No empieces en microservicios.** Casi nadie los necesita. Un modular monolith bien hecho se parte en servicios después, si duele; al revés no se puede.

---

## Hexagonal / Ports & Adapters

El dominio no conoce a nadie. Todo lo de fuera entra por interfaces que **el dominio define**.

```
        driving adapters              driven adapters
   (REST, CLI, scheduler, tests)    (JPA, HTTP, Kafka, S3)
              │                              ▲
              ▼                              │
        ┌──────────────────────────────────────────┐
        │  application  (casos de uso, puertos)     │
        │  ┌────────────────────────────────────┐  │
        │  │  domain  (entidades, reglas)       │  │
        │  │  CERO imports de framework          │  │
        │  └────────────────────────────────────┘  │
        └──────────────────────────────────────────┘
```

Estructura en Java:

```
com.empresa.proyecto
├── domain/
│   ├── model/            Pedido, Dinero, EstadoPedido   ← POJOs puros
│   └── port/
│       ├── in/           CrearPedidoUseCase             ← lo que el mundo pide
│       └── out/          PedidoRepository, PasarelaPago ← lo que el dominio necesita
├── application/
│   └── service/          CrearPedidoService             ← orquesta, implementa port/in
└── infrastructure/
    ├── web/              PedidoController (REST)        ← driving
    ├── persistence/      JpaPedidoRepository            ← driven, implementa port/out
    └── config/           Beans de Spring
```

**La regla que lo sostiene:** en `domain/` no puede haber ni un `import org.springframework` ni un `import jakarta.persistence`. Si lo hay, no es hexagonal, es layered con carpetas bonitas.

Test de si lo hiciste bien: ¿puedes testear todo el dominio sin levantar Spring y sin base de datos? Si sí, está bien.

Verifícalo automáticamente con ArchUnit:
```java
@ArchTest
static final ArchRule dominio_no_depende_de_frameworks =
    noClasses().that().resideInAPackage("..domain..")
        .should().dependOnClassesThat()
        .resideInAnyPackage("org.springframework..", "jakarta.persistence..");
```

**Cuándo NO usarla:** CRUD sin reglas. Te queda un mapper por entidad, tres clases por caso de uso, y cero beneficio.

---

## Layered + Vertical Slice

Lo pragmático para CRUD y plazos cortos. Corta por **feature**, no por capa técnica.

```
features/
├── pedido/
│   ├── PedidoController.java
│   ├── PedidoService.java
│   ├── PedidoRepository.java
│   └── dto/
└── cliente/
    └── ...
```

Mejor que `controllers/ services/ repositories/` con 40 clases cada uno: al tocar una feature, todo lo que necesitas está junto. Y migrar una slice a hexagonal después es local, no global.

---

## Modular Monolith

Un despliegue, módulos con límites reales. El escalón intermedio correcto.

```
src/main/java/com/empresa/
├── pedidos/
│   ├── api/          ← lo ÚNICO público del módulo
│   └── internal/     ← package-private, nadie de fuera entra
├── inventario/
│   ├── api/
│   └── internal/
└── shared/
```

Reglas:
- Los módulos se hablan solo por `api/` o por eventos.
- Nada de `internal/` es público.
- Cada módulo dueño de sus tablas. Sin joins cruzando módulos.

Spring Modulith verifica esto en un test y falla el build si alguien cruza un límite.

---

## Event-Driven

Para integraciones y flujos asíncronos. Añade potencia y complejidad a partes iguales.

Dentro de un proceso, empieza por eventos de Spring (`ApplicationEventPublisher`) — sin infraestructura. Solo salta a Kafka/RabbitMQ cuando de verdad necesites persistencia de eventos o consumidores separados.

Lo que la gente olvida y luego duele:
- **Idempotencia**: el mismo evento llegará dos veces. Diseña para eso desde el día uno.
- **Orden**: no está garantizado entre particiones.
- **Outbox pattern**: escribir en BD y publicar el evento debe ser atómico. Sin outbox, pierdes eventos cuando el broker se cae entre el commit y el publish.
- **Dead letter queue**: los eventos que fallan siempre deben ir a algún sitio.

---

## Decisiones transversales

**DTOs en el borde.** Nunca expongas entidades JPA en el JSON de la API. Un cambio de columna no puede romper a los clientes. En Java 25, los `record` hacen los DTOs triviales.

**Errores como parte del diseño.** Excepciones de dominio (`PedidoNoEncontrado`) traducidas a HTTP en un `@RestControllerAdvice`. El dominio no sabe qué es un 404.

**Transacciones en la capa de aplicación**, no en el controlador ni en el repositorio. Un caso de uso = una transacción.

**Configuración por entorno**, nunca en código. Perfiles de Spring + variables de entorno.

---

## Documentar la decisión

Cuando elijas arquitectura, escribe un ADR corto en `docs/adr/NNN-titulo.md`:

```markdown
# ADR 001 — Hexagonal para el módulo de pedidos

## Estado
Aceptada — 2026-07-22

## Contexto
Las reglas de precios cambian a menudo y hay que testearlas sin BD.
Está previsto migrar de Stripe a otra pasarela en 6 meses.

## Decisión
Ports & Adapters. El dominio define `PasarelaPago`; la infraestructura la implementa.

## Consecuencias
+ Dominio testeable sin Spring ni BD.
+ Cambiar de pasarela = una clase nueva en infrastructure.
− Más clases y un mapper entre dominio y entidad JPA.
```

Un ADR de diez líneas ahorra la discusión de "¿por qué está así esto?" seis meses después.
