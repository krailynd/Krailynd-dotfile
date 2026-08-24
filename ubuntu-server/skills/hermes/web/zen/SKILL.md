---
name: zen
description: |
  Operar el navegador Zen Browser real como si fueras un usuario: abrir paginas,
  leerlas, pulsar, escribir, desplazarte, capturar pantalla y descargar
  ficheros, manteniendo el contexto entre pasos. Usa la capa unica
  `zen-ctl`, comun a todos los modelos de Hermes. Carga esta skill cuando
  el usuario pida navegar, consultar una web con sesion iniciada, rellenar un
  formulario, comprobar como se ve algo en el navegador o automatizar una
  tarea web paso a paso.
version: 2.0.0
platforms: [linux, windows]
metadata:
  hermes:
    tags: [browser, zen, firefox, automation, web, operator]
    category: web
    related_skills: [computer-use, browser-use]
---

# /zen — operador de navegador

Controlas una sesion **real** de Zen Browser: las cookies del usuario, sus sesiones
iniciadas y sus extensiones. No es un navegador limpio de pruebas. Actua en
consecuencia.

Todo pasa por un unico comando de shell:

```bash
zen-ctl <subcomando> [opciones]
```

Da igual que modelo seas. La interfaz y la semantica son identicas para todos:
si un modelo barato hace la observacion y uno fuerte decide el plan, ambos
hablan exactamente este mismo lenguaje.

## Antes de nada

```bash
zen-ctl status
```

Si dice `extension: NO conectada`, **para y dilo**. No sigas intentando
comandos: todos fallaran igual y solo gastaras tokens. El problema esta en la
instalacion (Zen Browser cerrado, host nativo sin registrar), no en lo que estes
intentando hacer.

## El ciclo de trabajo

Repite este ciclo. No lo cortes.

1. **Mira** — `zen-ctl look`
2. **Actua** — un solo paso: `click`, `type`, `scroll`…
3. **Verifica** — vuelve a `look` (o `shot` si necesitas ver pixeles)

```bash
zen-ctl open https://ejemplo.com
zen-ctl look
zen-ctl click --ref e12
zen-ctl look
```

`look` devuelve algo asi:

```
URL    https://ejemplo.com/login
TITULO Iniciar sesion

INTERACTIVOS (7 de 7)
  [e3] input (email) ph="Correo electronico"
  [e4] input (password) ph="Contrasena"
  [e5] button "Entrar"
```

Esos `[eN]` son **referencias estables**: apuntan al mismo nodo aunque vuelvas
a leer la pagina. Usalas para actuar; son mucho mas fiables que un selector CSS
que te inventes.

## Reglas que importan

**Un paso por comando.** Nada de encadenar cinco acciones y mirar al final. Si
el tercer paso falla, sin verificacion intermedia no sabras cual fue.

**Verifica lo que cambia.** Despues de pulsar algo que deberia navegar o abrir
un panel, vuelve a `look`. Si el resumen dice `la pagina no ha cambiado desde
tu ultima lectura`, tu accion **no hizo nada**: no repitas lo mismo, cambia de
enfoque.

**Prefiere `--ref` sobre `--selector`, y `--selector` sobre `--texto`.**
`--texto` es ambiguo por naturaleza y falla con `E_AMBIGUOUS_SELECTOR` cuando
coincide con varias cosas.

**No uses `look` como muletilla.** Si acabas de leer la pagina y tu accion no
la ha cambiado, no la releas. Cada `look` cuesta contexto.

**`raw eval` es el ultimo recurso.** Existe, pero si hay un subcomando
especifico, usalo: son mas seguros, mas legibles en el historial y dan mejores
errores.

## Errores y que hacer con cada uno

El adaptador ya reintenta solo (2 veces) los fallos transitorios. Si un error
llega hasta ti, es que reintentar no basta.

| Codigo | Significado | Que hacer |
|---|---|---|
| `E_SELECTOR_NOT_FOUND` | El elemento no esta (o ya no) | `look` otra vez; la pagina cambio |
| `E_AMBIGUOUS_SELECTOR` | `--texto` coincide con varios | Usa `--ref` |
| `E_TIMEOUT` | No llego a tiempo | `zen-ctl wait --selector <x>` y reintenta |
| `E_RESTRICTED_URL` | Pagina interna del navegador | No es automatizable; navega a una URL http(s) |
| `E_CONTENT_UNREACHABLE` | El content script no responde | `zen-ctl nav reload` |
| `E_BUCLE` | Llevas 4 veces la misma accion | **Para.** Cambia de estrategia o admite que no se puede |
| `E_BRIDGE_CAIDO` | El bridge no responde | Fallo de infraestructura; informa al usuario |
| `ERROR vision` | Ningun backend de vision respondio | La captura SI existe: su ruta sale en la salida. Sigue con `look` |

Si una respuesta trae `estado: parcial`, el comando cumplio **a medias** —
tipicamente una captura de pagina completa cortada por el tope de pantallas.
El campo `aviso` dice por que. No saques conclusiones como si tuvieras el dato
entero: o subes el tope, o dices explicitamente que la vista esta incompleta.

Cuando algo falla dos veces por el mismo motivo, **no lo intentes una tercera
igual**. O cambias de camino o le dices al usuario que no se puede y por que.

## Capturas y vista

```bash
zen-ctl shot --label antes-de-enviar     # solo captura -> ruta en disco
zen-ctl see --pregunta "¿hay algun error?"   # captura Y la analiza
```

`shot` devuelve una **ruta**, no la imagen: una captura en base64 dentro de tu
contexto cuesta decenas de miles de tokens.

**`see` es el comando que quieres casi siempre.** Captura y se la pasa al
backend de vision configurado, que te devuelve texto. Funciona igual seas el
modelo que seas — tambien si tu no ves imagenes. Ahi esta la gracia: la
capacidad de mirar no depende de que modelo este activo.

Cuando usar `see` en vez de `look`:

| Situacion | Comando |
|---|---|
| Saber que hay y que puedes pulsar | `look` (mas barato, siempre) |
| `look` dice que la accion no cambio nada y no entiendes por que | `see` |
| Algo depende del layout: solapamientos, cosas cortadas, modales | `see` |
| Contenido en imagen, canvas o video sin texto en el DOM | `see` |
| Confirmar visualmente antes de algo irreversible | `see` |

No uses `see` por rutina: cuesta una llamada a un modelo de vision. `look`
primero, `see` cuando `look` no baste.

## Limitacion real de Firefox/Zen

En Gecko **no existe Chrome DevTools Protocol**. Todos los clicks y pulsaciones
que genera Hermes son sinteticos (`isTrusted: false`). Un sitio que compruebe
`isTrusted` los ignorara y no hay forma de evitarlo desde una extension.

Que significa en la practica:

- `--coordenadas` y `--real` **siguen funcionando**, pero no dan entrada de
  confianza: resuelven el elemento del punto y le mandan eventos sinteticos.
- Si un click no surte efecto y ya probaste `--coordenadas`, **no insistas**:
  en este navegador no hay escalado posible. Dilo y sigue por otra via.
- A cambio, las capturas en segundo plano son mas limpias que en Chromium:
  `tabs.captureTab` no adjunta nada ni muestra avisos.

## Cursor visual (modo operador)

```bash
zen-ctl overlay debug      # cursor animado, resalte persistente, etiquetas
zen-ctl overlay normal     # destello breve sobre cada objetivo
zen-ctl overlay off        # por defecto
```

Con el overlay encendido, Hermes mueve un cursor propio hasta el elemento y lo
resalta **antes** de actuar, y eso queda grabado en la captura de evidencia.

Enciendelo en `debug` cuando:

- una accion "funciona" pero no pasa nada — veras si apuntaba donde creias,
- sospechas que hay algo tapando el objetivo,
- el usuario quiere ver que esta haciendo el agente.

```bash
zen-ctl highlight --ref e12 --etiqueta "voy a pulsar aqui"
zen-ctl say "Buscando el panel de ajustes…"
```

`highlight` resalta sin actuar: util para confirmarle al usuario donde vas a
pulsar antes de hacerlo.

## Formularios

```bash
zen-ctl look
zen-ctl type --ref e3 --text "usuario@ejemplo.com"
zen-ctl type --ref e4 --text "$CONTRASENA"
zen-ctl click --ref e5 --esperar-navegacion
zen-ctl look
```

Si escribes y el campo se queda vacio, el sitio usa un editor que ignora los
eventos sinteticos. Reintenta con `--real`, que teclea de verdad via CDP:

```bash
zen-ctl type --ref e3 --text "hola" --real
```

Lo mismo con los clicks: si `click` no surte efecto, `--coordenadas` fuerza una
pulsacion real.

## Autonomia: sigue hasta terminar

**No pidas permiso para cada clic.** Un flujo de doce pasos con doce
confirmaciones no es un operador de navegador, es un mando a distancia.
Encadena los pasos triviales —navegar, abrir menus, leer, desplazarte,
rellenar campos— y reporta al final con la evidencia.

Para y pregunta **solo** ante algo irreversible: pagar, publicar, enviar un
mensaje, borrar datos, cambiar credenciales o permisos de seguridad, aceptar
terminos legales. Ahi si: para, ensena la captura y espera.

Si te bloquea un login, un 2FA o un captcha, para y dilo. No inventes
credenciales ni intentes rodearlo.

## Niveles de modelo

`see` y `analyze` aceptan `--nivel`, que enruta por Omniroute al modelo
adecuado. Misma interfaz, distinto coste:

```bash
zen-ctl see --nivel rapido   --pregunta "¿cargo la pagina?"
zen-ctl see --nivel normal   --pregunta "¿que opciones hay aqui?"   # defecto
zen-ctl see --nivel profundo --pregunta "¿por que esta roto el layout?"
```

Usa `rapido` para comprobaciones tontas y `profundo` solo cuando la respuesta
requiera razonar sobre lo que se ve.

## Playbooks

Resumen de las recetas mas habituales. Las versiones completas —con las
particularidades de X.com y Reddit— estan en `docs/PLAYBOOKS.md` del proyecto.

No son guiones a seguir a ciegas: son el esqueleto, y el ciclo
mirar→actuar→verificar sigue mandando.

### X.com — «los ultimos 10 posts de este usuario»

```bash
zen-ctl open https://x.com/USUARIO --esperar idle
zen-ctl wait --selector "article" --timeout 25
zen-ctl look --max 40
```

X virtualiza el scroll: **los posts que salen del viewport se desmontan del
DOM**. Hay que recoger mientras bajas, no leerlo todo al final.

```bash
zen-ctl extract links --max 60    # los /status/NNN identifican cada post
zen-ctl scroll --a abajo
zen-ctl look --max 40
```

Maximo 6 iteraciones. Descarta reposts si te pidieron posts *del usuario* (su
permalink apunta a otro autor). Un hilo son varios `article` seguidos del mismo
autor: cuenta como uno. Si sale muro de login, para — la sesion no esta
iniciada y no debes autenticarte.

### Reddit — «analiza este hilo»

```bash
zen-ctl open "https://www.reddit.com/r/SUB/comments/ID/" --esperar idle
zen-ctl wait --selector "shreddit-comment, .Comment, [data-testid=comment]" --timeout 25
zen-ctl look --max 50
```

**Si el frontend nuevo se resiste, cambia a `old.reddit.com`**: es HTML plano y
mucho mas facil de leer. Para comentarios, `scroll --a abajo` + `look`, maximo
4 veces. Expande solo los «More replies» de primer nivel: hacerlo entero es
infinito. Ignora `[deleted]` / `[removed]`.

Entregable: postura general, los 3-5 argumentos con mas peso y las
discrepancias. No parafrasees comentario a comentario.

### «Entra a una web y cambia una configuracion»

Ojo con la ambiguedad, porque son dos cosas distintas:

- **Ajustes DE LA WEB** (tu cuenta en un servicio): se navegan como cualquier
  otra pagina.
- **Permisos DEL NAVEGADOR** para ese sitio (camara, notificaciones): eso es
  `zen-ctl site`.

Para lo primero:

```bash
zen-ctl open https://servicio.com/settings --esperar idle
zen-ctl look
zen-ctl click --ref e14                  # la seccion que toque
zen-ctl look                             # confirma que abrio
zen-ctl type --ref e22 --text "nuevo valor"
zen-ctl see --pregunta "¿el formulario muestra algun error de validacion?"
zen-ctl click --ref e30 --esperar-navegacion   # guardar
zen-ctl look                             # confirma que guardo
```

**Verifica siempre despues de guardar.** Un "Guardar" que no guarda es el fallo
mas comun y el mas silencioso.

Para lo segundo:

```bash
zen-ctl site "https://meet.ejemplo.com/*" camera --valor allow
```

### «Navega este panel complejo»

Los paneles de administracion anidan pestanas, acordeones y modales.

1. `zen-ctl overlay debug` — vas a necesitar ver donde pulsa.
2. `look` y **quedate con el mapa**: que secciones hay y sus `[eN]`.
3. Un nivel por paso: click → `look` → decide. Nunca dos clicks seguidos.
4. Si un click abre un modal, el `look` siguiente lo reflejara. Si no aparece,
   `see` para comprobar si hay algo tapando.
5. Cuando te pierdas: `zen-ctl session` te dice como llegaste ahi sin
   releer nada.

### «Captura y analiza»

```bash
zen-ctl see --pregunta "¿que muestra el grafico de la derecha?"
zen-ctl see --selector "#panel-resumen" --pregunta "¿que valores hay?"
zen-ctl see --completa --pregunta "¿el pie de pagina tiene aviso legal?"
```

`--selector` recorta antes de analizar: mas barato y mas preciso que mandar la
pantalla entera cuando ya sabes donde mirar.

### Tareas de varios pasos

Para un flujo largo (login → navegar → rellenar → confirmar):

- `zen-ctl session` al empezar cada tramo, para saber donde estas.
- Una captura etiquetada en cada hito: `shot --label paso-3-formulario`.
- Si te interrumpen y retomas luego, `session` reconstruye el contexto sin
  volver a leer las paginas.
- Ante algo irreversible (pagar, borrar, enviar) **para y confirma con el
  usuario**, ensenandole la evidencia.

## Cosas que NO debes hacer

- **No inventes credenciales.** Si un login pide datos que no tienes, para y
  pideselos al usuario.
- **No aceptes terminos, no compres, no envies dinero ni publiques nada** en
  nombre del usuario sin que te lo haya pedido explicitamente para esa accion
  concreta.
- **No cierres pestanas que no abriste tu.** El usuario esta trabajando ahi.
- **No leas ni exfiltres** contenido de pestanas ajenas a la tarea.

Ante la duda en algo irreversible: para y pregunta. Es mas barato que
deshacerlo.

## Referencia rapida

```bash
zen-ctl status                              # salud del puente
zen-ctl open <url> [--nueva] [--esperar idle]
zen-ctl look [--max 60]                     # lectura por defecto
zen-ctl elements [--filtro texto]           # + coordenadas
zen-ctl click --ref e12 [--esperar-navegacion] [--coordenadas]
zen-ctl type --ref e5 --text "..." [--enter] [--real]
zen-ctl press Enter [--mod ctrl] [--repetir 3]
zen-ctl scroll [--a abajo] [--dy 500]
zen-ctl wait --selector ".resultado" [--timeout 30]
zen-ctl nav back|forward|reload
zen-ctl extract links|forms|images|videos|tables|meta
zen-ctl shot [--label x] [--completa] [--selector "#panel"]
zen-ctl see [--pregunta "..."] [--selector "#x"] [--completa]
zen-ctl analyze --shot <ruta> [--pregunta "..."]
zen-ctl overlay off|normal|debug [--todas]
zen-ctl highlight --ref e12 [--etiqueta "..."] [--tipo foco|hover]
zen-ctl say "texto sobre la pagina"
zen-ctl site "https://x.com/*" camera|notifications|... [--valor allow]
zen-ctl download <url>
zen-ctl session                             # que has hecho hasta ahora
zen-ctl reset                               # empezar limpio
zen-ctl catalogo                            # todo lo que sabe la extension
zen-ctl raw <cmd> --json-params '{...}'     # escotilla de emergencia
```

`zen-ctl session` es util cuando pierdes el hilo: te dice donde estas y que
llevas hecho sin necesidad de releer la pagina.
