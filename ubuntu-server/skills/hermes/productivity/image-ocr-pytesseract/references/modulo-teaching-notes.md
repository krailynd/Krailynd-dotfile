# Math Concept: Modulo / Residuo — Teaching Notes

## User's mental model evolution (2026-08-02)

### Initial confusion
> "es lo que queda del numero para completar a la llega redondeada de un numero" — thought residue = "what's missing to reach the next multiple"

### Breakthrough moment
User's own example: **100 caramelos ÷ 3 personas**
- Each gets 33 (integer division)
- 33 × 3 = 99 distributed
- **1 left in hand** = residuo
- User: "osea es como que yo tengo 100 y tengo que repartilo a 3 personas..."

### Winning analogy: **El Reparto (Distribution)**
> "Reparto lo máximo posible en partes iguales enteras, y lo que me queda en la mano sin poder repartir = residuo"

### Key phrases that clicked
| User's words | Concept |
|--------------|---------|
| "me queda ahi un poco" | remainder exists when not divisible |
| "no se puede tener la misma cantidad entera" | integer division constraint |
| "para decir que si te dan 3 personas y tienes 100" | concrete distribution framing |
| "claramente que en forma entera sin decimales pues es imposible" | integer vs float division distinction |

## Teaching pattern for modulo

1. **Concrete distribution** (candies, cards, people) — not abstract numbers
2. **Physical action**: "deal out groups of N until you can't"
3. **What's in YOUR hand at the end** = residue
4. **Verification**: `divisor × quotient + residue = dividend`

## Common misconceptions to address

| Misconception | Correction |
|---------------|------------|
| Residue = "what's missing to next multiple" | No, that's `divisor - residue` |
| Residue = "decimal part" | No, `100/3 = 33.33`, residue = 1 |
| Negative numbers work like C/Java | Python: residue sign = divisor sign |

## Python-specific rules

```python
# Always true in Python
a == b * (a // b) + (a % b)

# Sign rule: residue sign = divisor sign
-17 % 5   = 3   (divisor +)
17 % -5   = -3  (divisor -)
-17 % -5  = -2  (divisor -)
```

## Quick reference for future explanations

**Spanish keywords that work:**
- "reparto" / "repartir" (distribution)
- "lo que sobra en la mano" (what's left in hand)
- "vueltas completas" (complete rounds)
- "no alcanza para otra vuelta" (not enough for another round)

**Avoid:**
- "lo que falta para..." (what's missing to...)
- "completar el redondeo" (complete the rounding)
- "parte decimal" (decimal part)