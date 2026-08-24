# SafeSchool-UV Project Template

## Overview
Complete technical specification template for the SafeSchool-UV project, including all components, code, and documentation needed for MINEDU Hackathon 2026 participation.

## Project Files Structure
```
hermes_safeschool_uv/
├── README.md                  # Project overview and quick start
├── circuit_diagram.fzz        # Fritzing circuit diagram
├── circuit_diagram.png        # Rendered circuit diagram
├── code/
│   ├── SafeSchool-UV.ino      # Main Arduino firmware
│   ├── calibration.ino        # Sensor calibration sketch
│   └── test_routine.ino       # Testing and debugging sketches
├── docs/
│   ├── user_manual.md         # User manual
│   ├── assembly_instructions.md # Step-by-step assembly guide
│   ├── maintenance_guide.md   # Maintenance procedures
│   └── troubleshooting.md     # Common issues and solutions
├── mechanical/
│   ├── maqueta_design.pdf     # Maqueta blueprints
│   ├── bill_of_materials.csv  # Complete BOM with suppliers
│   └── 3d_models/             # Optional 3D printed parts
├── presentation/
│   ├── slides.pptx            # Presentation slides
│   ├── demo_script.md         # Demonstration script
│   └── judging_criteria.md    # Evaluation checklist
└── images/                    # Project images and diagrams
```

## Quick Reference

### UV Index Levels (WHO Standard)
| Index | Level | Color | Action |
|-------|-------|-------|--------|
| 0-2 | Bajo | Verde | Protección normal |
| 3-5 | Moderado | Amarillo | Usar bloqueador SPF15+ |
| 6-7 | Alto | Naranja | Usar bloqueador SPF30+, sombrero |
| 8-10 | Muy Alto | Rojo | Limitar tiempo al sol, SPF50+ |
| 11+ | Extremo | Morado | Evitar sol, protección máxima |

### Pin Assignments (Arduino Uno)
| Pin | Component | Function |
|-----|-----------|----------|
| A0 | GUVA-S12SD | UV Sensor Input |
| D5 | L298N IN1 | Motor Control |
| D6 | L298N IN2 | Motor Control |
| D7 | Red LED | High UV Indicator |
| D8 | Green LED | Safe UV Indicator |
| D9 | Buzzer | Audible Alert |
| D10 | Push Button | Manual Override |
| SCL | OLED | I2C Clock |
| SDA | OLED | I2C Data |
| 5V | All | Power (+) |
| GND | All | Ground |

### Component Cost Summary
- **Electronics**: S/ 230-380
- **Mechanical**: S/ 75-120
- **Total**: S/ 305-500 (without tools)

## Key Contacts for Materials
- **Amazon Perú**: https://www.amazon.com.pe
- **MercadoLibre**: https://www.mercadolibre.com.pe
- **Radio Shack Perú**: https://www.radioshack.com.pe
- **Local Ferreterías**: For wood, MDF, and mechanical parts
