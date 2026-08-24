# Krailynd - Preferencias de Entrega de Documentos

**Fecha**: 05 de Julio 2026  
**Contexto**: Krailynd solicitó explícitamente formato profesional para guías de recursos

## 📄 Preferencias de Formato

### ✅ **Lo que SI quiere**
- **Estructura con tablas**: Organizar información en formato tabular siempre que sea posible
- **Listas organizadas**: Usar viñetas y numeración para jerarquizar información
- **Formato PDF profesional**: Para documentos largos (>1000 palabras)
- **Encabezados claros**: Usar jerarquía de títulos (H1, H2, H3)
- **Separadores visuales**: Líneas horizontales para dividir secciones

### ❌ **Lo que NO quiere**
- **Texto plano desorganizado**: Bloques de texto sin estructura
- **Formato informal**: Sin encabezados, sin jerarquía
- **Listas simples**: Solo texto con saltos de línea

## 📋 Estructura Esperada para Guías

```
# TÍTULO PRINCIPAL
## Subtítulo o Sección

### Categoría 1
| Columna 1 | Columna 2 | Columna 3 |
|-----------|-----------|-----------|
| Item 1    | Descripción | Enlace |
| Item 2    | Descripción | Enlace |

---

### Categoría 2
- [ ] Item con checkbox
- [ ] Otro item

**Nota**: Texto explicativo en negrita o cursiva
```

## 🎯 Ejemplo Real (Solicitud del 05/07/2026)

Krailynd pidió:
> "Un PDF con +500 enlaces de recursos gratuitos para YouTube, DaVinci Resolve y Blender"

**Formato esperado**:
- Documento PDF profesional
- Más de 500 enlaces **verificados y funcionales**
- Organizados por categorías
- Con tablas para facilitar la lectura
- Incluyendo metadatos (fecha, autor, versión)

## 📊 Recomendaciones para Hermes

1. **Siempre preguntar**: "¿Quieres que lo organice en tablas como prefieres?"
2. **Priorizar PDF**: Para documentos extensos, generar PDF con ReportLab
3. **Incluir índice**: Para documentos >5 páginas
4. **Verificar enlaces**: Asegurar que todos los recursos sean funcionales
5. **Metadatos**: Incluir fecha de compilación, autor, versión

## 🔧 Herramientas Recomendadas

```bash
# Para PDF profesional con ReportLab
python3 ~/.hermes/scripts/hermes_pdf_academic.py \
  --title "Título" \
  --output /tmp/guia.pdf \
  --phone YOUR_WHATSAPP_NUMBER \
  --body "## Sección 1\n\nContenido..."

# Para enviar como documento
~/.hermes/scripts/hermes_send_file.sh /tmp/guia.pdf document YOUR_WHATSAPP_NUMBER "Guía de recursos"
```

## 📝 Notas Adicionales

- Krailynd usa **AFFiNE** (`draw.sahacloud.dpdns.org`) para notas personales
- Prefiere **Outline** (`docs.sahacloud.dpdns.org`) para documentación empresarial
- Los archivos PDF generados deben ser **legibles y bien formateados**
- Evitar estilo "borrador" - siempre entrega final profesional