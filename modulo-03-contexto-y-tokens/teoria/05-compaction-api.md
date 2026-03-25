# 05 - Compaction API: Conversaciones Efectivamente Infinitas

> Tiempo estimado: 20 minutos | Nivel: Intermedio-Avanzado

## Objetivos de aprendizaje

Al terminar este fichero serás capaz de:

1. Explicar qué es la Compaction API y en qué se diferencia del comando `/compact`
2. Describir cómo funciona el proceso de compactación automática del lado del servidor
3. Configurar la Compaction API en tus proyectos y scripts
4. Utilizar el hook `PostCompact` para reaccionar a eventos de compactación
5. Evaluar cuándo usar compactación automática frente a gestión manual de contexto

---

## Qué es la Compaction API

La **Compaction API** es un mecanismo de compactación automática del lado del servidor (server-side) que entra en acción cuando la ventana de contexto se acerca a su límite. En lugar de forzar una intervención manual del usuario, el servidor resume los mensajes anteriores de forma transparente y continúa la sesión con ese resumen en lugar del historial completo.

El resultado práctico es que una sesión puede extenderse indefinidamente sin que el contexto se sature y sin que el desarrollador tenga que gestionar manualmente cuándo limpiar o compactar.

> La Compaction API es una funcionalidad en fase **beta** (a fecha del curso). Su comportamiento puede cambiar entre versiones de Claude Code. Consulta siempre la documentación oficial en https://docs.anthropic.com/en/docs/claude-code antes de depender de ella en producción.

---

## Diferencia con `/compact`: manual vs automático

Antes de la Compaction API, la única forma de liberar contexto sin perder la sesión era el comando `/compact`:

```
/compact "Mantener: decisiones de arquitectura, endpoints creados, tests pendientes"
```

Este comando es **manual** y **síncrono**: tú decides cuándo compactar, puedes añadir instrucciones sobre qué conservar, y la compactación ocurre en ese momento.

La Compaction API introduce un modo de operación diferente:

| Característica | `/compact` (manual) | Compaction API (automática) |
|----------------|--------------------|-----------------------------|
| Quién lo activa | El usuario | El servidor automáticamente |
| Cuándo ocurre | Cuando tú lo decides | Al acercarse al límite de contexto |
| Instrucciones personalizadas | Sí (texto libre) | No |
| Interrumpe el flujo | Sí (pausa explícita) | No (transparente) |
| Hook disponible | No | Sí (`PostCompact`) |
| Disponibilidad | Desde siempre | Beta (requiere configuración) |

En la sesión interactiva, `/compact` sigue siendo la herramienta de control manual. La Compaction API está orientada principalmente a **flujos agénticos** y pipelines donde un humano no está monitorizando la sesión en todo momento.

---

## Cómo funciona la Compaction API

### El proceso paso a paso

```
Sesión en curso
      │
      │  (el contexto crece con cada turno)
      │
      ▼
Contexto se acerca al límite (~95%)
      │
      ▼
El servidor detecta que no hay suficiente espacio
para continuar con seguridad
      │
      ▼
El servidor genera un resumen de los mensajes anteriores
(compact_summary)
      │
      ▼
El historial de mensajes se reemplaza internamente
por ese resumen
      │
      ▼
Se dispara el hook PostCompact
      │
      ▼
La sesión continúa con contexto liberado
```

### Qué contiene el resumen generado

El servidor intenta preservar en el resumen:

- El estado actual del trabajo en curso
- Los archivos modificados y las decisiones de código relevantes
- Los objetivos declarados de la tarea
- Los errores o problemas identificados aún sin resolver

Lo que puede perderse en el resumen:

- Instrucciones dadas con mucho detalle al principio de la sesión
- El razonamiento detrás de decisiones que no quedaron explícitas
- Matices de conversaciones largas con múltiples cambios de dirección
- El contexto de por qué se descartaron alternativas

---

## El hook PostCompact

Cuando la compactación automática ocurre, Claude Code dispara el hook `PostCompact`. Este hook te permite reaccionar al evento: por ejemplo, registrar que ocurrió, inyectar contexto crítico de vuelta, o notificar a un sistema externo.

### Estructura del evento PostCompact

El hook recibe por la entrada estándar (stdin) un objeto JSON con la siguiente estructura:

```json
{
  "hook_event_name": "PostCompact",
  "compact_summary": "Resumen generado automáticamente por el servidor. Contiene el estado del trabajo, archivos modificados y decisiones relevantes tomadas hasta este punto.",
  "session_id": "abc123def456"
}
```

El campo `compact_summary` contiene el texto del resumen que el servidor usará como nuevo contexto de partida. Puedes leer ese resumen en tu script para diagnosticar qué información se preservó.

### Configuración del hook en settings.json

Para registrar el hook `PostCompact`, añádelo a tu fichero `.claude/settings.json`:

```json
{
  "hooks": {
    "PostCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash /home/usuario/proyecto/.claude/hooks/post-compact.sh"
          }
        ]
      }
    ]
  }
}
```

### Ejemplo de script PostCompact

El siguiente script registra cada evento de compactación en un fichero de log y extrae el resumen para diagnóstico:

```bash
#!/usr/bin/env bash
# .claude/hooks/post-compact.sh
# Se ejecuta automáticamente tras cada compactación de contexto.

LOG_FILE="/tmp/claude-compactions.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Leer el evento JSON desde stdin
EVENT=$(cat)

# Extraer el resumen y el session_id
SUMMARY=$(echo "$EVENT" | jq -r '.compact_summary // "sin resumen disponible"')
SESSION=$(echo "$EVENT" | jq -r '.session_id // "desconocido"')

# Registrar el evento
echo "[$TIMESTAMP] Compactación en sesión $SESSION" >> "$LOG_FILE"
echo "Resumen: $SUMMARY" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"

# Mostrar aviso en la sesión (aparece como output del hook)
echo "Contexto compactado. Revisa $LOG_FILE si necesitas el resumen completo."
```

Para que el script sea ejecutable:

```bash
chmod +x .claude/hooks/post-compact.sh
```

---

## Activación y configuración

### Activar la Compaction API en modo headless

En modo headless (`-p`), la compactación automática se puede habilitar con el flag `--auto-compact`:

```bash
claude -p "Refactoriza el módulo completo de pagos y genera todos los tests" \
  --auto-compact
```

Con este flag activo, si la tarea supera el límite de contexto, el servidor compactará automáticamente en lugar de detenerse con un error.

### Nivel de compactación

Puedes controlar cuándo se dispara la compactación automática con el parámetro `--compaction-threshold`:

```bash
# Compactar cuando el contexto llegue al 80% (más conservador)
claude -p "Analiza todos los ficheros en src/ y detecta vulnerabilidades" \
  --auto-compact \
  --compaction-threshold 0.8
```

El valor por defecto es `0.95` (95% de capacidad). Bajarlo a `0.8` activa la compactación antes, lo que preserva más espacio de razonamiento pero genera resúmenes más frecuentes.

### Configuración en settings.json a nivel de proyecto

Para activar la compactación automática en todas las sesiones de un proyecto:

```json
{
  "autoCompact": true,
  "compactionThreshold": 0.85
}
```

Con esta configuración, tanto las sesiones interactivas como las headless del proyecto usarán compactación automática por defecto, sin necesidad de pasar el flag en cada invocación.

---

## Ejemplo práctico: sesión larga de refactoring

Imagina un escenario donde necesitas refactorizar un módulo grande con decenas de ficheros. Sin la Compaction API, tendrías que gestionar manualmente el contexto con `/compact` o dividir la tarea en varias sesiones. Con la Compaction API activada, la sesión puede continuar sin interrupciones:

```bash
# Iniciamos una tarea agéntica larga con compactación automática
claude -p "
Refactoriza el módulo src/payments/ completo:
1. Migra de callbacks a async/await en todos los ficheros
2. Añade tipos TypeScript estrictos
3. Genera tests unitarios para cada función pública
4. Actualiza la documentación JSDoc
Trabaja fichero por fichero hasta completar todo el módulo.
" \
  --auto-compact \
  --compaction-threshold 0.80 \
  --max-budget-usd 5.00
```

Durante esta tarea:

1. Claude procesa los primeros 10-15 ficheros normalmente
2. Al llegar al 80% de contexto, el servidor compacta automáticamente
3. El hook `PostCompact` registra el evento (si está configurado)
4. Claude continúa con los ficheros restantes usando el contexto liberado
5. El proceso puede repetirse varias veces sin intervención manual

El fichero de log resultante permite auditar cuántas compactaciones ocurrieron y qué información preservó el servidor en cada una.

---

## Relación con las estrategias de sesión

La Compaction API no reemplaza las estrategias descritas en el fichero anterior ([03-estrategias-sesion.md](03-estrategias-sesion.md)); las complementa.

La **estrategia atómica** (sesiones cortas de 5-20 minutos) sigue siendo la recomendación principal para trabajo interactivo cotidiano. No necesita compactación porque el contexto nunca llega a saturarse.

La **estrategia con checkpoints** usando `/compact` manual sigue siendo preferible cuando quieres control explícito sobre qué se preserva en el resumen.

La Compaction API aporta valor principalmente en dos escenarios:

| Escenario | Por qué usar Compaction API |
|-----------|----------------------------|
| Tareas agénticas largas sin supervisión | No hay humano disponible para hacer `/compact` manualmente |
| Pipelines de CI/CD con análisis extensos | El tamaño del código analizado es impredecible |
| Exploración de codebases muy grandes | Claude necesita leer decenas de ficheros antes de poder actuar |
| Investigación en proyectos legacy | El volumen de contexto necesario para entender el código supera lo manejable manualmente |

---

## Limitaciones actuales (beta)

La Compaction API es funcionalidad beta. Estas son las limitaciones conocidas a fecha del curso:

**El resumen puede perder detalles finos.** El servidor no conoce qué información consideras crítica. Si al inicio de una sesión larga dijiste "nunca uses snake_case en la API pública", esa instrucción puede desaparecer del resumen si se dijo muchos mensajes atrás.

**No hay instrucciones personalizadas.** A diferencia de `/compact "Mantener: X, Y, Z"`, la compactación automática no acepta instrucciones sobre qué preservar. El servidor decide algorítmicamente.

**El comportamiento puede cambiar.** Al ser beta, la lógica de qué se preserva y cuándo se activa puede variar entre versiones sin previo aviso. No dependas de comportamientos específicos del resumen en pipelines críticos de producción.

**Latencia añadida.** Cada compactación introduce una pausa mientras el servidor genera el resumen. En sesiones interactivas esto es perceptible.

**No disponible en todos los entornos.** Verifica que la versión de Claude Code que usas soporta el flag `--auto-compact` antes de incluirlo en scripts compartidos:

```bash
claude --version
claude --help | grep compact
```

---

## Puntos clave

- La Compaction API compacta el contexto **automáticamente** cuando se acerca al límite, sin intervención del usuario. Es la diferencia principal respecto al comando `/compact`, que es manual.

- El proceso ocurre en el **lado del servidor**: el historial de mensajes se reemplaza por un resumen generado por el modelo, y la sesión continúa.

- El hook **`PostCompact`** se dispara tras cada compactación automática. El campo `compact_summary` del evento JSON contiene el texto del resumen generado.

- Se activa con `--auto-compact` en modo headless o con `"autoCompact": true` en `settings.json`. El umbral de activación se controla con `--compaction-threshold` (valor entre 0 y 1, por defecto 0.95).

- Es especialmente útil en **tareas agénticas largas** donde no hay un humano supervisando para hacer `/compact` a tiempo.

- Las limitaciones de beta implican que el resumen puede perder detalles finos y que no admite instrucciones personalizadas sobre qué preservar. Para trabajo interactivo cotidiano, las estrategias manuales de [03-estrategias-sesion.md](03-estrategias-sesion.md) siguen siendo preferibles.

- Combinar `--auto-compact` con `--max-budget-usd` es una buena práctica en pipelines automatizados: la primera evita que la sesión muera por exceso de contexto, la segunda evita sorpresas de coste.

---

## Siguiente paso

Has completado la teoría del Módulo 03. Ahora pon en práctica lo aprendido con los ejercicios:

- [01-monitorizar-contexto.md](../ejercicios/01-monitorizar-contexto.md) — Aprende a monitorizar y gestionar el contexto en tiempo real
- [02-optimizar-sesion.md](../ejercicios/02-optimizar-sesion.md) — Optimiza una sesión larga de programación aplicando las estrategias del módulo
