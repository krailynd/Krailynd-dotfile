# Prompting por tipo de imagen

Estructura base, válida en los 11 modelos:

```
[sujeto] + [acción/pose] + [entorno] + [iluminación] + [óptica/estilo] + [calidad]
```

Lo que más mueve la aguja, por orden: **sujeto concreto > iluminación > óptica > adjetivos de calidad**. Añadir "8k ultra detailed masterpiece" a un prompt vago no lo arregla; concretar el sujeto sí.

---

## Iluminación — el ajuste de mayor impacto

| Término | Resultado |
|---|---|
| `soft natural window light` | Suave, halagador, editorial |
| `golden hour backlight` | Cálido, contraluz, atmosférico |
| `overcast diffused light` | Plano, uniforme, documental |
| `studio three-point lighting` | Limpio, controlado, comercial |
| `single hard key light, deep shadows` | Dramático, claroscuro |
| `blue hour, ambient city light` | Frío, nocturno, cinematográfico |

Sin especificar luz, el modelo pone un genérico plano. Especifícala siempre.

## Óptica — controla la sensación de foto real

| Término | Efecto |
|---|---|
| `85mm f/1.8, shallow depth of field` | Retrato, fondo desenfocado |
| `35mm f/8, deep focus` | Reportaje, todo nítido |
| `24mm wide angle` | Amplio, arquitectura, algo de distorsión |
| `macro lens, extreme close-up` | Detalle mínimo |
| `film grain, Portra 400` | Analógico, textura |

`krea/v2/large` responde especialmente bien a la jerga fotográfica: grano, desenfoque de movimiento, aspecto de película.

## Calidad — poco y concreto

Funciona: `natural skin texture`, `sharp focus`, `high detail`, `editorial photography`.
Ruido inútil: `masterpiece, best quality, 8k, ultra HD, trending on artstation` apilados. Ocupan atención del modelo sin aportar.

---

## Negativos

No todos los modelos exponen prompt negativo. Cuando esté disponible, va bien:
```
blurry, low resolution, distorted hands, extra fingers, watermark, text artifacts,
oversaturated, plastic skin
```

Si no hay negativo, formúlalo en positivo: en vez de "sin piel de plástico", escribe `natural skin texture with visible pores`.

---

## Texto dentro de la imagen

La mayoría de modelos deforma las letras. Si el texto importa:

1. `ideogram/v3` para rótulos y tipografía.
2. `gpt-image-2` para frases largas o CJK.
3. Entrecomilla el texto exacto: `a sign reading "ABIERTO"`.
4. Cuanto menos texto, mejor sale. Tres palabras salen bien; un párrafo no.

Alternativa más fiable: genera la imagen sin texto y superpón el texto después con Pillow. Control tipográfico total y cero riesgo de letras inventadas.

---

## Semilla y reproducibilidad

Con `seed` fija y el mismo prompt, el resultado se repite. Es la base de la consistencia:

- Explora **sin** semilla hasta encontrar una composición que sirva.
- Anota la semilla de esa imagen.
- Fija esa semilla y cambia **una sola cosa** por iteración.

Cambiar el prompt y la semilla a la vez impide saber qué causó la mejora. Es depuración: una variable cada vez.

---

## Iterar barato

```
1. flux-2/klein/9b ($0.006/MP, <1s)  →  4-6 pruebas, encuentra composición y semilla
2. flux-2-pro o krea/v2/large        →  1-2 generaciones finales
3. imgqc + imgfx pipeline            →  entrega
```

Explorar en el modelo caro multiplica el gasto sin mejorar la decisión: en fase de exploración lo que buscas es encuadre y composición, y eso ya se ve en el modelo barato.

---

## Errores frecuentes

| Síntoma | Causa | Arreglo |
|---|---|---|
| Cara plástica, irreal | Falta textura | `natural skin texture, visible pores, subsurface scattering` |
| Todo desenfocado | Falta punto de enfoque | `sharp focus on [sujeto]` + óptica concreta |
| Composición aburrida | Sin encuadre | `rule of thirds`, `low angle`, `close-up` |
| Colores chillones | Sobresaturación del modelo | `muted color palette, natural colors` |
| Texto ilegible | Modelo equivocado | `ideogram/v3`, o superponer con Pillow |
| Manos deformes | Limitación conocida | Reencuadra para que no salgan, o regenera con otra semilla |
| Personas distintas entre imágenes | Semilla y descripción variables | Fija semilla y repite las mismas palabras exactas |
