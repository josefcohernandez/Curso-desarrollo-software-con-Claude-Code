# 04 - Fast Mode y Selección de Modelos

Claude Code ofrece controles granulares sobre la velocidad y la profundidad de razonamiento. Este capítulo explica Fast Mode, el parámetro de nivel de esfuerzo y cómo combinarlos con la elección de modelo para cada tipo de tarea.

## Conceptos clave

### Fast Mode

Fast Mode no es un modelo distinto. Es una optimización de velocidad sobre el modelo Opus 4.6 que reduce el tiempo de respuesta priorizando la rapidez frente a la profundidad de razonamiento.

**Lo que Fast Mode hace:**
- Genera output **2.5x más rápido** que el modo estándar (research preview)
- Mantiene el mismo modelo (Opus 4.6) y sus capacidades de base
- Es útil cuando necesitas iteraciones rápidas y la tarea no requiere razonamiento complejo

**Lo que Fast Mode NO hace:**
- No cambia de modelo a uno más barato o pequeño
- No reduce la calidad en tareas de complejidad baja o media
- No es equivalente a usar Haiku (que sí es un modelo diferente)

> **Nota v3.0 — Pricing de Fast Mode:** Fast Mode tiene un coste de $30/$150 por MTok (input/output), 6x el precio estándar de Opus ($5/$25). El incremento se justifica por la infraestructura de generación acelerada. Es un research preview disponible en planes Max/Team/Enterprise.

**Activar Fast Mode en el CLI:**

```bash
# Activar Fast Mode en la sesión actual
/fast

# Verificar estado actual del modo
/status
```

### Modelos disponibles (familia Claude 4.x)

Como se introdujo en el Capítulo 1, Claude Code ofrece tres modelos. Aquí profundizamos en la estrategia táctica de selección:

| Modelo | Model ID | Contexto | Fortaleza principal |
|--------|----------|----------|---------------------|
| Claude Opus 4.6 | `claude-opus-4-6` | 1M tokens | Razonamiento profundo, tareas complejas |
| Claude Sonnet 4.6 | `claude-sonnet-4-6` | 1M tokens | Equilibrio calidad/velocidad |
| Claude Haiku 4.5 | `claude-haiku-4-5-20251001` | 200K tokens | Velocidad, tareas simples |

Para especificar el modelo en el CLI:

```bash
# Iniciar sesión con un modelo específico
claude --model claude-opus-4-6
claude --model claude-sonnet-4-6
claude --model claude-haiku-4-5-20251001

# Cambiar modelo en una sesión activa
/model claude-sonnet-4-6
```

### Effort Level (nivel de esfuerzo)

La variable de entorno `CLAUDE_CODE_EFFORT_LEVEL` controla cuánto razonamiento interno aplica Claude antes de responder. Es independiente del modelo elegido.

| Valor | Comportamiento | Tokens de razonamiento | Disponibilidad |
|-------|---------------|----------------------|----------------|
| `low` | Respuesta rápida, razonamiento mínimo | Pocos | Todos los modelos |
| `medium` | Balance entre velocidad y profundidad **(default)** | Moderados | Todos los modelos |
| `high` | Razonamiento profundo antes de responder | Muchos | Todos los modelos |
| `max` | Máximo razonamiento posible, sin límites | Máximos | **Solo Opus 4.6** |

> **Nota:** Opus 4.6 y Sonnet 4.6 usan **medium** como nivel de esfuerzo por defecto. Medium es el nivel recomendado para la mayoría de tareas de programación.

```bash
# Configurar para la sesión actual
export CLAUDE_CODE_EFFORT_LEVEL=low
claude

# Configurar de forma persistente en tu shell
echo 'export CLAUDE_CODE_EFFORT_LEVEL=medium' >> ~/.bashrc

# Volver al default (medium)
unset CLAUDE_CODE_EFFORT_LEVEL
claude
```

**Formas de cambiar el nivel de esfuerzo durante una sesión:**

```bash
# Slash command (dentro de una sesión interactiva)
/effort low
/effort medium
/effort high
/effort max          # Solo Opus 4.6

# Flag CLI (al iniciar sesión)
claude --effort high
claude --effort max  # Solo Opus 4.6
```

**Activar high effort para un solo turno con "ultrathink":**

Si estás en un nivel de esfuerzo bajo o medio y necesitas razonamiento profundo para una pregunta puntual, incluye la palabra **"ultrathink"** en tu prompt. Esto activa temporalmente el nivel high para ese único turno, sin cambiar la configuración de la sesión:

```
> ultrathink: ¿Cuál es la causa raíz de este bug de concurrencia en el pool de conexiones?
```

Tras responder, Claude vuelve al nivel de esfuerzo configurado previamente.

## Ejemplos prácticos

### Tabla de decisión: modelo + Fast Mode + esfuerzo

Esta tabla resume la combinación óptima según el tipo de tarea:

| Tarea | Modelo | Fast Mode | Effort Level |
|-------|--------|-----------|--------------|
| Renombrar variable o función | Haiku | - | `low` |
| Implementar una feature nueva | Sonnet | No | `medium` |
| Depurar un bug complejo | Opus | No | `high` |
| Generar boilerplate o scaffolding | Sonnet | Sí | `low` |
| Revisión de seguridad | Opus | No | `high` |
| Exploración inicial de codebase | Haiku / Sonnet | Sí | `low` |
| Refactoring de módulo complejo | Opus | No | `high` |
| Escribir tests unitarios simples | Sonnet | Sí | `medium` |
| Diseño de arquitectura | Opus | No | `high` |
| Formateo y lint de código | Haiku | Sí | `low` |

### Combinando Fast Mode y Effort Level

```bash
# Tarea de exploración: máximo rendimiento, mínimo razonamiento
export CLAUDE_CODE_EFFORT_LEVEL=low
claude --model claude-haiku-4-5-20251001
/fast
> "Dame un mapa de los módulos principales de este repositorio"

# Tarea crítica: máximo razonamiento, sin Fast Mode
export CLAUDE_CODE_EFFORT_LEVEL=high
claude --model claude-opus-4-6
> "Analiza esta vulnerabilidad de seguridad y propón una mitigación"
```

### Patrón recomendado para el día a día

```bash
# Planificación matutina (Opus, razonamiento alto, sin Fast Mode)
export CLAUDE_CODE_EFFORT_LEVEL=high
claude --model claude-opus-4-6
> "Plan para las tareas de hoy: [lista]"
> /exit

# Implementación (Sonnet, esfuerzo medio, sin Fast Mode)
export CLAUDE_CODE_EFFORT_LEVEL=medium
claude --model claude-sonnet-4-6
> "Implementa la feature X según el plan"
> /exit

# Tareas rápidas (Haiku, esfuerzo bajo, Fast Mode)
export CLAUDE_CODE_EFFORT_LEVEL=low
claude --model claude-haiku-4-5-20251001
/fast
> "Escribe el commit message para estos cambios"
```

## Errores comunes

**Usar Opus con Fast Mode para tareas complejas**: Fast Mode reduce la profundidad de razonamiento. Si la tarea requiere razonamiento profundo (arquitectura, seguridad, bugs complejos), no actives Fast Mode.

**Confundir Fast Mode con cambio de modelo**: Fast Mode mantiene Opus. Si quieres ahorro de coste, cambia a Sonnet o Haiku, no uses Fast Mode.

**`CLAUDE_CODE_EFFORT_LEVEL=low` para todo**: El esfuerzo bajo es útil en tareas simples, pero en tareas complejas produce respuestas superficiales. Resérvalo para exploración y tareas mecánicas.

**Usar Opus para todo**: Opus es el más potente pero también el más lento y costoso. Sonnet cubre el 80% de los casos de uso con mejor relación calidad/tiempo.

## Resumen

- Fast Mode es una optimización de velocidad sobre Opus 4.6, no un cambio de modelo
- Se activa con `/fast` en la sesión activa
- Los modelos actuales son Opus 4.6 (1M tokens), Sonnet 4.6 y Haiku 4.5
- `CLAUDE_CODE_EFFORT_LEVEL` (low/medium/high/max) controla la profundidad de razonamiento; el default es **medium**
- Usa `/effort` o `--effort` para cambiar el nivel durante o al iniciar una sesión
- Incluye "ultrathink" en un prompt para activar high effort en un solo turno
- El nivel `max` solo está disponible para Opus 4.6
- La tabla de decisión combina modelo + Fast Mode + esfuerzo según el tipo de tarea
- Para tareas críticas: Opus, sin Fast Mode, esfuerzo high o max
