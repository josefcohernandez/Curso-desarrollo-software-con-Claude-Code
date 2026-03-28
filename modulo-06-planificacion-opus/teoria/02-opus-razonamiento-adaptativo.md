# 02 - Opus 4.6 y Razonamiento Adaptativo

## Qué es Opus 4.6

Opus 4.6 es el modelo más capaz de Anthropic. Su característica principal
es el **razonamiento adaptativo**: ajusta automáticamente la profundidad
de su razonamiento según la complejidad de la tarea.

---

## Razonamiento Adaptativo

### 3 Niveles de Esfuerzo

| Nivel | Cuándo | Ejemplo |
|-------|--------|---------|
| **Bajo** | Tareas simples, respuestas directas | "¿Qué hace git status?" |
| **Medio** | Tareas con algo de complejidad | "Refactoriza esta función a async" |
| **Alto** | Problemas complejos, multi-archivo | "Diseña sistema de permisos RBAC" |

Opus decide automáticamente cuánto "pensar" basándose en la complejidad.

### Adaptive Thinking (reemplaza Extended Thinking)

> **Cambio v3.0:** En Opus 4.6, **adaptive thinking** es el nuevo comportamiento por defecto: el modelo decide automáticamente cuándo y cuánto razonar. Los parámetros `thinking: {type: "enabled"}` y `budget_tokens` siguen siendo funcionales pero ya no son necesarios. Para revertir al comportamiento anterior, configura `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.

Con adaptive thinking, no necesitas activar ni desactivar el razonamiento profundo manualmente. Opus ajusta dinámicamente la profundidad de su razonamiento basándose en la complejidad detectada.

Si necesitas forzar razonamiento extendido, puedes usar:

| Método | Cómo |
|--------|------|
| Atajo | `Alt+T` (toggle) |
| Slash command | `/effort max` (nuevo nivel máximo para Opus) |

Extended thinking sigue siendo útil para:
- Debugging de problemas complejos
- Decisiones arquitectónicas
- Análisis de seguridad
- Lógica de negocio crítica

---

## Cuándo Usar Cada Modelo

| Modelo | Coste (in/out) | Usar para | No usar para |
|--------|---------------|-----------|-------------|
| **Haiku 4.5** | $1/$5 | Commit messages, formateo, tareas triviales | Cualquier cosa que requiera razonamiento |
| **Sonnet 4.6** | $3/$15 | Desarrollo diario, features, tests, refactoring | Decisiones arquitectónicas complejas |
| **Opus 4.6** | $5/$25 | Planificación, debug complejo, arquitectura | Tareas rutinarias (~1.7x más caro que Sonnet) |

> **Nota v3.0:** Opus 4.6 ahora soporta hasta **128K tokens de salida** (duplicado desde 64K). Sonnet 4.6 alcanza **1M de contexto** en beta con 64K tokens de salida.

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
90% del trabajo → Sonnet ($3/$15)
Planificación   → Opus o opusplan
Tareas triviales → Haiku ($1/$5)
Debug complejo  → Opus con Extended Thinking
```
