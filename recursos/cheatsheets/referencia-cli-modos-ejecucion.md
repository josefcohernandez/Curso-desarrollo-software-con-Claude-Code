# Referencia CLI — Modos de ejecución

> Documentación exhaustiva de los modos en que se puede invocar Claude Code desde la línea de comandos.

Índice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Visión general

Claude Code soporta varios modos de ejecución que determinan cómo interactúas con el modelo, cómo se gestiona la sesión y cómo fluye la entrada y la salida.

| Modo | Comando base | Interactivo | Persistencia | Uso típico |
|------|-------------|-------------|--------------|------------|
| Interactivo | `claude` | Sí | Sí | Desarrollo día a día |
| One-shot | `claude "query"` | Sí (tras respuesta) | Sí | Empezar con un contexto inicial |
| Headless / print | `claude -p "query"` | No | Configurable | Scripts, CI/CD, automatización |
| Pipe / stdin | `cat file \| claude -p "query"` | No | Configurable | Procesar contenido de ficheros |
| Remoto | `claude --remote "tarea"` | No (crea sesión web) | Sí (en claude.ai) | Sesiones de larga duración en la nube |
| Remote Control | `claude --remote-control` | Sí | Sí | Control desde claude.ai o app móvil |
| Worktree | `claude -w nombre` | Sí | Sí | Trabajo paralelo en branches aislados |

---

## Modo interactivo

### Descripción

Inicia una sesión REPL (Read-Eval-Print Loop) conversacional completa. Claude Code mantiene el estado de la sesión, gestiona el contexto acumulado, y ofrece todas las funcionalidades interactivas: slash commands, atajos de teclado, historial de prompts, autocompletado, etc.

### Sintaxis

```bash
claude
claude [flags]
```

### Cuando usarlo

- Desarrollo activo: explorar código, implementar features, hacer refactoring
- Tareas complejas que requieren múltiples turnos de conversación
- Cuando necesitas usar slash commands (`/clear`, `/compact`, `/model`, etc.)
- Cuando quieres revisión y aprobación de acciones antes de ejecutarlas

### Ejemplos

```bash
# Sesión interactiva básica
claude

# Sesión interactiva con modelo específico
claude --model opus

# Sesión interactiva en modo Plan (solo planifica, no ejecuta)
claude --permission-mode plan

# Sesión interactiva con directorio adicional
claude --add-dir ../shared-lib

# Sesión interactiva con nombre para poder reanudar después
claude --name "refactor-autenticación"
```

### Compatibilidad con otros flags

Compatible con casi todos los flags de arranque. Los flags `--max-turns`, `--max-budget-usd`, `--output-format` y `--fallback-model` son exclusivos del modo print (`-p`).

---

## Modo one-shot (con query inicial)

### Descripción

Inicia una sesión interactiva pero con un prompt inicial ya especificado. Claude procesa el prompt inmediatamente al arrancar y luego la sesión continúa en modo interactivo. Es útil cuando ya sabes exactamente cuál es la primera instrucción que quieres dar.

### Sintaxis

```bash
claude "<query>"
claude "<query>" [flags]
```

### Cuando usarlo

- Cuando tienes una tarea clara y concreta con la que empezar
- Para combinar un contexto inicial con la posibilidad de hacer seguimiento
- Cuando quieres que Claude empiece a trabajar inmediatamente sin esperar input

### Ejemplos

```bash
# Iniciar con una pregunta
claude "explica la arquitectura de este proyecto"

# Iniciar con una tarea de implementación
claude "implementa un endpoint REST para crear usuarios en src/api/users.ts"

# Iniciar en modo plan con una tarea
claude --permission-mode plan "refactoriza el módulo de autenticación para usar JWT"

# Reanudar sesión con query inicial
claude --resume "refactor-autenticación" "continua con los tests unitarios"
```

---

## Modo headless / print (`-p`)

### Descripción

Ejecuta Claude de forma no interactiva: procesa el prompt, emite la respuesta, y termina. No hay sesión REPL, no hay interacción con el usuario, no hay slash commands. La salida va directamente a stdout, lo que permite integrarlo en scripts, pipelines de CI/CD, y herramientas de automatización.

Este modo es equivalente al uso del Agent SDK y es la base para cualquier automatización con Claude Code.

### Sintaxis

```bash
claude -p "<query>"
claude --print "<query>"
claude -p "<query>" [flags exclusivos de print]
```

### Cuando usarlo

- Scripts de automatización y CI/CD
- Procesamiento en batch de múltiples ficheros o queries
- Cuando necesitas capturar la salida de Claude en una variable o fichero
- Integraciones con otras herramientas
- Cuando necesitas output estructurado en JSON

### Ejemplos

```bash
# Query simple, salida en texto
claude -p "cuantos archivos .ts hay en src/"

# Con formato JSON
claude -p "analiza la estructura del proyecto" --output-format json

# Limitando turnos y presupuesto
claude -p "implementa tests para auth.ts" --max-turns 10 --max-budget-usd 2.00

# Guardando la salida en un fichero
claude -p "genera documentación para la API" > docs/api.md

# En un script bash
RESUMEN=$(claude -p "resume los cambios de este commit: $(git log -1 --format='%s %b')")
echo "Resumen: $RESUMEN"

# Con modelo de fallback
claude -p "query compleja" --fallback-model sonnet

# Sin persistencia de sesión (más rápido, sin guardar en disco)
claude -p --no-session-persistence "query rápida"
```

### Flags exclusivos del modo print

Estos flags solo funcionan con `-p` / `--print`:

| Flag | Descripción |
|------|-------------|
| `--max-turns N` | Máximo de turnos antes de terminar |
| `--max-budget-usd N` | Tope de gasto en dólares |
| `--output-format` | Formato de salida: `text`, `json`, `stream-json` |
| `--fallback-model` | Modelo alternativo si el principal está sobrecargado |
| `--no-session-persistence` | No guardar la sesión en disco |
| `--json-schema` | Validar output contra un JSON Schema |
| `--include-partial-messages` | Incluir eventos de streaming parciales |
| `--input-format` | Formato de entrada: `text`, `stream-json` |
| `--permission-prompt-tool` | Herramienta MCP para gestionar permisos |

---

## Modo pipe / stdin

### Descripción

Claude Code lee contenido desde stdin cuando se usa en una pipeline de Unix. El contenido del stdin se incorpora al contexto del prompt. Este modo requiere `-p` para funcionar correctamente en scripts.

### Sintaxis

```bash
comando | claude -p "<query sobre el contenido>"
claude -p "<query>" < fichero.txt
```

### Cuando usarlo

- Analizar ficheros de log en tiempo real
- Procesar la salida de otros comandos (git diff, grep, etc.)
- Revisar código o configuración antes de aplicar cambios
- Pipelines de transformación de datos

### Ejemplos

```bash
# Analizar logs
cat logs/error.log | claude -p "identifica los errores más frecuentes y sugiere soluciones"

# Revisar cambios staged antes de commit
git diff --staged | claude -p "revisa estos cambios y sugiere un mensaje de commit"

# Review de seguridad de un PR
gh pr diff 123 | claude -p "analiza este PR buscando vulnerabilidades de seguridad"

# Procesar la salida de un comando
npm audit | claude -p "resume las vulnerabilidades críticas y como resolverlas"

# Analizar un fichero de configuración
cat .env.example | claude -p "explica cada variable de entorno"

# Combinar stdin con formato JSON
git log --oneline -20 | claude -p "categoriza estos commits por tipo de cambio" --output-format json

# Leer desde un fichero
claude -p "revisa este fichero de configuración y sugiere mejoras" < docker-compose.yml
```

### Notas técnicas

- El contenido de stdin se concatena antes del prompt cuando se usan pipes
- Claude Code detecta automáticamente si stdin es un terminal o un pipe
- Con stdin interactivo (terminal), el modo funciona normalmente
- Con stdin no-interactivo (pipe o fichero), se comporta como modo headless

---

## Modo remoto (`--remote`)

### Descripción

Crea una nueva sesión en la infraestructura web de Anthropic (claude.ai) con la tarea especificada. En lugar de ejecutar localmente, la sesión corre en los servidores de Anthropic con acceso a recursos en la nube. La tarea se inicia en la web y puede ejecutarse en segundo plano.

### Sintaxis

```bash
claude --remote "<descripción de la tarea>"
```

### Cuando usarlo

- Tareas de larga duración que no quieres dejar corriendo en tu máquina local
- Cuando necesitas recursos de cómputo en la nube
- Para delegar trabajo mientras tu máquina local está ocupada
- Tareas que pueden ejecutarse sin supervisión

### Ejemplo

```bash
# Crear una sesión remota
claude --remote "analiza todo el código en busca de oportunidades de optimización y genera un informe"

# La sesión se inicia en claude.ai y puedes monitorearla desde el navegador
```

### Notas

- Requiere cuenta en claude.ai con plan compatible
- La sesión se puede reanudar localmente usando `--teleport`
- La sesión persiste en claude.ai aunque cierres el terminal local
- Configura el entorno remoto por defecto con `/remote-env`

---

## Modo Remote Control (`--remote-control`)

### Descripción

Inicia una sesión interactiva local que además queda accesible para control desde claude.ai o la app móvil de Claude. Permite supervisar y controlar la sesión desde otro dispositivo mientras Claude trabaja localmente con acceso completo al sistema de ficheros y herramientas.

### Sintaxis

```bash
claude --remote-control [nombre-sesión]
claude --rc [nombre-sesión]
```

### Cuando usarlo

- Supervisar el trabajo de Claude desde un móvil o segundo dispositivo
- Colaboración remota donde alguien controla Claude en tu máquina
- Monitorizar tareas largas sin estar frente al terminal

### Ejemplo

```bash
# Sesión con Remote Control habilitado
claude --remote-control "implementación-auth"

# Sin nombre (se auto-genera)
claude --rc
```

---

## Modo teleport (`--teleport`)

### Descripción

Reanuda una sesión remota que está corriendo en claude.ai y la trae al terminal local. Permite continuar en el terminal una tarea que fue iniciada con `--remote` o que está corriendo en la interfaz web.

### Sintaxis

```bash
claude --teleport
```

### Cuando usarlo

- Continuar localmente una sesión que iniciaste con `--remote`
- Traer al terminal una sesión que empezaste en claude.ai
- Cuando necesitas acceso a herramientas locales en una sesión remota

### Ejemplo

```bash
# Teleportar la sesión remota activa al terminal local
claude --teleport

# Se mostrará un selector si hay múltiples sesiones activas
```

---

## Modo worktree (`-w`)

### Descripción

Inicia Claude en un git worktree aislado dentro del repositorio actual. Crea un worktree en `.claude/worktrees/<nombre>` donde Claude puede trabajar sin afectar el worktree principal. Ideal para trabajar en múltiples tareas en paralelo sobre el mismo repositorio.

### Sintaxis

```bash
claude -w [nombre]
claude --worktree [nombre]
```

### Cuando usarlo

- Implementar una feature sin afectar el branch principal
- Ejecutar múltiples instancias de Claude en paralelo en el mismo repo
- Mantener el worktree principal limpio mientras Claude experimenta
- Flujos de trabajo con branches de vida corta

### Ejemplos

```bash
# Crear worktree con nombre descriptivo
claude -w feature-autenticación

# Sin nombre (se auto-genera)
claude -w

# Listar worktrees activos
git worktree list
```

---

## Subcomandos de gestion

Además de los modos de sesión, Claude Code ofrece subcomandos para gestion:

| Subcomando | Descripción |
|------------|-------------|
| `claude update` | Actualizar Claude Code a la última versión |
| `claude auth login` | Iniciar sesión en la cuenta de Anthropic. En WSL2, SSH y containers acepta pegar el código OAuth directamente en la terminal |
| `claude auth login --console` | Iniciar sesión con API key de Anthropic Console |
| `claude auth login --sso` | Iniciar sesión con SSO |
| `claude auth logout` | Cerrar sesión |
| `claude auth status` | Ver estado de autenticación (JSON) |
| `claude auth status --text` | Ver estado de autenticación (texto legible) |
| `claude agents` | Listar todos los subagentes configurados |
| `claude mcp` | Gestionar servidores MCP |
| `claude remote-control` | Iniciar servidor de Remote Control (sin sesión local) |
| `claude ultrareview [target]` | Revisión de código multi-agente no-interactiva. Acepta `--json` para salida estructurada. Equivale al slash command `/ultrareview` pero para uso en scripts y CI |
| `claude project purge [path]` | Elimina todo el estado de Claude Code de un proyecto: transcripts, tasks y configuración local. Flags: `--dry-run` (simula sin borrar), `-y` (confirma sin preguntar), `-i` (interactivo), `--all` (incluye configuración global) |
| `claude plugin prune` | Elimina dependencias de plugins huérfanas (plugins instalados pero ya no referenciados) |
| `claude plugin tag <version>` | Crea un git tag de release para el plugin actual con validación de formato SemVer |

---

## Ver también

- [Flags de arranque](./referencia-cli-flags-arranque.md) — Todos los flags disponibles para cada modo
- [Formatos de salida](./referencia-cli-formatos-salida.md) — Como estructurar la salida del modo headless
- [Slash commands](./referencia-cli-slash-commands.md) — Comandos disponibles en el modo interactivo
