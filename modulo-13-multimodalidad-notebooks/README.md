# Módulo 13: Multimodalidad y Notebooks

## Descripción general

Claude Code no solo trabaja con texto y código: es un LLM multimodal capaz de "ver" imágenes, leer PDFs y procesar Jupyter notebooks completos (celdas, outputs y visualizaciones incluidas). Este módulo explora estas capacidades y presenta el patrón Visual-Driven Development, donde el flujo comienza con un mockup o screenshot y termina con código funcional.

**Tiempo estimado:** 2 horas y 20 minutos

**Nivel:** Avanzado (Bloque 3)

---

## Objetivos de aprendizaje

Al completar este módulo, serás capaz de:

1. **Proporcionar imágenes a Claude Code** usando arrastrar, pegar o referencias con `@`.
2. **Leer y analizar PDFs** con la herramienta Read, incluyendo estrategias para PDFs largos.
3. **Trabajar con notebooks Jupyter** (`.ipynb`): analizar, editar celdas y añadir visualizaciones.
4. **Aplicar Visual-Driven Development**: pasar de mockup o screenshot a código funcional.
5. **Identificar las limitaciones** de cada capacidad multimodal y cuándo no usarlas.
6. **Combinar multimodalidad con el patrón Writer/Reviewer** del M12 para verificación visual.
7. **Configurar Channels** para recibir eventos de Telegram, Discord u otros servicios externos en la sesión activa.
8. **Activar Chrome Integration** para debuggear consola y DOM, testear formularios y extraer datos desde el navegador.

---

## Prerrequisitos

- Módulos 01-06 completados (especialmente M02, CLI, y M03, contexto)
- Familiaridad básica con HTML/CSS o un framework frontend (para los ejercicios de VDD)
- Python instalado (para los ejercicios de notebooks)
- Recomendado: M12 (patrones avanzados, Writer/Reviewer)

---

## Duración estimada

**2 horas y 20 minutos** distribuidos así:

- Teoría: 110 minutos (7 ficheros, ~16 min cada uno)
- Ejercicios: 30 minutos

---

## Contenido

### Teoría

| Archivo | Tema | Duración |
|---------|------|----------|
| [01-lectura-de-imagenes.md](teoria/01-lectura-de-imagenes.md) | Claude Code como LLM multimodal: ver y analizar imágenes | 15 min |
| [02-lectura-de-pdfs.md](teoria/02-lectura-de-pdfs.md) | Leer PDFs con Read: páginas, límites y estrategias | 15 min |
| [03-jupyter-notebooks.md](teoria/03-jupyter-notebooks.md) | Notebooks `.ipynb`: leer, editar y mejorar con Claude | 15 min |
| [04-visual-driven-development.md](teoria/04-visual-driven-development.md) | Visual-Driven Development: de mockup a código | 15 min |
| [05-voice-y-computer-use.md](teoria/05-voice-y-computer-use.md) | `/voice`, push-to-talk y Remote Control con Computer Use | 15 min |
| [06-channels.md](teoria/06-channels.md) | Channels: recibir eventos de Telegram, Discord e iMessages en la sesión activa | 16 min |
| [07-chrome-integration.md](teoria/07-chrome-integration.md) | Chrome Integration (GA desde v2.1.198): debugging de consola y DOM, test de formularios, extracción de datos | 16 min |

### Ejercicios prácticos

| Archivo | Ejercicio | Duración |
|---------|-----------|----------|
| [01-analisis-visual.md](ejercicios/01-analisis-visual.md) | Análisis visual completo: imágenes, PDFs, notebooks y VDD | 30 min |

---

## Conceptos clave

| Concepto | Descripción |
|----------|-------------|
| **Multimodalidad** | Capacidad de Claude para procesar texto, imágenes y documentos en la misma sesión |
| **Herramienta Read (imágenes)** | Read funciona con PNG, JPG, GIF y WebP; presenta el contenido visualmente al modelo |
| **Herramienta Read (PDFs)** | Read acepta `.pdf` con el parámetro `pages` para limitar las páginas leídas |
| **NotebookEdit** | Herramienta nativa para editar celdas de notebooks `.ipynb` |
| **Visual-Driven Development** | Patrón donde un mockup o screenshot se convierte directamente en código |
| **Referencia con `@`** | `@ruta/al/archivo.png` o `@documento.pdf` para referenciar ficheros multimodales en el CLI |
| **Estrategia por secciones** | Leer PDFs largos en bloques con `pages: "1-20"`, `pages: "21-40"`, etc. |
| **`/voice`** | Slash command que activa push-to-talk: mantener Space para grabar y soltar para enviar |
| **push-to-talk** | Mecanismo de activación por tecla mantenida; configurable vía `keybindings.json` |
| **Remote Control** | Conecta `claude.ai/code` o la app móvil con una sesión de Claude Code que corre en local |
| **Computer Use** | Capacidad de **Claude Cowork** (no Claude Code) para interactuar con el escritorio: ratón, teclado, navegador y UI. Disponible como research preview, solo en macOS |
| **Channels** | Servidores MCP en modo push: fuentes externas (Telegram, Discord, iMessages) envían eventos a la sesión activa de Claude Code para que los procese y actúe |
| **Sender allowlist** | Lista de usuarios o grupos cuyas mensajes un Channel procesa; los demás se ignoran silenciosamente |
| **Chrome Integration** | Extensión "Claude in Chrome" que da acceso en tiempo real a la consola, el DOM, el estado de red y las interacciones del navegador desde Claude Code |
| **`--chrome` / `/chrome`** | Flag y slash command para activar Chrome Integration al iniciar o durante una sesión en curso |
| **`--channels`** | Flag para activar todos los Channels instalados al iniciar Claude Code; admite un nombre de canal como argumento para activar solo uno |

---

## Flujo de trabajo recomendado

```text
1. Teoría: imágenes + PDFs (30 min)
   |
2. Teoría: notebooks + VDD (30 min)
   |
3. Teoría: /voice y Computer Use (15 min)
   |
4. Teoría: Channels (16 min)
   |
5. Teoría: Chrome Integration (16 min)
   |
6. Ejercicio: análisis visual (30 min)
   - Parte 1: analizar screenshot de UI
   - Parte 2: documentar diagrama de arquitectura
   - Parte 3: extraer spec de un PDF
   - Parte 4: mejorar un notebook Jupyter
   - Parte 5: flujo completo VDD
```

---

## Por qué existe este módulo

La mayoría de los desarrolladores usa Claude Code como si fuera solo un asistente de texto. Sin embargo, muchos artefactos del día a día son visuales: mockups de Figma, diagramas de arquitectura, especificaciones en PDF y resultados de análisis en notebooks. Este módulo te enseña a traer esos artefactos directamente a la conversación con Claude, eliminando el paso de "describir lo que ves" y trabajando directamente sobre el contenido real.

---

## Navegación

- Anterior: [Módulo 12 - Metodologías de Desarrollo con IA](../modulo-12-metodologias-desarrollo-ia/README.md)
- Siguiente: [Módulo 14 - Claude Agent SDK](../modulo-14-agent-sdk/README.md)
