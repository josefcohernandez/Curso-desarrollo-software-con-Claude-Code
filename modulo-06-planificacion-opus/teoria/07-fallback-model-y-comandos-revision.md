# 07 - Fallback Models, Selección de Modelo y Evolución de `/code-review`

## Objetivos de aprendizaje

Al terminar esta sección sabrás:
- Configurar `fallbackModel` con hasta 3 modelos de respaldo en orden de prioridad
- Entender la diferencia entre fijar un modelo como nuevo **default** y cambiarlo **solo para la sesión actual** con `/model`
- Reconocer el aviso de Claude Code cuando el modelo solicitado está deprecado o se auto-actualiza
- Saber qué son los modelos por defecto organizacionales y dónde se configuran
- Desactivar el thinking por completo cuando no lo necesitas
- Seguir la evolución de `/simplify` → `/code-review`, y su relación con `/review` y `/ultrareview`

---

## `fallbackModel`: hasta 3 modelos de respaldo en orden

El fichero de settings del proyecto admite `fallbackModel` como un único modelo (como se vio en el capítulo anterior) o, desde v2.1.152, como una **lista ordenada de hasta 3 modelos**. Claude Code los prueba en orden hasta encontrar uno disponible:

```json
{
  "model": "claude-opus-4-8",
  "fallbackModel": [
    "claude-sonnet-5",
    "claude-opus-4-7",
    "claude-sonnet-4-6"
  ]
}
```

En este ejemplo, si `claude-opus-4-8` no responde o no está disponible, Claude Code prueba primero `claude-sonnet-5`; si tampoco está disponible, prueba `claude-opus-4-7`; y como último recurso, `claude-sonnet-4-6`.

### `--fallback-model` ahora también en sesiones interactivas

> **Novedad v2.1.166:** hasta esta versión, `--fallback-model` solo tenía efecto en modo no interactivo (`claude -p`) y en pipelines de CI/CD. Desde v2.1.166, **también se aplica a sesiones interactivas**: si el modelo principal falla a mitad de una sesión en el terminal, Claude Code cambia automáticamente al fallback sin que tengas que reiniciar la sesión.

```bash
# Ahora también funciona en una sesión interactiva normal
claude --model claude-opus-4-8 --fallback-model claude-sonnet-5
```

### Cambio automático permanente cuando el modelo principal no existe

> **Novedad v2.1.152:** si el modelo principal configurado deja de existir (por ejemplo, porque se ha deprecado su identificador), Claude Code cambia automáticamente al `--fallback-model` configurado **para el resto de la sesión**, en lugar de fallar en cada turno o pedirte que reintentes manualmente.

Esto es especialmente relevante en scripts y pipelines de larga duración: si fijaste un `model` que meses después queda deprecado, la sesión sigue funcionando con el fallback en vez de romperse.

---

## `/model`: guardar como default frente a aplicar solo a la sesión

El comportamiento de `/model` ha cambiado dos veces. Es importante conocer el comportamiento **actual** (post v2.1.153), que es el correcto:

| Momento | Comportamiento de `/model` |
|---------|----------------------------|
| Antes de v2.1.153 | `/model <nombre>` cambiaba el modelo **solo para la sesión actual**. Pulsar la tecla `d` lo fijaba como nuevo modelo por defecto |
| **Desde v2.1.153 (actual)** | `/model <nombre>` **guarda el cambio como nuevo modelo por defecto** para futuras sesiones. Pulsar la tecla `s` aplica el cambio **solo a la sesión actual**, sin tocar tu configuración por defecto |

En otras palabras: el comportamiento se invirtió. Antes el default era "solo esta sesión" y había que confirmar explícitamente para fijarlo como default. Ahora el default es "fijar como nuevo default" y hay que confirmar explícitamente (`s`) para limitarlo a la sesión actual.

```bash
# Ejemplo: quieres probar Fable 5 solo en esta sesión, sin cambiar tu default
/model claude-fable-5
# Claude Code pregunta: ¿Aplicar como nuevo modelo por defecto o solo para esta sesión?
# Pulsa 's' → se usa Fable 5 solo en esta sesión; tu modelo por defecto no cambia

# Ejemplo: quieres adoptar Sonnet 5 como tu modelo habitual
/model claude-sonnet-5
# No pulses 's': el cambio queda guardado como nuevo default
```

> **Importante para quien venga de versiones anteriores del curso:** si recuerdas que `/model` solo afectaba a la sesión actual y que había que pulsar `d` para fijar el default, ese comportamiento quedó obsoleto en v2.1.153. Verifica siempre tu configuración con `/status` si no estás seguro de qué modelo tienes fijado como default.

---

## Aviso de modelo deprecado o auto-actualizado

> **Novedad v2.1.183:** cuando solicitas un modelo (por `--model`, `/model` o en `settings.json`) cuyo identificador está **deprecado**, Claude Code muestra un aviso explícito antes de continuar. Según el caso, la sesión se auto-actualiza al sucesor recomendado o te pide confirmación.

```text
⚠ El modelo "claude-opus-4-6" está deprecado y será retirado el 15 de septiembre de 2026.
  Claude Code continuará esta sesión con "claude-opus-4-8" (sucesor recomendado).
  Para fijar la versión anterior de forma explícita, usa --model claude-opus-4-6 --no-auto-upgrade.
```

Este aviso evita el escenario silencioso de un pipeline que deja de funcionar de un día para otro porque el modelo que tenía fijado fue retirado sin que nadie se diera cuenta.

---

## Modelos por defecto organizacionales

> **Novedad v2.1.196:** los administradores de un plan Team/Enterprise pueden configurar **modelos por defecto a nivel de organización o de rol** desde la consola de administración, sin que cada desarrollador tenga que configurarlo individualmente.

Cuando existe un default organizacional o de rol, `/model` muestra una etiqueta junto a la opción correspondiente:

```text
/model
  claude-opus-4-8        (Org default)
  claude-sonnet-5         Role default
  claude-fable-5
  claude-haiku-4-5-20251001
```

Esto permite, por ejemplo, que el equipo de plataforma fije Sonnet 5 como default para todo el departamento de ingeniería, mientras el equipo de seguridad tiene Opus 4.8 como default de rol para sus revisiones. El detalle completo de la configuración de modelos a nivel de organización se cubre en el [Módulo 11 - Enterprise y Seguridad](../../modulo-11-enterprise-seguridad/teoria/02-enterprise.md).

---

## Desactivar el thinking: `MAX_THINKING_TOKENS=0` / `--thinking disabled`

> **Novedad v2.1.166:** para los modelos que piensan por defecto al usarse vía API (a diferencia del comportamiento adaptativo de Claude Code en CLI), puedes desactivar el thinking por completo con la variable de entorno `MAX_THINKING_TOKENS=0` o el flag `--thinking disabled`.

```bash
# Vía variable de entorno
export MAX_THINKING_TOKENS=0
claude --model claude-opus-4-8

# Vía flag directo
claude --thinking disabled
```

Esto es distinto de bajar el `effort level` a `low`: el effort level reduce la profundidad del razonamiento, mientras que `--thinking disabled` lo elimina por completo. Resérvalo para integraciones donde el thinking añade latencia sin aportar valor (por ejemplo, llamadas de API muy simples y de alto volumen).

---

## La evolución de los comandos de revisión: de `/simplify` a `/code-review`

Los comandos de revisión de código han cambiado varias veces. Esta tabla resume la línea temporal completa:

| Versión | Cambio |
|---------|--------|
| (histórico) | `/simplify` existía como comando para simplificar el código seleccionado |
| **v2.1.147** | `/simplify` se **renombra a `/code-review`** y añade selección de nivel de esfuerzo (`low`/`medium`/`high`/`xhigh`) |
| **v2.1.152** | `/code-review` añade el flag `--fix`, que aplica automáticamente las correcciones sugeridas en lugar de solo reportarlas |
| **v2.1.154** | `/code-review` empieza a incorporar capacidades de revisión **multi-agente en la nube**, la misma tecnología que ya usaba `/ultrareview` (ver [06-ultrareview-revision-multiagente.md](06-ultrareview-revision-multiagente.md), introducido en v2.1.111) |
| **v2.1.202** | Se consolidan **dos comandos distintos y complementarios**: `/review <pr>` vuelve a ser una revisión rápida de un solo paso (un único agente, ideal para cambios pequeños), y `/code-review <level> <pr#>` es la versión completa **multi-agente** con nivel de esfuerzo configurable |

### Uso actual (post v2.1.202)

```bash
# Revisión rápida de un solo paso — para cambios pequeños
/review 42

# Revisión multi-agente completa, con nivel de esfuerzo y número de PR
/code-review high 42
/code-review xhigh 42 --fix   # aplica las correcciones automáticamente

# /ultrareview se mantiene como alias de compatibilidad
/ultrareview 42
```

### Cómo elegir entre `/review`, `/code-review` y `/ultrareview`

| Situación | Comando recomendado |
|-----------|---------------------|
| Cambio pequeño (<50 líneas), quieres una pasada rápida | `/review <pr>` |
| Feature con lógica compleja, seguridad o múltiples módulos | `/code-review <level> <pr#>` |
| Quieres que Claude aplique las correcciones automáticamente | `/code-review <level> <pr#> --fix` |
| Vienes de una versión anterior del curso y usas `/ultrareview` en scripts existentes | Sigue funcionando como alias, pero migra a `/code-review` para nuevas integraciones |

### Deprecación relacionada: `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE`

Esta variable de entorno, usada para forzar el comportamiento de Fast Mode en Opus 4.6, fue **deprecada en v2.1.154** (coincidiendo con el cambio de pricing de Fast Mode a Opus 4.8, ver [04-fast-mode-y-modelos.md](04-fast-mode-y-modelos.md)) y **eliminada en v2.1.160**. Si tienes scripts o CI/CD que todavía la referencian, elimínala: ya no tiene efecto.

---

## Ejemplos prácticos

### Settings de proyecto con fallback multinivel y modelo por defecto explícito

```json
{
  "model": "claude-opus-4-8",
  "fallbackModel": [
    "claude-sonnet-5",
    "claude-haiku-4-5-20251001"
  ]
}
```

### Pipeline de CI/CD resiliente a deprecaciones de modelo

```bash
#!/usr/bin/env bash
# scripts/code-review-ci.sh
set -euo pipefail

claude \
  --model claude-opus-4-8 \
  --fallback-model claude-sonnet-5,claude-opus-4-7 \
  --thinking disabled \
  -p "Resume los cambios de este PR en 3 líneas"

# Revisión completa multi-agente antes de mergear a main
claude code-review high "${PR_NUMBER}" --json > code-review-output.json
```

### Cambiar de modelo solo para una tarea puntual sin tocar el default

```text
> /model claude-opus-4-8
> [Claude Code pregunta: default o solo esta sesión?]
> Pulsa 's'
> "Analiza la arquitectura de este módulo con el máximo nivel de detalle"
> [al terminar la sesión, tu modelo por defecto sigue siendo el que tenías antes]
```

---

## Errores comunes

**Asumir que `/model` solo afecta a la sesión actual**: desde v2.1.153 esto ya no es así por defecto. Si no quieres cambiar tu modelo habitual, recuerda pulsar `s` explícitamente.

**Confundir `/code-review` con `/review`**: `/review <pr>` es una revisión rápida de un solo agente; `/code-review <level> <pr#>` es la versión multi-agente completa. Usar `/code-review` para cambios triviales desperdicia tiempo y tokens.

**No configurar varios niveles de `fallbackModel`**: un único fallback puede no estar disponible en el mismo incidente de saturación que afecta al modelo principal. Configura una cadena de 2-3 modelos para pipelines críticos.

**Ignorar el aviso de modelo deprecado**: si ves el aviso de deprecación y no actualizas tu configuración, dependes de que la auto-actualización elija el sucesor correcto para tu caso de uso. Es mejor fijar explícitamente el modelo que quieres usar.

**No revisar si tu organización tiene un modelo por defecto**: si tu equipo trabaja en un plan Team/Enterprise, comprueba con `/model` si hay un "Org default" o "Role default" configurado antes de asumir que tu configuración local es la que se está usando.

---

## Resumen

- `fallbackModel` admite hasta **3 modelos de respaldo en orden** (v2.1.152); `--fallback-model` funciona ahora también en **sesiones interactivas** (v2.1.166)
- Si el modelo principal no existe, Claude Code cambia automáticamente al fallback **para el resto de la sesión** (v2.1.152)
- Desde v2.1.153, `/model` **guarda el cambio como nuevo modelo por defecto**; pulsa `s` para aplicarlo solo a la sesión actual
- Claude Code avisa cuando el modelo solicitado está **deprecado o se auto-actualiza** (v2.1.183)
- Los administradores pueden fijar **modelos por defecto organizacionales o de rol** (v2.1.196); ver [Módulo 11](../../modulo-11-enterprise-seguridad/teoria/02-enterprise.md)
- `MAX_THINKING_TOKENS=0` / `--thinking disabled` desactivan el thinking por completo vía API (v2.1.166)
- `/simplify` se renombró a `/code-review` (v2.1.147), ganó `--fix` (v2.1.152) y capacidades multi-agente (v2.1.154); desde v2.1.202, `/review <pr>` es la revisión rápida de un paso y `/code-review <level> <pr#>` es la versión multi-agente
- `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` quedó deprecada en v2.1.154 y se eliminó en v2.1.160

---

## Siguiente paso

Continúa con los ejercicios prácticos del módulo: [01 - Plan Mode en la práctica](../ejercicios/01-plan-mode-practica.md)
