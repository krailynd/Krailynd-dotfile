---
name: deep-learning-research
description: Skill de Deep Learning y Research Engineering en Windows (E:\entornos\deep-learning). Entrenamiento de modelos, PyTorch, TensorFlow, Transformers y Visión Computacional.
---

# Deep Learning & AI Research Engineering Skill (Windows SSH)

Skill especialista para entrenamiento de Redes Neuronales, Fine-Tuning de LLMs, Modelos de Visión Computacional y MLOps en Windows PC (`windows-krai`).

---

## 1. CONFIGURACIÓN DEL ENTORNO EN WINDOWS

- **Host SSH**: `windows-krai` (IP Tailscale `YOUR_TAILSCALE_IP`).
- **Python Executable**: `E:\entornos\deep-learning\python.exe`
- **Frameworks Clave**: PyTorch, torchvision, torchaudio, TensorFlow, Keras, HuggingFace `transformers`, `datasets`, `accelerate`, OpenCV.

---

## 2. VERIFICACIÓN DE GPU Y EJECUCIÓN

Verificar disponibilidad de CUDA / GPU en Windows:
```bash
ssh -o RemoteCommand=none -o RequestTTY=no windows-krai "E:\entornos\deep-learning\python.exe -c \"import torch; print('CUDA disponible:', torch.cuda.is_available(), '| GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU')\""
```

---

## 3. WORKFLOWS DE TRABAJO Y RESEARCH

- **Fine-Tuning & Model Training**: Creación de scripts de entrenamiento con seguimiento de métricas (pérdida, precisión, matriz de confusión).
- **Exportación de Modelos**: Guardar pesos en formato ONNX (`.onnx`) o PyTorch Checkpoints (`.pt` / `.safetensors`).
- **Resúmenes en Obsidian**: Guardar arquitectura y curvas de entrenamiento en `E:\YOUR_VAULT\Machine Learning\`.
