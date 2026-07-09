# 04 - Fast Mode y Selección de Modelos

Claude Code ofrece controles granulares sobre la velocidad y la profundidad de razonamiento. Este capítulo explica Fast Mode, el parámetro de nivel de esfuerzo y cómo combinarlos con la elección de modelo para cada tipo de tarea.

## Conceptos clave

### Fast Mode

Fast Mode no es un modelo distinto. Es una optimización de velocidad que reduce el tiempo de respuesta priorizando la rapidez frente a la profundidad de razonamiento. El modelo base sobre el que corre Fast Mode ha ido evolucionando junto al flagship: Opus 4.6 originalmente, Opus 4.7 desde v2.1.142, y **Opus 4.8** desde v2.1.154 (dato histórico: Fast Mode siempre usa el Opus más reciente disponible como base).

**Lo que Fast Mode hace:**
- Genera output **2.5x más rápido** que el modo estándar (research preview)
- Mantiene el modelo Opus vigente (Opus 4.8) y sus capacidades de base
- Es útil cuando necesitas iteraciones rápidas y la tarea no requiere razonamiento complejo

**Lo que Fast Mode NO hace:**
- No cambia de modelo a uno más barato o pequeño
- No reduce la calidad en tareas de complejidad baja o media
- No es equivalente a usar Haiku (que sí es un modelo diferente)

> **Nota v3.0 (histórica) — Pricing de Fast Mode en Opus 4.6/4.7:** Fast Mode tenía un coste de $30/$150 por MTok (input/output), 6x el precio estándar de Opus ($5/$25). El incremento se justificaba por la infraestructura de generación acelerada.

> **Novedad v2.1.154 — Nuevo pricing de Fast Mode en Opus 4.8:** el coste de Fast Mode baja a **2x la tarifa estándar** ($10/$50 por MTok) a cambio de **2.5x más velocidad**, frente al 6x anterior en Opus 4.7. Sigue siendo un research preview disponible en planes Max/Team/Enterprise.

**Activar Fast Mode en el CLI:**

```bash
# Activar Fast Mode en la sesión actual
/fast

# Verificar estado actual del modo
/status
```

### Modelos disponibles (familia actual + generación anterior)

Como se introdujo en el Capítulo 1, Claude Code ofrece varios modelos. Aquí profundizamos en la estrategia táctica de selección:

| Modelo | Model ID | Contexto | Fortaleza principal | Disponibilidad |
|--------|----------|----------|---------------------|----------------|
| Claude Opus 4.8 | `claude-opus-4-8` | 1M tokens | Razonamiento profundo + nivel `xhigh`, flagship | Todos los planes con acceso a Opus |
| Claude Sonnet 5 | `claude-sonnet-5` | 1M tokens **nativo** | Equilibrio calidad/velocidad, modelo por defecto | Todos los planes (precio promo hasta 31 ago 2026) |
| Claude Fable 5 | `claude-fable-5` | Consultar doc. oficial | Modelo "Mythos-class": narrativo/especializado | Todos los planes |
| Claude Haiku 4.5 | `claude-haiku-4-5-20251001` | 200K tokens | Velocidad, tareas simples | Todos los planes |
| Claude Opus 4.7 | `claude-opus-4-7` | 1M tokens | Generación anterior de flagship | Planes Max (claude.ai) |
| Claude Opus 4.6 | `claude-opus-4-6` | 1M tokens | Generación anterior, razonamiento profundo | API, Bedrock, Vertex, Team, Enterprise |
| Claude Sonnet 4.6 | `claude-sonnet-4-6` | 1M tokens | Generación anterior, equilibrio calidad/velocidad | Todos los planes |

> Opus 4.7/4.6 y Sonnet 4.6 se mantienen documentados aquí porque siguen siendo válidos para fijar una versión concreta (por ejemplo, en pipelines de CI/CD que necesitan reproducibilidad), pero **Opus 4.8 y Sonnet 5 son ya la referencia recomendada** para empezar cualquier tarea nueva.

Para especificar el modelo en el CLI:

```bash
# Iniciar sesión con un modelo específico
claude --model claude-opus-4-8      # Opus 4.8 (flagship)
claude --model claude-sonnet-5      # Sonnet 5 (modelo por defecto)
claude --model claude-fable-5       # Fable 5 (contenido narrativo)
claude --model claude-opus-4-7      # Generación anterior, si la necesitas fijada
claude --model claude-haiku-4-5-20251001

# Cambiar modelo en una sesión activa
/model claude-sonnet-5
```

> Desde v2.1.153, `/model` guarda el modelo elegido como nuevo **modelo por defecto** de tus próximas sesiones. Si solo quieres probarlo en la sesión actual, consulta [07-fallback-model-y-comandos-revision.md](07-fallback-model-y-comandos-revision.md).

> **Aviso v2.1.108:** Cambiar de modelo durante una conversación activa con `/model`
> hace que el siguiente turno **retenga el historial completo sin prompt cache**.
> Para evitar el coste adicional, cambia de modelo al inicio de una sesión limpia.

### Effort Level (nivel de esfuerzo)

La variable de entorno `CLAUDE_CODE_EFFORT_LEVEL` controla cuánto razonamiento interno aplica Claude antes de responder. Es independiente del modelo elegido.

| Valor | Comportamiento | Tokens de razonamiento | Disponibilidad |
|-------|---------------|----------------------|----------------|
| `low` | Respuesta rápida, razonamiento mínimo | Pocos | Todos los modelos |
| `medium` | Balance entre velocidad y profundidad | Moderados | Todos los modelos |
| `high` | Razonamiento profundo antes de responder **(default)** | Muchos | Todos los modelos |
| `xhigh` | Thinking de máxima profundidad (entre `high` y `max`) | Muy muchos | **Solo Opus 4.8** (heredado de Opus 4.7) |
| `max` | Máximo razonamiento posible, sin límites | Máximos | **Solo Opus 4.6, 4.7 y 4.8** |

> **Nota v2.1.117:** El nivel de esfuerzo por defecto es **high** para todos los planes
> (Pro, Max, API key, Bedrock, Vertex, Team, Enterprise). Hasta v2.1.117, los planes
> Pro/Max tenían `medium` como default.

```bash
# Configurar para la sesión actual
export CLAUDE_CODE_EFFORT_LEVEL=low
claude

# Configurar de forma persistente en tu shell
echo 'export CLAUDE_CODE_EFFORT_LEVEL=high' >> ~/.bashrc

# Volver al default (high)
unset CLAUDE_CODE_EFFORT_LEVEL
claude
```

**Formas de cambiar el nivel de esfuerzo durante una sesión:**

```bash
# Slash command interactivo (sin argumentos): abre un slider con flechas + Enter
/effort

# Slash command directo (dentro de una sesión interactiva)
/effort low
/effort medium
/effort high
/effort xhigh        # Solo Opus 4.8
/effort max          # Solo Opus 4.6, 4.7 y 4.8

# Flag CLI (al iniciar sesión)
claude --effort high
claude --effort xhigh   # Solo Opus 4.8
claude --effort max     # Solo Opus 4.6, 4.7 y 4.8
```

> **Novedad v2.1.166:** para desactivar el thinking por completo en modelos que
> piensan por defecto vía API, usa la variable de entorno `MAX_THINKING_TOKENS=0`
> o el flag `--thinking disabled`. Es distinto de bajar el effort level: desactiva
> el razonamiento extendido en lugar de reducir su profundidad.
>
> ```bash
> export MAX_THINKING_TOKENS=0
> claude --model claude-opus-4-8
>
> # Equivalente con flag
> claude --thinking disabled
> ```

> **Novedad v2.1.111:** `/effort` sin argumentos abre un **slider interactivo**.
> Navega entre los niveles con las teclas de flecha y confirma con Enter.
> El slider muestra solo los niveles disponibles para el modelo activo en la sesión.

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
| Implementar una feature nueva | Sonnet 5 | No | `medium` |
| Depurar un bug complejo | Opus 4.8 | No | `high` |
| Generar boilerplate o scaffolding | Sonnet 5 | Sí | `low` |
| Revisión de seguridad | Opus 4.8 | No | `high` |
| Exploración inicial de codebase | Haiku / Sonnet 5 | Sí | `low` |
| Refactoring de módulo complejo | Opus 4.8 | No | `high` |
| Escribir tests unitarios simples | Sonnet 5 | Sí | `medium` |
| Diseño de arquitectura | Opus 4.8 | No | `high` |
| Formateo y lint de código | Haiku | Sí | `low` |
| Redactar documentación extensa o guía de usuario | Fable 5 | No | `medium` |
| Trabajar sobre un repositorio muy grande (mucho contexto) | Sonnet 5 | No | `medium` |
| Problema de concurrencia o seguridad crítica | Opus 4.8 | No | `xhigh` |
| Análisis arquitectónico profundo | Opus 4.8 | No | `xhigh` o `max` |

### Combinando Fast Mode y Effort Level

```bash
# Tarea de exploración: máximo rendimiento, mínimo razonamiento
export CLAUDE_CODE_EFFORT_LEVEL=low
claude --model claude-haiku-4-5-20251001
/fast
> "Dame un mapa de los módulos principales de este repositorio"

# Tarea crítica: máximo razonamiento, sin Fast Mode
export CLAUDE_CODE_EFFORT_LEVEL=high
claude --model claude-opus-4-8
> "Analiza esta vulnerabilidad de seguridad y propón una mitigación"
```

### Patrón recomendado para el día a día

```bash
# Planificación matutina (Opus 4.8, razonamiento alto, sin Fast Mode)
export CLAUDE_CODE_EFFORT_LEVEL=high
claude --model claude-opus-4-8
> "Plan para las tareas de hoy: [lista]"
> /exit

# Implementación (Sonnet 5, esfuerzo medio, sin Fast Mode)
export CLAUDE_CODE_EFFORT_LEVEL=medium
claude --model claude-sonnet-5
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

- Fast Mode es una optimización de velocidad sobre el Opus vigente (ahora Opus 4.8), no un cambio de modelo
- Se activa con `/fast` en la sesión activa; desde v2.1.154 cuesta **2x tarifa por 2.5x velocidad** (antes 6x en Opus 4.7)
- Los modelos de referencia actuales son **Opus 4.8** (flagship), **Sonnet 5** (por defecto, 1M contexto nativo, precio promo hasta 31 ago 2026) y **Fable 5** (contenido narrativo); Opus 4.7, Opus 4.6, Sonnet 4.6 y Haiku 4.5 siguen disponibles
- `CLAUDE_CODE_EFFORT_LEVEL` (low/medium/high/xhigh/max) controla la profundidad de razonamiento; el default es **high** para todos los planes desde v2.1.117
- `/effort` sin argumentos abre un slider interactivo (novedad v2.1.111)
- El nivel `xhigh` solo está disponible para Opus 4.8 (heredado de Opus 4.7)
- El nivel `max` está disponible para Opus 4.6, 4.7 y 4.8
- `MAX_THINKING_TOKENS=0` o `--thinking disabled` desactivan el thinking en modelos que piensan por defecto vía API (v2.1.166)
- Desde v2.1.153, `/model` guarda el modelo elegido como nuevo modelo por defecto (detalle en [07-fallback-model-y-comandos-revision.md](07-fallback-model-y-comandos-revision.md))
- Cambiar de modelo a mitad de conversación con `/model` invalida el prompt cache
- Incluye "ultrathink" en un prompt para activar high effort en un solo turno
- La tabla de decisión combina modelo + Fast Mode + esfuerzo según el tipo de tarea
- Para tareas críticas: Opus 4.8, sin Fast Mode, esfuerzo `xhigh` o `max`
