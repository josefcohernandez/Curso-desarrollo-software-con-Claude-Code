# Modulo 13: Multimodalidad y Notebooks

## Descripcion General

Claude Code no solo trabaja con texto y codigo: es un LLM multimodal capaz de "ver" imagenes, leer PDFs y procesar Jupyter notebooks completos (celdas, outputs y visualizaciones incluidas). Este modulo explora estas capacidades y presenta el patron Visual-Driven Development, donde el flujo comienza con un mockup o screenshot y termina con codigo funcional.

**Tiempo estimado:** 1 hora 50 minutos

**Nivel:** Avanzado (Bloque 3)

---

## Objetivos de Aprendizaje

Al completar este modulo, seras capaz de:

1. **Proporcionar imagenes a Claude Code** usando arrastrar, pegar o referencias con `@`
2. **Leer y analizar PDFs** con la herramienta Read, incluyendo estrategias para PDFs largos
3. **Trabajar con notebooks Jupyter** (.ipynb): analizar, editar celdas y anadir visualizaciones
4. **Aplicar Visual-Driven Development**: pasar de mockup o screenshot a codigo funcional
5. **Identificar las limitaciones** de cada capacidad multimodal y cuando no usarlas
6. **Combinar multimodalidad con el patron Writer/Reviewer** del M12 para verificacion visual

---

## Prerequisitos

- Modulos 01-06 completados (especialmente M02 CLI y M03 contexto)
- Familiaridad basica con HTML/CSS o un framework frontend (para los ejercicios de VDD)
- Python instalado (para los ejercicios de notebooks)
- Recomendado: M12 (patrones avanzados, Writer/Reviewer)

---

## Duracion Estimada

**1 hora 50 minutos** distribuidas:
- Teoria: 80 minutos (5 ficheros, ~16 min cada uno)
- Ejercicios: 30 minutos

---

## Contenido

### Teoria

| Archivo | Tema | Duracion |
|---------|------|----------|
| [01-lectura-de-imagenes.md](teoria/01-lectura-de-imagenes.md) | Claude Code como LLM multimodal: ver y analizar imagenes | 15 min |
| [02-lectura-de-pdfs.md](teoria/02-lectura-de-pdfs.md) | Leer PDFs con Read: paginas, limites y estrategias | 15 min |
| [03-jupyter-notebooks.md](teoria/03-jupyter-notebooks.md) | Notebooks .ipynb: leer, editar y mejorar con Claude | 15 min |
| [04-visual-driven-development.md](teoria/04-visual-driven-development.md) | Visual-Driven Development: de mockup a codigo | 15 min |
| [05-voice-y-computer-use.md](teoria/05-voice-y-computer-use.md) | /voice push-to-talk y Remote Control con Computer Use | 15 min |

### Ejercicios Practicos

| Archivo | Ejercicio | Duracion |
|---------|-----------|----------|
| [01-analisis-visual.md](ejercicios/01-analisis-visual.md) | Analisis visual completo: imagenes, PDFs, notebooks y VDD | 30 min |

---

## Conceptos Clave

| Concepto | Descripcion |
|----------|-------------|
| **Multimodalidad** | Capacidad de Claude para procesar texto, imagenes y documentos en la misma sesion |
| **Herramienta Read (imagenes)** | Read funciona con PNG, JPG, GIF y WebP; presenta el contenido visualmente al modelo |
| **Herramienta Read (PDFs)** | Read acepta .pdf con el parametro `pages` para limitar las paginas leidas |
| **NotebookEdit** | Herramienta nativa para editar celdas de notebooks .ipynb |
| **Visual-Driven Development** | Patron donde un mockup o screenshot se convierte directamente en codigo |
| **Referencia con @** | `@ruta/al/archivo.png` o `@documento.pdf` para referenciar ficheros multimodales en el CLI |
| **Estrategia por secciones** | Leer PDFs largos en bloques con `pages: "1-20"`, `pages: "21-40"`, etc. |
| **/voice** | Slash command que activa push-to-talk: mantener Space para grabar, soltar para enviar |
| **push-to-talk** | Mecanismo de activacion por tecla mantenida; configurable via keybindings.json |
| **Remote Control** | Conecta claude.ai/code o la app movil con una sesion de Claude Code que corre en local |
| **Computer Use** | Capacidad de **Claude Cowork** (no Claude Code) para interactuar con el escritorio: ratón, teclado, navegador, UI. Disponible como research preview, solo en macOS |

---

## Flujo de Trabajo Recomendado

```
1. Teoria: Imagenes + PDFs (30 min)
   |
2. Teoria: Notebooks + VDD (30 min)
   |
3. Teoria: /voice y Computer Use (15 min)
   |
4. Ejercicio: Analisis visual (30 min)
   - Parte 1: Analizar screenshot de UI
   - Parte 2: Documentar diagrama de arquitectura
   - Parte 3: Extraer spec de un PDF
   - Parte 4: Mejorar un notebook Jupyter
   - Parte 5: Flujo completo VDD
```

---

## Por que este modulo existe

La mayoria de los desarrolladores usa Claude Code como si fuera solo un asistente de texto. Sin embargo, muchos artefactos del dia a dia son visuales: mockups de Figma, diagramas de arquitectura, especificaciones en PDF, resultados de analisis en notebooks. Este modulo te enseña a traer esos artefactos directamente a la conversacion con Claude, eliminando el paso de "describir lo que ves" y trabajando directamente sobre el contenido real.

---

## Navegacion

- Anterior: [Modulo 12 - Metodologias de Desarrollo con IA](../modulo-12-metodologias-desarrollo-ia/README.md)
- Siguiente: [Modulo 14 - Claude Agent SDK](../modulo-14-agent-sdk/README.md)
