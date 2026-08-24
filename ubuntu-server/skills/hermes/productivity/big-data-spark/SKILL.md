---
name: big-data-spark
description: Skill de Big Data y Procesamiento Masivo con PySpark 4.1.1 en Windows (E:\entornos\spark). Pipelines ETL, Spark SQL y procesado distribuido.
---

# Big Data & PySpark Engineering Skill (Windows SSH)

Skill especialista para procesamiento masivo de datos, pipelines ETL y analítica Big Data en Windows PC (`windows-krai`).

---

## 1. CONFIGURACIÓN DEL ENTORNO EN WINDOWS

- **Host SSH**: `windows-krai` (IP Tailscale `YOUR_TAILSCALE_IP`).
- **Python Executable**: `E:\entornos\spark\python.exe` (PySpark 4.1.1).
- **Librerías Clave**: PySpark, PySpark SQL, Delta Lake, PyArrow.

---

## 2. COMANDO DE EJECUCIÓN AUTÓNOMA

Verificar PySpark en Windows desde Hermes:
```bash
ssh -o RemoteCommand=none -o RequestTTY=no windows-krai "E:\entornos\spark\python.exe -c \"from pyspark.sql import SparkSession; spark = SparkSession.builder.appName('HermesTest').getOrCreate(); print('Spark Version:', spark.version)\""
```

---

## 3. CASOS DE USO PROFESIONALES

- **Pipelines ETL**: Lectura y transformación de millones de registros (CSV, Parquet, JSON, Delta).
- **Consultas Spark SQL**: Ejecución de queries de alto rendimiento sobre datasets masivos.
- **Integración con Obsidian**: Registro de esquemas y estadísticas de rendimiento en `E:\YOUR_VAULT\Documentos\ETL_Pipelines.md`.
