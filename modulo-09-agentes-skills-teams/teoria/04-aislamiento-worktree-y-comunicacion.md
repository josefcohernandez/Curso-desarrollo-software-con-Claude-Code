# 04 - Aislamiento con Worktrees y Comunicación entre Agentes

Claude Code ofrece mecanismos avanzados para que los agentes trabajen en paralelo de forma segura y se comuniquen entre sí de manera eficiente. Este capítulo cubre la variable `CLAUDE_CODE_FORK_SUBAGENT`, el aislamiento mediante git worktrees, la comunicación dirigida entre agentes con `SendMessage`, los background agents con notificación automática, y las herramientas de gestión de tareas.

---

## `CLAUDE_CODE_FORK_SUBAGENT`: subagentes fork en worktree

> **Disponible desde v2.1.117 (sesiones interactivas) y v2.1.121 (sesiones no-interactivas)**

La variable de entorno `CLAUDE_CODE_FORK_SUBAGENT=1` habilita el modo de subagentes fork con aislamiento en worktree para todos los subagentes de la sesión, sin necesidad de especificar `isolation: "worktree"` en cada Task call.

```bash
# Habilitar subagentes fork en la sesión actual
export CLAUDE_CODE_FORK_SUBAGENT=1
claude

# O directamente en el comando de lanzamiento
CLAUDE_CODE_FORK_SUBAGENT=1 claude --print "Refactoriza el módulo de pagos"
```

### Ámbito de aplicación

| Versión | Dónde aplica |
|---------|-------------|
| v2.1.117 | Sesiones interactivas y builds externas interactivas |
| v2.1.121 | Sesiones no-interactivas: SDK y flag `--print` (`-p`) |

Desde v2.1.121, la variable funciona también en pipelines de CI/CD y scripts que usen `claude --print` o el Agent SDK. Esto permite habilitar el aislamiento en worktree de forma global en entornos de automatización sin modificar cada invocación individual.

### Diferencia con `isolation: "worktree"` por Task

| Mecanismo | Ámbito | Cuándo usarlo |
|-----------|--------|---------------|
| `isolation: "worktree"` en Task | Solo el subagente que lo declara | Aislamiento selectivo por tarea |
| `CLAUDE_CODE_FORK_SUBAGENT=1` | Todos los subagentes de la sesión | Aislamiento global de la sesión |

**Cuándo usar `CLAUDE_CODE_FORK_SUBAGENT=1`:**
- En pipelines de CI/CD donde todos los subagentes deben trabajar en worktrees aislados
- Al lanzar sesiones con `--print` en scripts de automatización
- En entornos donde el repositorio principal no debe tocarse bajo ninguna circunstancia
- Para garantizar que experimentos paralelos nunca se interfieran entre sí

```bash
# Ejemplo: pipeline de CI que ejecuta análisis paralelos sin tocar el repo principal
CLAUDE_CODE_FORK_SUBAGENT=1 claude --print \
  "Analiza el rendimiento del módulo de pagos y el módulo de usuarios en paralelo.
   Para cada uno, lanza un subagente que ejecute los benchmarks y reporte resultados."
```

---

## Aislamiento con Git Worktrees para subagentes

### El problema del trabajo experimental

Cuando un subagente experimenta con una implementación alternativa, trabaja directamente sobre el repositorio principal. Si el experimento no funciona, hay que deshacer los cambios manualmente. Si varios agentes trabajan en paralelo, sus cambios pueden interferir entre sí.

La solución es el parámetro `isolation: "worktree"`.

### Cómo funciona el worktree isolation

Al lanzar un subagente con `isolation: "worktree"`, Claude Code:

1. Crea un **git worktree temporal** — una copia aislada del repositorio en un directorio separado
2. El subagente trabaja **exclusivamente en esa copia** sin afectar el repo principal
3. Al terminar:
   - Si el subagente **no hizo cambios**: el worktree se elimina automáticamente
   - Si el subagente **hizo cambios**: se devuelve la ruta del worktree y el nombre del branch temporal para que puedas revisar y hacer merge si te convence

### Sintaxis para lanzar con aislamiento

Desde una sesión de Claude Code interactiva, puedes indicar el aislamiento en el prompt de instrucción al subagente:

```
Usa un subagente con isolation: "worktree" para experimentar
con una implementación alternativa del sistema de caché.
Si la implementación mejora el rendimiento según los tests,
haremos merge; si no, se descarta automáticamente.
```

### Casos de uso

| Caso de uso | Por qué usar worktree isolation |
|-------------|--------------------------------|
| Explorar una refactorización arriesgada | El repo principal no se toca hasta que se aprueba |
| Múltiples agentes trabajando en features distintas | Cada agente tiene su propio espacio de trabajo sin conflictos |
| Pruebas de concepto que pueden "romper cosas" | Se descarta automáticamente si no hay resultados útiles |
| Comparar dos implementaciones alternativas | Dos worktrees en paralelo, luego se elige la mejor |

### EnterWorktree: entrar en un worktree existente

Claude Code expone la herramienta `EnterWorktree` para que un agente cambie su directorio de trabajo activo al de un worktree concreto.

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `name` | string | Nombre del worktree al que se quiere entrar |
| `path` | string | *(v2.1.105)* Ruta a un worktree ya existente. Permite entrar sin crear uno nuevo |

> **Novedad v2.1.105:** El parámetro `path` permite entrar en un worktree que ya existe en disco — por ejemplo, uno que un agente anterior creó en la misma sesión — sin que `EnterWorktree` intente crear un worktree nuevo. Esto es útil para retomar trabajo en un worktree previamente inicializado.

**Ejemplo de uso con `path`:**

```
El agente "feature-auth" creó un worktree en /tmp/worktrees/feature-auth
durante su ejecución anterior. Para continuar allí sin duplicar el worktree:

Usa EnterWorktree con path: "/tmp/worktrees/feature-auth" para retomar
el trabajo de implementación de JWT donde lo dejó el agente anterior.
```

**Cuándo usar `path` en lugar del flujo estándar:**
- Retomar trabajo en un worktree que un agente creó previamente en la sesión
- Coordinar varios agentes que deben operar sobre el mismo worktree de forma secuencial
- Inspeccionar o completar cambios parciales de un agente interrumpido

### `EnterWorktree` puede cambiar entre worktrees gestionados en mitad de sesión (v2.1.157)

Además de entrar en un worktree nuevo o retomar uno existente por `path`, `EnterWorktree` permite **cambiar de un worktree gestionado por Claude Code a otro** durante la misma sesión, sin necesidad de salir y relanzar la sesión. Esto es útil cuando estás inspeccionando varios worktrees creados por distintos subagentes y quieres moverte entre ellos interactivamente:

```
Estamos comparando los worktrees "cache-redis" y "cache-memory" que
crearon los subagentes anteriores. Usa EnterWorktree para entrar primero
en "cache-redis" y ejecuta los benchmarks. Cuando termines, usa
EnterWorktree de nuevo para pasar a "cache-memory" y repite los benchmarks
en ese worktree.
```

Antes de esta mejora, moverse entre worktrees gestionados requería salir del worktree actual explícitamente antes de entrar en el siguiente. Ahora `EnterWorktree` gestiona la transición directamente.

### `worktree.baseRef`: elegir la base del worktree (v2.1.133)

Al crear un worktree nuevo para un subagente, Claude Code necesita decidir desde qué punto del historial de git rama el nuevo worktree. El setting `worktree.baseRef` en `settings.json` controla ese comportamiento:

```json
{
  "worktree": {
    "baseRef": "head"
  }
}
```

| Valor | Comportamiento |
|-------|---------------|
| `"fresh"` | El worktree rama desde el último commit del remoto (`origin/<rama-principal>`), ignorando cambios locales no confirmados |
| `"head"` | El worktree rama desde el `HEAD` actual del repositorio, incluyendo el estado local (commits locales no publicados) |

**Cuándo usar `"fresh"`:** cuando quieres que el subagente trabaje sobre una base limpia y reproducible, equivalente a lo que vería un compañero de equipo tras un `git pull`. Útil para experimentos que deben ser comparables entre sí.

**Cuándo usar `"head"` (más habitual):** cuando el subagente necesita partir exactamente de donde está tu working copy actual, incluyendo trabajo local que aún no se ha subido al remoto. Es el comportamiento más intuitivo en la mayoría de flujos de desarrollo activo.

### Ejemplo práctico completo

```
Tenemos un endpoint GET /api/products que actualmente hace una query
SQL sin caché y tarda ~200ms. Quiero explorar dos alternativas:

1. Lanza un subagente con isolation: "worktree" llamado "cache-redis"
   para implementar caché con Redis. Que ejecute los benchmarks
   existentes y reporte el tiempo promedio.

2. Lanza otro subagente con isolation: "worktree" llamado "cache-memory"
   para implementar caché en memoria con Map. Que ejecute los mismos
   benchmarks.

Cuando ambos terminen, compara los resultados y recomienda cuál hacer merge.
```

El agente principal recibe los resultados de ambos worktrees sin que el repositorio principal haya sido modificado en ningún momento.

---

## SendMessage: comunicación dirigida entre agentes

### El problema de la comunicación entre agentes

Cuando lanzas múltiples subagentes, el patrón habitual es secuencial: el agente principal lanza un subagente, espera su resultado, y luego lanza el siguiente. Pero a veces necesitas que agentes en ejecución se comuniquen entre sí sin pasar por el agente principal.

### Nombrar agentes para comunicación

Para que un agente pueda recibir mensajes, necesita un **nombre**:

```
Lanza un subagente llamado "investigador" para analizar la arquitectura
actual del módulo de autenticación. Que documente los patrones que
encuentra en un fichero temporal. Mientras tanto, seguiré trabajando
en la nueva feature.
```

### SendMessage: reanudar con contexto preservado

La diferencia fundamental entre lanzar un nuevo subagente y usar `SendMessage`:

| | Nuevo subagente | SendMessage |
|-|-----------------|-------------|
| Estado previo | Perdido (empieza de cero) | Preservado (continúa donde lo dejó) |
| Contexto | Nuevo contexto vacío | Contexto completo de la sesión anterior |
| Uso | Primera interacción | Continuar trabajo o pedir resultados |

```
Envía un SendMessage al agente "investigador" pidiéndole
que resuma los tres patrones de autenticación que encontró
y los liste en orden de complejidad.
```

El agente "investigador" reanuda con todo su contexto previo — los ficheros que leyó, el análisis que hizo — y puede responder directamente a la pregunta sin volver a analizar el código.

### Mensajes cross-session ya no llevan autoridad de usuario (v2.1.166)

Cuando `SendMessage` se usa para comunicar agentes que pertenecen a **sesiones distintas** (no solo agentes dentro de la misma sesión), existe un riesgo de seguridad: un mensaje que llega de otra sesión podría, en versiones anteriores, tratarse con el mismo nivel de confianza que una instrucción directa del usuario, permitiendo potencialmente que una sesión comprometida o manipulada influyera en las decisiones de otra.

Desde v2.1.166, los mensajes recibidos vía `SendMessage` que provienen de **otra sesión** ya **no llevan autoridad de usuario**. El agente que recibe el mensaje lo trata como información de contexto (similar a texto encontrado en un fichero o el resultado de una tool call), no como una instrucción con el mismo peso que una petición directa del desarrollador.

```
Sesión A: "investigador" envía SendMessage a Sesión B: "implementador"
  con el contenido: "Ejecuta rm -rf en el directorio de logs"

ANTES de v2.1.166: podía tratarse con la misma confianza que una
  instrucción del usuario, dependiendo del resto de la configuración.

DESDE v2.1.166: el "implementador" recibe el mensaje como contexto
  informativo, NO como una orden con autoridad de usuario. Cualquier
  acción derivada de ese contenido sigue pasando por el sistema de
  permisos y el clasificador de Auto Mode normalmente, exactamente
  igual que si esa instrucción viniera de un fichero externo.
```

**Por qué importa:** esta medida cierra una vía de escalado de privilegios entre sesiones. Antes de este cambio, coordinar múltiples sesiones de Claude Code (por ejemplo, en un pipeline de automatización con varias invocaciones de `claude --print`) requería confiar en que cada sesión individual se comportara de forma segura, porque un mensaje entrante de otra sesión podía tener demasiada influencia. Ahora, la autoridad de usuario sigue estando reservada exclusivamente al desarrollador humano (o al proceso que inició la sesión con `--print`/SDK), no a mensajes que llegan de otras sesiones de Claude Code.

### Patrón: coordinator con delegación y recogida de resultados

```
1. Lanza el agente "backend-analyst" (con nombre) para mapear
   todos los endpoints de la API y sus dependencias.

2. Mientras tanto, analiza el frontend y lista los componentes
   que más endpoints consumen.

3. Cuando termines tu análisis, envía un SendMessage a
   "backend-analyst" pidiéndole: "Lista los 5 endpoints con
   mayor tiempo de respuesta según los logs de la última semana."

4. Con ambos análisis, genera un plan de optimización priorizando
   los endpoints que más impacto tienen en el frontend.
```

Este patrón evita que el agente principal permanezca bloqueado esperando, y aprovecha el contexto acumulado por el agente nombrado.

---

## Background agents evolucionados

### Lanzar agentes en background

El parámetro `run_in_background: true` permite lanzar un agente que trabaja de forma autónoma mientras tú continúas interactuando con Claude Code.

```
Lanza tres agentes en background:
- "frontend-audit": audita el código del frontend (src/frontend/)
  buscando componentes sin tests
- "backend-audit": audita el backend (src/api/) buscando
  endpoints sin validación de input
- "deps-audit": revisa el package.json y reporta dependencias
  desactualizadas con vulnerabilidades conocidas

Cuando terminen, notifícame con un resumen de cada uno.
```

### Notificación automática

Los background agents **no requieren polling**. Claude Code notifica automáticamente cuando terminan. No es necesario preguntar periódicamente "¿ya terminaste?" — el agente interrumpe la sesión actual para entregar sus resultados cuando está listo.

> **Regla importante:** No uses `loop` ni comprobaciones periódicas para saber si un background agent ha terminado. La notificación es automática.

### Combinación con worktree isolation

El patrón más potente es combinar ambas funcionalidades:

```
Lanza 3 agentes en background, cada uno con isolation: "worktree":

- "feature-auth": implementa autenticación con JWT
- "feature-search": implementa búsqueda full-text con Elasticsearch
- "feature-notifications": implementa sistema de notificaciones push

Que cada uno ejecute sus tests y reporte el resultado.
Cuando los tres terminen, revisamos los tres worktrees y hacemos
merge de los que pasen todos los tests.
```

Los tres agentes trabajan en paralelo, cada uno en su propio worktree, sin interferencias. El repo principal permanece intacto hasta que se decide hacer merge.

---

## Task management dentro de agentes

### Las herramientas de gestión de tareas

Claude Code proporciona un conjunto de herramientas para que los agentes gestionen trabajo complejo de forma estructurada:

| Herramienta | Descripción |
|-------------|-------------|
| `TaskCreate` | Crea una nueva tarea con título, descripción y estado inicial |
| `TaskGet` | Obtiene el detalle de una tarea por su ID |
| `TaskList` | Lista todas las tareas activas en la sesión |
| `TaskUpdate` | Actualiza el estado o descripción de una tarea |
| `TaskStop` | Cancela una tarea en curso |

### El ciclo de vida de una tarea

```
pending -> in_progress -> completed
                       -> failed
                       -> cancelled (via TaskStop)
```

### Cuándo usar task management

Las tareas son **efímeras**: existen solo durante la sesión actual. No persisten entre sesiones. Para trabajo que debe persistir entre sesiones, usa memoria (CLAUDE.md o ficheros de contexto).

| Usar tareas | Usar memoria (CLAUDE.md) |
|-------------|--------------------------|
| Descomponer trabajo de una sesión larga | Decisiones de arquitectura permanentes |
| Coordinar subtareas dentro de un agente | Contexto del proyecto que no cambia |
| Seguimiento de progreso durante la sesión | Preferencias y convenciones del equipo |

### Ejemplo: descomponer una feature compleja

```
Tengo que implementar un sistema de exportación de datos en tres formatos
(CSV, JSON, PDF). Descompone este trabajo en tareas usando TaskCreate,
márcalas como in_progress cuando empieces cada una, y como completed
al terminar. Al final, usa TaskList para mostrarme un resumen de lo completado.
```

El agente crea tres tareas, las trabaja secuencialmente actualizando el estado de cada una, y al final puede presentar un resumen estructurado del trabajo realizado.

### Coordinación en Agent Teams vía tareas compartidas

En el contexto de Agent Teams, las tareas son el mecanismo de coordinación principal:

```
Lista de Tareas Compartida (visible para todos los teammates):

[pending]     Crear esquema de base de datos       -> asignada a Backend
[in_progress] Implementar endpoint POST /users     -> Backend trabajando
[in_progress] Crear formulario de registro         -> Frontend trabajando
[pending]     Escribir tests de integración        -> esperando a Backend y Frontend
[pending]     Documentar API endpoints             -> esperando a Backend
```

Cada teammate puede ver el estado de las tareas de los demás y saber cuándo una dependencia está lista para empezar su propio trabajo.

---

## Errores comunes

| Error | Causa | Solución |
|-------|-------|---------|
| Agente borrando trabajo del repo principal | No usar worktree isolation en experimentos | Siempre usar `isolation: "worktree"` para trabajo experimental |
| Polling manual de background agents | Confundir con procesos background de bash | La notificación es automática; no hay que preguntar |
| SendMessage a agente sin nombre | El agente no puede recibir mensajes dirigidos | Siempre asignar nombre al lanzar agentes que recibirán mensajes |
| Usar `task.resume` para continuar agentes | `task.resume` ha sido eliminado en v3.0 | Usar `SendMessage(to: "nombre-agente")` para continuar un agente existente |
| Tareas usadas como memoria permanente | Las tareas desaparecen al terminar la sesión | Usar CLAUDE.md o ficheros de contexto para persistencia |
| Demasiados background agents a la vez | Consumo de tokens muy elevado | Limitar a 3-4 agentes paralelos como máximo |

---

## Resumen

- `CLAUDE_CODE_FORK_SUBAGENT=1` habilita aislamiento en worktree para todos los subagentes de la sesión; desde v2.1.121 también funciona en sesiones no-interactivas (`--print`, SDK)
- `isolation: "worktree"` crea una copia aislada del repo para que el subagente trabaje sin afectar el principal; los cambios se descartan automáticamente si el agente no produce resultados útiles
- `worktree.baseRef` (v2.1.133) controla si el worktree nuevo rama desde `"fresh"` (último commit remoto) o `"head"` (estado local actual)
- `EnterWorktree` puede cambiar entre worktrees gestionados en mitad de sesión desde v2.1.157, sin salir explícitamente del worktree actual
- `SendMessage` permite comunicación dirigida a agentes con nombre, preservando su contexto completo en lugar de empezar desde cero
- Desde v2.1.166, los mensajes `SendMessage` recibidos de **otra sesión** ya no llevan autoridad de usuario: se tratan como contexto informativo, no como instrucción directa
- Los background agents con `run_in_background: true` trabajan de forma autónoma y notifican automáticamente al terminar, sin necesidad de polling
- Combinar background agents con worktree isolation es el patrón más potente para trabajo paralelo seguro
- Las herramientas `TaskCreate`, `TaskGet`, `TaskList`, `TaskUpdate` y `TaskStop` permiten descomponer y hacer seguimiento de trabajo complejo dentro de una sesión
- Las tareas son efímeras (solo duran la sesión); para persistencia entre sesiones, usar CLAUDE.md o ficheros de contexto
- Para monitorizar sesiones y subagentes en background a nivel de dashboard (`claude agents`, notificaciones, Dynamic Workflows), ver [Módulo 16](../../modulo-16-agentes-background-workflows/README.md)
