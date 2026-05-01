# 02 - Opus 4.7 y Razonamiento Adaptativo

## Qué es Opus 4.7

Opus 4.7 es el modelo más capaz de Anthropic (disponible desde v2.1.111). Mantiene
la ventana de **1M tokens de contexto** e introduce el nivel de esfuerzo `xhigh`
para razonamiento de máxima profundidad. Disponible para suscriptores de los planes
**Max** de claude.ai.

Opus 4.6 sigue disponible para usuarios de API key, Bedrock y Vertex.

---

## Razonamiento Adaptativo

### 5 Niveles de Esfuerzo

| Nivel | Cuándo | Disponibilidad |
|-------|--------|----------------|
| **Bajo (low)** | Tareas simples, respuestas directas | Todos los modelos |
| **Medio (medium)** | Tareas con algo de complejidad | Todos los modelos |
| **Alto (high)** | Problemas complejos, multi-archivo **(default Pro/Max desde v2.1.117)** | Todos los modelos |
| **Extra alto (xhigh)** | Thinking de máxima profundidad entre `high` y `max` | **Solo Opus 4.7** |
| **Máximo (max)** | Razonamiento sin límites | **Solo Opus 4.6 y 4.7** |

Opus decide automáticamente cuánto "pensar" basándose en la complejidad.

> **Novedad v2.1.117:** Para Opus 4.6 y Sonnet 4.6 en planes **Pro y Max**, el nivel
> de esfuerzo por defecto sube de `medium` a **`high`**. Para usuarios de API key,
> Bedrock, Vertex, Team y Enterprise el default ya era `high` desde v2.1.94.

> **Tip:** Para activar razonamiento profundo en un solo turno sin cambiar la configuración de la sesión, incluye la keyword **"ultrathink"** en tu prompt.

### Adaptive Thinking (reemplaza Extended Thinking)

> **Cambio v3.0:** En Opus 4.6 y 4.7, **adaptive thinking** es el nuevo comportamiento por defecto: el modelo decide automáticamente cuándo y cuánto razonar. Los parámetros `thinking: {type: "enabled"}` y `budget_tokens` siguen siendo funcionales pero ya no son necesarios. Para revertir al comportamiento anterior, configura `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.

Con adaptive thinking, no necesitas activar ni desactivar el razonamiento profundo manualmente. Opus ajusta dinámicamente la profundidad de su razonamiento basándose en la complejidad detectada.

Si necesitas forzar un nivel de razonamiento concreto, puedes usar:

| Método | Cómo |
|--------|------|
| Atajo de teclado | `Alt+T` (toggle) |
| Slash command interactivo | `/effort` (sin argumentos abre slider con flechas + Enter) |
| Slash command directo | `/effort high`, `/effort xhigh`, `/effort max` |
| Flag CLI | `--effort high`, `--effort xhigh`, `--effort max` |
| Keyword por turno | Incluir "ultrathink" en el prompt |

> **Novedad v2.1.111:** `/effort` sin argumentos abre un **slider interactivo**:
> navega con las flechas del teclado y confirma con Enter. Es útil cuando no recuerdas
> los nombres exactos de los niveles o quieres ver las opciones disponibles para tu modelo.

Extended thinking sigue siendo útil para:
- Debugging de problemas complejos
- Decisiones arquitectónicas
- Análisis de seguridad
- Lógica de negocio crítica

---

## Cuándo Usar Cada Modelo

| Modelo | Coste (in/out) | Contexto | Usar para | No usar para |
|--------|---------------|----------|-----------|-------------|
| **Haiku 4.5** | $1/$5 | 200K | Commit messages, formateo, tareas triviales | Cualquier cosa que requiera razonamiento |
| **Sonnet 4.6** | $3/$15 | 1M | Desarrollo diario, features, tests, refactoring | Decisiones arquitectónicas complejas |
| **Opus 4.6** | $5/$25 | 1M | Planificación, debug complejo, arquitectura (API/Bedrock/Vertex) | Tareas rutinarias |
| **Opus 4.7** | $5/$25 | 1M | Todo lo de Opus 4.6 + nivel `xhigh` (**planes Max de claude.ai**) | Tareas rutinarias |

> **Nota v3.0:** Opus 4.6 soporta hasta **128K tokens de salida**. Sonnet 4.6 alcanza **1M de contexto** con 64K tokens de salida.

### Árbol de Decisión

```
¿Es una tarea trivial (format, commit msg)?
  → Haiku

¿Requiere razonamiento profundo o multi-archivo complejo?
  → Opus

Todo lo demás (90% del trabajo diario)?
  → Sonnet
```

---

## El Alias opusplan

```bash
claude --model opusplan
```

**Comportamiento**:
- Cuando Claude planifica → usa Opus (mejor razonamiento)
- Cuando Claude ejecuta (editar, escribir, bash) → usa Sonnet (más barato)

**Ideal para**: Features grandes donde la planificación importa pero
la ejecución es mecánica.

### Coste opusplan vs alternativas

| Enfoque | Planificación | Ejecución | Coste típico feature |
|---------|--------------|-----------|---------------------|
| Todo Opus | Opus ($5/$25) | Opus ($5/$25) | $1-3 |
| Todo Sonnet | Sonnet ($3/$15) | Sonnet ($3/$15) | $0.50-1.50 |
| **opusplan** | Opus ($5/$25) | Sonnet ($3/$15) | **$0.60-1.50** |
| Haiku | Haiku ($1/$5) | Haiku ($1/$5) | $0.10-0.30 |

opusplan ofrece la **calidad de Opus en planificación** con el **coste de Sonnet en ejecución**.

---

## Cambiar de Modelo Dinámicamente

```bash
# En sesión interactiva
/model opus        # Para planificar
/model sonnet      # Para implementar
/model haiku       # Para tareas simples

# Por sesión
claude --model opus        # Toda la sesión con Opus
claude --model opusplan    # Híbrido
```

> **Aviso v2.1.108:** Al ejecutar `/model` para cambiar de modelo **durante una conversación activa**, Claude Code muestra una advertencia: el siguiente mensaje **releerá el historial completo** sin poder aprovechar el prompt cache acumulado. Esto puede aumentar significativamente el coste del siguiente turno si la conversación es larga.
>
> Estrategia para minimizar el coste: cambia de modelo al inicio de una nueva sesión (`/clear` + `/model`) en lugar de a mitad de conversación.

### Estrategia por Fase del Día

```
Mañana (planificación):
  claude --model opus
  > Shift+Tab
  > "Diseña las features del sprint"
  > /exit

Desarrollo (implementación):
  claude --model sonnet
  > "Implementa feature 1 según el plan"
  > [trabajar]
  > /exit

Final del día (cleanup):
  claude --model haiku
  > git diff | claude -p "Commit message"
```

---

## Opus vs Sonnet: Casos Reales

### Caso 1: Bug Multi-Archivo

**Sonnet**: Encuentra el bug en el archivo obvio, puede no ver la causa raíz
en otro archivo.

**Opus**: Razona sobre las dependencias entre archivos, encuentra la causa raíz
y propone el fix correcto.

**Veredicto**: Opus para bugs complejos, Sonnet para bugs obvios.

### Caso 2: Refactoring de Arquitectura

**Sonnet**: Puede refactorizar mecánicamente pero no siempre elige
la mejor arquitectura.

**Opus**: Evalúa alternativas, considera trade-offs, propone la arquitectura
más adecuada para el contexto.

**Veredicto**: Opus para planificar el refactoring, Sonnet para ejecutarlo.

### Caso 3: Generar Tests

**Sonnet**: Genera tests correctos que cubren los casos principales.

**Opus**: Genera tests + edge cases + tests de regresión + sugiere
mejorar el código para ser más testeable.

**Veredicto**: Sonnet es suficiente para tests normales. Opus si necesitas
cobertura exhaustiva.

---

## Resumen

```
90% del trabajo  → Sonnet ($3/$15)
Planificación    → Opus (4.6 en API, 4.7 en planes Max) o opusplan
Tareas triviales → Haiku ($1/$5)
Debug complejo   → Opus con effort high/xhigh/max o "ultrathink"
xhigh            → Solo Opus 4.7 (planes Max de claude.ai)
```

- El nivel `xhigh` está entre `high` y `max` en profundidad de razonamiento y es exclusivo de Opus 4.7
- Cambiar de modelo a mitad de conversación invalida el prompt cache: hazlo al inicio de sesión
- Desde v2.1.117, el default para planes Pro/Max es `high` (antes era `medium`)
