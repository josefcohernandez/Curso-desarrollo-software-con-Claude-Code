# 09 - `/goal` y Self-Hosted Runners: Cierre de Tareas Largas e Infraestructura Propia

## Objetivos de aprendizaje

Al completar esta sección, serás capaz de:

1. **Fijar condiciones de finalización** para una tarea larga con `/goal`, de forma que Claude siga trabajando a través de múltiples turnos sin que tengas que reformular el prompt en cada paso.
2. **Distinguir `/goal` de `/loop` y `CronCreate`**: cuándo usar cada mecanismo según si la tarea es de un único objetivo con fin claro o una tarea recurrente/periódica.
3. **Configurar el hook `post-session`** en un self-hosted runner para ejecutar tareas de limpieza o exportación antes de que se destruya el workspace efímero.
4. **Diseñar un flujo de cierre de sesión** en runners propios que preserve artefactos, logs o cambios sin commitear antes de perder el entorno.

---

## Parte 1: El comando `/goal`

### Qué resuelve

Hasta ahora, para que Claude completara una tarea larga sin supervisión turno a turno, había que apoyarse en `--max-turns`, en revisar manualmente cada paso, o en escribir un prompt inicial extremadamente detallado. `/goal` (v2.1.139) resuelve un problema distinto: fijar **una condición de finalización explícita** que se comprueba automáticamente después de cada turno, de modo que Claude continúa trabajando por su cuenta hasta que la condición se cumple, sin devolver el control al usuario en cada paso intermedio.

### Sintaxis

```text
/goal <condición de finalización en lenguaje natural>
```

### Cómo funciona internamente

Al final de cada turno, Claude Code envía la condición del goal junto con el estado actual de la conversación a un modelo rápido configurado (por defecto Haiku). Ese modelo evalúa si la condición se cumple y devuelve una decisión sí/no con una razón breve:

| Resultado del clasificador | Efecto |
|----------------------------|--------|
| "No" | Claude inicia otro turno automáticamente, usando la razón devuelta como guía adicional para el siguiente paso |
| "Sí" | El goal se limpia y se registra una entrada `achieved` en el transcript de la sesión |

Este bucle de verificación es lo que permite que `/goal` funcione de forma no supervisada durante minutos u horas, a diferencia de un prompt normal que se detiene cuando Claude considera que ha terminado su interpretación inicial de la tarea.

### Ejemplo de uso

```text
/goal Todos los tests de la suite de integración pasan y no quedan
advertencias de linting en el código modificado
```

Claude trabajará turno tras turno —corrigiendo tests, ajustando código, relanzando la suite— hasta que el clasificador confirme que la condición se cumple. Durante la ejecución, un panel de overlay muestra en tiempo real el tiempo transcurrido, el número de turnos y el consumo de tokens, lo que permite seguir el progreso sin intervenir.

### Dónde funciona

`/goal` está disponible en modo no interactivo (`-p`), en la app de escritorio y a través de Remote Control (ver [Módulo 13](../../modulo-13-multimodalidad-notebooks/teoria/05-voice-y-computer-use.md)), lo que lo hace útil tanto para sesiones locales largas como para tareas lanzadas desde el móvil o desde un pipeline.

### `/goal` frente a `/loop` y `CronCreate`

| Mecanismo | Patrón | Cuándo usarlo |
|-----------|--------|---------------|
| `/goal` | Condición de finalización única, verificada tras cada turno | Una tarea larga con un criterio de "terminado" claro (tests en verde, migración completa, refactor finalizado) |
| `/loop` | Ejecución periódica de un prompt cada N minutos | Monitorización continua sin condición de fin (vigilar logs, revisar PRs nuevas) |
| `CronCreate` | Tarea recurrente programada por cron | Tareas que deben repetirse indefinidamente en el tiempo, no una tarea con final |

Los tres mecanismos son complementarios: puedes combinar `/goal` dentro de una Routine (ver [06-routines-cloud.md](06-routines-cloud.md)) para que una automatización cloud persista hasta cumplir una condición, en lugar de ejecutar un único turno.

### Ejemplo práctico: migración de una API a un nuevo esquema de respuesta

```text
/goal Todos los endpoints de src/api/ devuelven el nuevo formato
{data, meta, errors} y la suite de tests de contrato (npm run test:contract)
pasa sin fallos
```

En este ejemplo, la tarea puede requerir tocar decenas de archivos, ajustar serializers y corregir tests rotos por el cambio de formato. En lugar de guiar a Claude paso a paso, `/goal` permite dejar la tarea en marcha y volver cuando el clasificador confirme que la condición se cumple.

### Errores comunes

| Error | Causa | Solución |
|-------|-------|---------|
| El goal nunca se marca como cumplido | La condición es ambigua o depende de un juicio subjetivo | Redacta la condición en términos verificables: comandos que pasan, ausencia de errores, valores concretos |
| El goal se marca como cumplido prematuramente | La condición es demasiado laxa | Añade criterios más específicos: "todos los tests" en vez de "los tests principales" |
| Consumo de tokens elevado | La tarea requiere muchos turnos para converger | Combina con `--max-budget-usd` para poner un tope de gasto aunque el goal no se haya cumplido |
| El goal se queda "colgado" repitiendo el mismo error | Claude no tiene suficiente contexto para corregir el problema | Interrumpe la sesión y añade contexto adicional (documentación, ejemplo del comportamiento esperado) antes de reanudar |

---

## Parte 2: Self-Hosted Runners y el hook `post-session`

### Contexto: runners propios frente a infraestructura cloud de Anthropic

Los servicios cloud vistos en este módulo (Routines, Code Review managed, Slack/web) ejecutan en la infraestructura de Anthropic. Para organizaciones que necesitan que la ejecución ocurra dentro de su propia red —por requisitos de compliance, acceso a servicios internos no expuestos a Internet, o auditoría de infraestructura— Claude Code soporta el patrón de **self-hosted runner**: un proceso que corre en máquinas propias (on-premise o en tu propia nube) y que reclama y ejecuta sesiones de Claude Code de forma similar a como un runner de GitHub Actions reclama jobs.

Cada sesión que ejecuta un self-hosted runner se realiza dentro de un **workspace efímero**: un directorio de trabajo aislado que se crea al empezar la sesión y se destruye al terminarla. Esto garantiza que las sesiones no comparten estado entre sí, pero también significa que cualquier artefacto que no se haya extraído explícitamente del workspace se pierde cuando este se borra.

### El hook `post-session` (v2.1.169)

El hook de ciclo de vida `post-session` se ejecuta **después de que la sesión termina y antes de que el workspace sea eliminado**. Es la última oportunidad de actuar sobre el contenido del workspace antes de que desaparezca.

```text
Sesión inicia
   |
Workspace efímero creado
   |
Claude Code ejecuta la tarea
   |
Sesión termina
   |
Hook post-session se ejecuta   <-- último acceso al workspace
   |
Workspace destruido
```

### Casos de uso típicos

| Caso de uso | Qué hace el hook |
|-------------|-------------------|
| Snapshot de cambios sin commitear | Ejecuta `git diff` y `git stash` para preservar trabajo no confirmado en un almacén externo antes de perder el workspace |
| Exportación de logs | Copia los logs de la sesión (comandos ejecutados, salidas, errores) a un sistema de almacenamiento persistente |
| Métricas de observabilidad | Envía duración, coste y resultado de la sesión al sistema de monitorización interno |
| Notificación de finalización | Publica un mensaje en Slack o crea un ticket si la sesión terminó con errores |

### Ejemplo de configuración

```json
{
  "hooks": {
    "postSession": [
      {
        "command": "/opt/claude-runner/scripts/post-session-cleanup.sh"
      }
    ]
  }
}
```

Script de ejemplo (`post-session-cleanup.sh`):

```bash
#!/bin/bash
# post-session-cleanup.sh
# Se ejecuta tras terminar la sesión, antes de destruir el workspace.

set -euo pipefail

SESSION_ID="${CLAUDE_SESSION_ID:-desconocido}"
WORKSPACE_DIR="${CLAUDE_WORKSPACE_DIR:-$(pwd)}"
ARCHIVE_BUCKET="s3://mi-empresa-claude-runners/sesiones"

cd "$WORKSPACE_DIR"

# 1. Preservar cambios sin commitear, si los hay
if ! git diff --quiet || ! git diff --cached --quiet; then
  git diff > "/tmp/${SESSION_ID}-uncommitted.patch"
  aws s3 cp "/tmp/${SESSION_ID}-uncommitted.patch" \
    "${ARCHIVE_BUCKET}/${SESSION_ID}/uncommitted.patch"
  echo "Cambios sin commitear preservados en ${ARCHIVE_BUCKET}/${SESSION_ID}/"
fi

# 2. Exportar logs de la sesión
if [ -f ".claude/session.log" ]; then
  aws s3 cp ".claude/session.log" "${ARCHIVE_BUCKET}/${SESSION_ID}/session.log"
fi

# 3. Reportar métricas
curl -s -X POST https://observabilidad.interna.empresa.com/eventos \
  -H "Content-Type: application/json" \
  -d "{\"session_id\": \"${SESSION_ID}\", \"evento\": \"post_session_cleanup\", \"estado\": \"completado\"}"

echo "Limpieza post-session completada para ${SESSION_ID}."
```

### Diferencia con los hooks del ciclo de vida estándar

El sistema general de hooks de Claude Code —cubierto en el [Módulo 08](../../modulo-08-hooks/README.md)— incluye eventos como `SessionStart` y `SessionEnd` que se disparan en cualquier tipo de sesión, local o en runner. `post-session` es un hook específico de la **infraestructura de self-hosted runner**: se ejecuta en el contexto del proceso runner (no dentro de la sesión de Claude Code en sí) y su propósito es exclusivamente gestionar el ciclo de vida del workspace efímero antes de su destrucción, algo que no aplica a una sesión interactiva local donde el directorio de trabajo persiste de forma natural.

| Aspecto | `SessionEnd` (M08) | `post-session` (self-hosted runner) |
|---------|--------------------|--------------------------------------|
| Contexto de ejecución | Dentro de cualquier sesión de Claude Code | Proceso del runner, tras finalizar la sesión |
| Disponibilidad | Todas las sesiones (local, CI, cloud) | Exclusivo de self-hosted runners |
| Acceso al workspace | El workspace puede seguir existiendo | Última oportunidad antes de la destrucción del workspace efímero |
| Caso de uso típico | Notificaciones, resumen de sesión | Preservación de artefactos, exportación de logs, limpieza de infraestructura |

### Errores comunes

| Error | Causa | Solución |
|-------|-------|---------|
| El hook `post-session` no se ejecuta | El runner no soporta hooks de ciclo de vida (versión antigua) | Verifica que el binario del runner es v2.1.169 o superior |
| Se pierden cambios sin commitear | No hay hook `post-session` configurado, o el script no cubre ese escenario | Añade el paso de `git diff` + exportación como en el ejemplo anterior |
| El script del hook tarda demasiado y bloquea la destrucción del workspace | Operaciones de red lentas (subida de artefactos grandes) sin timeout | Añade un timeout explícito al script y considera exportar solo lo esencial |
| Variables como `CLAUDE_SESSION_ID` no están definidas | El runner no las inyecta en versiones anteriores a la que soporta `post-session` | Actualiza el runner y verifica la documentación de variables de entorno disponibles en el contexto del hook |

---

## Resumen

- `/goal <condición>` (v2.1.139) fija una condición de finalización que Claude verifica automáticamente tras cada turno con un modelo clasificador rápido (Haiku por defecto), permitiendo que trabaje de forma autónoma en tareas largas sin reintervención constante.
- `/goal` es complementario a `/loop` (monitorización periódica sin fin) y `CronCreate` (tareas recurrentes): úsalo cuando la tarea tiene un criterio de "terminado" claro y verificable.
- Los **self-hosted runners** permiten ejecutar sesiones de Claude Code en infraestructura propia, dentro de workspaces efímeros que se destruyen al finalizar cada sesión.
- El hook `post-session` (v2.1.169) se ejecuta tras terminar la sesión y **antes** de que el workspace sea eliminado: es el punto de extensión correcto para preservar cambios sin commitear, exportar logs o reportar métricas.
- A diferencia de los hooks generales del ciclo de vida (Módulo 08), `post-session` es específico de la infraestructura de self-hosted runner y no aplica a sesiones locales o cloud estándar.

## Siguiente paso

Esto completa el bloque de automatización avanzada del Módulo 10. Continúa con el [Módulo 11: Enterprise y Seguridad](../../modulo-11-enterprise-seguridad/README.md) para profundizar en las políticas gestionadas y las restricciones organizacionales que complementan estos mecanismos de automatización en entornos empresariales.
