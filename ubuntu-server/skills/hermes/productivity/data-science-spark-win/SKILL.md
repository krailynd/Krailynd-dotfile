---
name: data-science-spark-win
description: "Data Science, Machine Learning, Deep Learning Research Engineering, PySpark, Predictions & Windows PC (windows-krai) Integration."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [DataScience, MachineLearning, DeepLearning, PySpark, Predictions, Windows, SSH, Anaconda, PyTorch, Pandas, Polars]
prerequisites:
  commands: [python3, ssh]
---

# /data-science-spark-win — Data Science, Spark & Remote Windows Lab

Comprehensive engineering workflow for Data Science, Machine Learning, Deep Learning, Predictions, and Big Data (PySpark), supporting both local Ubuntu execution and remote execution on the main Windows PC (`windows-krai`).

---

## 1. Remote Windows PC Lab (`windows-krai`)

When the main Windows PC is powered ON and accessible via SSH (`ssh windows-krai`), use its dedicated environments in `E:\entornos\`:

### Connect & Environment Map
- **Connection Command**: `ssh -o RequestTTY=no -o RemoteCommand=none windows-krai "COMMAND"`
- **Environments Path**: `E:\entornos\`
- **Spark Environment**: `E:\entornos\spark` (PySpark 4.2.0 + Java 21 LTS Temurin)
- **Data Science Environment**: `E:\entornos\data-science` (pandas, polars, scikit-learn, matplotlib)
- **Deep Learning Environment**: `E:\entornos\deep-learning` (PyTorch, Transformers, CUDA)
- **Conda Installation**: `E:\anaconda`

### Remote Execution Syntax
```bash
# Run script in Windows Spark environment
ssh -o RequestTTY=no -o RemoteCommand=none windows-krai \
  "E:\\entornos\\spark\\python.exe E:\\entornos\\spark\\script.py"

# Run PyTorch deep learning training on Windows GPU
ssh -o RequestTTY=no -o RemoteCommand=none windows-krai \
  "E:\\entornos\\deep-learning\\python.exe E:\\entornos\\deep-learning\\train.py"
```

---

## 2. Local Ubuntu Execution (Fallback Mode)

When Windows is powered OFF or for lightweight datasets:
- Local Python virtualenv in Hermes (`~/.hermes/hermes-agent/venv/bin/python`)
- Includes `pandas`, `numpy`, `matplotlib`, `scikit-learn`, `PIL`, `pytesseract`.

---

## 3. High-Resolution Diagram & Flowchart Generation

To create architectural diagrams, machine learning pipeline flowcharts, or system schemas locally:

```bash
PUPPETEER_EXECUTABLE_PATH=/home/sahacloud/.cache/ms-playwright/chromium-1237/chrome-linux64/chrome \
  local-diagram.py --out pipeline.png --code "flowchart TD
    A[Data Source / Stream] -->|PySpark / Polars| B(Feature Engineering)
    B -->|PyTorch / XGBoost| C[Prediction Model]
    C -->|Evaluation| D[Output Storage]
"
```

---

## 4. Best Practices for Deep Learning & Predictions

1. **Exploratory Data Analysis (EDA)**: Inspect nulls, distributions, correlations before modeling.
2. **Feature Engineering**: Standardize, encode categorical variables, handle class imbalance.
3. **Model Selection**: Start with baseline (Logistic Regression / XGBoost), then proceed to Deep Learning (PyTorch) if needed.
4. **Reproducibility**: Set seeds (`torch.manual_seed`, `np.random.seed`).
