---
name: math-solver-sympy
description: "Resolución de problemas matemáticos, álgebra lineal, cálculo diferencial/integral y matrices mediante Python SymPy y NumPy."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Math, SymPy, Calculus, Algebra, Matrices, Derivatives, Integrals, Equations]
prerequisites:
  commands: [python3]
---

# /math-solver-sympy — Resolutor Matemático Simbólico

Permite resolver operaciones matemáticas complejas, integrales, derivadas, límites y álgebra de matrices en el entorno local de Python usando **SymPy**.

---

## 1. Ejemplos de Uso Directo

### Ecuaciones y Cálculo (Derivadas / Integrales)
```bash
python3 -c "
import sympy as sp
x = sp.Symbol('x')
f = sp.sin(x)**2 * sp.exp(x)
print('Función:', f)
print('Derivada:', sp.diff(f, x))
print('Integral indefinida:', sp.integrate(f, x))
"
```

### Álgebra Lineal & Matrices
```bash
python3 -c "
import sympy as sp
A = sp.Matrix([[1, 2], [3, 4]])
print('Matriz A:\n', A)
print('Determinante:', A.det())
print('Inversa:\n', A.inv())
print('Autovalores:', A.eigenvals())
"
```
