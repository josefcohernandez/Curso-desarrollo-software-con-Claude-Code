# Referencia CLI — Flags de arranque

> Documentacion exhaustiva de todos los flags disponibles al invocar `claude` desde la linea de comandos.

Indice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Convencion de lectura

- `<arg>` — argumento obligatorio
- `[arg]` — argumento opcional
- **Solo print** — el flag solo funciona con `-p` / `--print`
- Los flags se pueden combinar libremente salvo que se indique lo contrario

---

## Tabla completa de flags

### Gestion de sesion

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--continue` | `-c` | boolean | Carga la conversacion mas reciente en el directorio actual | `claude -c` |
| `--resume` | `-r` | string | Reanuda una sesion especifica por ID o nombre, o abre el selector interactivo | `claude -r "refactor-auth"` |
| `--fork-session` | — | boolean | Al reanudar, crea un nuevo ID de sesion en lugar de reutilizar el original (usar con `--resume` o `--continue`) | `claude --resume abc123 --fork-session` |
| `--from-pr` | — | string/number | Reanuda sesiones vinculadas a un PR de GitHub especifico. Acepta numero o URL de PR | `claude --from-pr 123` |
| `--name` | `-n` | string | Asigna un nombre visible a la sesion, mostrado en `/resume` y en el titulo del terminal | `claude -n "mi-feature"` |
| `--session-id` | — | string (UUID) | Usa un ID de sesion especifico para la conversacion (debe ser UUID valido) | `claude --session-id "550e8400-..."` |
| `--no-session-persistence` | — | boolean | **Solo print.** No guarda la sesion en disco (mas rapido, no se puede reanudar) | `claude -p --no-session-persistence "query"` |

### Modelo y razonamiento

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--model` | — | string | Modelo para la sesion. Acepta alias (`sonnet`, `opus`) o nombre completo | `claude --model claude-opus-4-6` |
| `--effort` | — | string | Nivel de esfuerzo: `low`, `medium`, `high`, `max` (Opus 4.6 solo). No persiste en settings | `claude --effort high` |
| `--fallback-model` | — | string | **Solo print.** Modelo de fallback si el principal esta sobrecargado | `claude -p --fallback-model sonnet "query"` |

### Herramientas y permisos

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--allowedTools` | — | string[] | Herramientas que se ejecutan sin pedir permiso. Ver [sintaxis de reglas de permisos](https://code.claude.com/docs/en/settings#permission-rule-syntax) | `--allowedTools "Bash(git log *)" "Read"` |
| `--disallowedTools` | — | string[] | Herramientas que se eliminan del contexto del modelo y no pueden usarse | `--disallowedTools "Bash(rm *)" "Edit"` |
| `--tools` | — | string | Restringe que herramientas integradas puede usar Claude. `""` para desactivar todas, `"default"` para todas, o nombres separados por coma | `--tools "Bash,Edit,Read"` |
| `--permission-mode` | — | string | Inicia en el modo de permisos indicado: `default`, `acceptEdits`, `plan`, `bypassPermissions` | `claude --permission-mode plan` |
| `--dangerously-skip-permissions` | — | boolean | Omite todos los prompts de permisos. **Usar solo en entornos aislados y controlados** | `claude --dangerously-skip-permissions` |
| `--allow-dangerously-skip-permissions` | — | boolean | Habilita el bypass de permisos como opcion sin activarlo inmediatamente. Permite composicion con `--permission-mode` | `claude --permission-mode plan --allow-dangerously-skip-permissions` |
| `--permission-prompt-tool` | — | string | **Solo print.** Herramienta MCP para gestionar prompts de permisos en modo no interactivo | `claude -p --permission-prompt-tool mcp_auth "query"` |
| `--disable-slash-commands` | — | boolean | Desactiva todas las skills y comandos para esta sesion | `claude --disable-slash-commands` |

### System prompt

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--system-prompt` | — | string | Reemplaza el system prompt por defecto con el texto indicado | `claude --system-prompt "Eres un experto en Python"` |
| `--system-prompt-file` | — | path | Reemplaza el system prompt con el contenido de un fichero | `claude --system-prompt-file ./prompts/review.txt` |
| `--append-system-prompt` | — | string | Anade texto al final del system prompt por defecto (sin reemplazarlo) | `claude --append-system-prompt "Usa siempre TypeScript estricto"` |
| `--append-system-prompt-file` | — | path | Anade el contenido de un fichero al final del system prompt por defecto | `claude --append-system-prompt-file ./style-rules.txt` |

**Nota:** `--system-prompt` y `--system-prompt-file` son mutuamente excluyentes. Los flags append pueden combinarse con cualquiera de los flags de reemplazo. Para la mayoria de casos, usa append para preservar las capacidades integradas de Claude Code.

### Directorios y workspace

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--add-dir` | — | string[] | Anade directorios de trabajo adicionales. Valida que cada ruta exista | `claude --add-dir ../apps ../lib` |
| `--worktree` | `-w` | string | Inicia Claude en un git worktree aislado en `.claude/worktrees/<nombre>` | `claude -w feature-auth` |

### Configuracion y settings

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--settings` | — | string | Ruta a un fichero JSON de settings o string JSON para cargar configuracion adicional | `claude --settings ./settings.json` |
| `--setting-sources` | — | string | Lista separada por comas de fuentes de settings a cargar: `user`, `project`, `local` | `claude --setting-sources user,project` |
| `--mcp-config` | — | string[] | Carga servidores MCP desde ficheros JSON o strings (separados por espacios) | `claude --mcp-config ./mcp.json` |
| `--strict-mcp-config` | — | boolean | Usa solo los servidores MCP de `--mcp-config`, ignorando todas las demas configuraciones MCP | `claude --strict-mcp-config --mcp-config ./mcp.json` |

### Agentes

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--agent` | — | string | Especifica un agente para la sesion actual (sobreescribe la configuracion de `agent`) | `claude --agent mi-agente-personalizado` |
| `--agents` | — | JSON string | Define subagentes personalizados dinamicamente via JSON. Usa los mismos campos que el frontmatter de subagentes, mas un campo `prompt` | `claude --agents '{"reviewer":{"description":"Revisa codigo","prompt":"Eres un revisor"}}'` |
| `--teammate-mode` | — | string | Modo de visualizacion de companieros de equipo: `auto` (defecto), `in-process`, o `tmux` | `claude --teammate-mode in-process` |

### Inicializacion y mantenimiento

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--init` | — | boolean | Ejecuta hooks de inicializacion e inicia el modo interactivo | `claude --init` |
| `--init-only` | — | boolean | Ejecuta hooks de inicializacion y sale (sin sesion interactiva) | `claude --init-only` |
| `--maintenance` | — | boolean | Ejecuta hooks de mantenimiento y sale | `claude --maintenance` |
| `--bare` | — | boolean | **Solo print.** Salta auto-discovery de hooks, skills, plugins, servidores MCP, auto memory y CLAUDE.md al arrancar. Reduce la latencia de inicio en llamadas scripteadas. Combinado habitualmente con `-p` | `claude -p --bare "query"` |

### Output y formato (modo print)

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--print` | `-p` | boolean | Modo no interactivo: emite la respuesta y sale | `claude -p "query"` |
| `--output-format` | — | string | **Solo print.** Formato de salida: `text` (defecto), `json`, `stream-json` | `claude -p "query" --output-format json` |
| `--input-format` | — | string | **Solo print.** Formato de entrada: `text` (defecto), `stream-json` | `claude -p --input-format stream-json` |
| `--json-schema` | — | JSON string | **Solo print.** Valida el output contra un JSON Schema una vez que el agente completa su workflow | `claude -p --json-schema '{"type":"object",...}' "query"` |
| `--include-partial-messages` | — | boolean | **Solo print.** Incluye eventos de streaming parciales (requiere formato `stream-json`) | `claude -p --output-format stream-json --include-partial-messages "query"` |
| `--max-turns` | — | number | **Solo print.** Limita el numero de turnos agentivos. Sale con error al alcanzar el limite | `claude -p --max-turns 3 "query"` |
| `--max-budget-usd` | — | float | **Solo print.** Tope de gasto en dolares antes de detener la ejecucion | `claude -p --max-budget-usd 5.00 "query"` |
| `--verbose` | — | boolean | Activa logging detallado, muestra el output completo turno a turno | `claude --verbose` |

### Integraciones

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--chrome` | — | boolean | Habilita la integracion con el navegador Chrome para automatizacion web | `claude --chrome` |
| `--no-chrome` | — | boolean | Deshabilita la integracion con Chrome para esta sesion | `claude --no-chrome` |
| `--ide` | — | boolean | Conecta automaticamente al IDE al arrancar si hay exactamente uno disponible | `claude --ide` |
| `--channels` | — | string[] | Habilita servidores de canal nombrados para enviar mensajes a esta sesion | `claude --channels plugin:fakechat@claude-plugins-official` |
| `--plugin-dir` | — | string | Carga plugins desde un directorio solo para esta sesion. Repetir el flag para multiples directorios | `claude --plugin-dir ./my-plugins` |

### Control remoto

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--remote` | — | string | Crea una nueva sesion web en claude.ai con la descripcion de tarea indicada | `claude --remote "Arregla el bug de login"` |
| `--remote-control` | `--rc` | string | Inicia sesion interactiva con Remote Control habilitado para control desde claude.ai o la app | `claude --remote-control "Mi Proyecto"` |
| `--teleport` | — | boolean | Reanuda una sesion web en el terminal local | `claude --teleport` |

### API y desarrollo

| Flag | Alias | Tipo | Descripcion | Ejemplo |
|------|-------|------|-------------|---------|
| `--betas` | — | string[] | Cabeceras beta a incluir en las peticiones API (solo usuarios con API key) | `claude --betas interleaved-thinking` |
| `--debug` | — | string | Activa modo debug con filtrado opcional de categorias (ej: `"api,hooks"` o `"!statsig,!file"`) | `claude --debug "api,mcp"` |
| `--version` | `-v` | boolean | Muestra la version instalada de Claude Code | `claude -v` |
| `--enable-auto-mode` | — | boolean | Desbloquea Auto Mode en el ciclo de `Shift+Tab`. Requiere plan Team y Claude Sonnet 4.6 o Opus 4.6 | `claude --enable-auto-mode` |
| `--tmux` | — | string | Crea una sesion tmux para el worktree. Requiere `--worktree`. Usa paneles nativos de iTerm2 si esta disponible; pasar `--tmux=classic` para tmux tradicional | `claude -w feature --tmux` |
| `--dangerously-load-development-channels` | — | boolean | Habilita canales no incluidos en la allowlist aprobada para desarrollo local | `claude --dangerously-load-development-channels` |

---

## Ejemplos de combinaciones frecuentes

### CI/CD con presupuesto controlado

```bash
claude -p "ejecuta los tests y reporta fallos" \
  --max-turns 5 \
  --max-budget-usd 1.00 \
  --output-format json
```

### Revision de codigo con model especifico

```bash
git diff --staged | claude -p "revisa estos cambios" \
  --model opus \
  --append-system-prompt "Enfocate en seguridad y rendimiento"
```

### Sesion de desarrollo con agente especializado

```bash
claude \
  --agent revisor-codigo \
  --permission-mode acceptEdits \
  --name "sprint-23-auth" \
  --add-dir ../shared-utils
```

### Modo plan para tareas complejas

```bash
claude "implementa el sistema de notificaciones" \
  --permission-mode plan \
  --model opus
```

### Automatizacion con output estructurado

```bash
claude -p "analiza el proyecto y genera un informe de dependencias" \
  --output-format json \
  --no-session-persistence \
  --max-turns 10 \
  > informe-dependencias.json
```

### Entorno enterprise con MCP especifico

```bash
claude \
  --strict-mcp-config \
  --mcp-config ./empresa-mcp.json \
  --permission-mode default \
  --setting-sources user,project
```

---

## Modos de permisos (`--permission-mode`)

| Modo | Comportamiento | Caso de uso |
|------|---------------|-------------|
| `default` | Pregunta antes de ejecutar acciones que modifican el sistema | Uso normal diario |
| `acceptEdits` | Acepta automaticamente ediciones de ficheros, pregunta para Bash | Implementacion activa |
| `plan` | Solo propone planes, no ejecuta nada | Revision de arquitectura, code review |
| `bypassPermissions` | Totalmente autonomo, no pregunta nada. **Solo para entornos aislados** | Automatizacion controlada |

---

## Ver tambien

- [Modos de ejecucion](./referencia-cli-modos-ejecucion.md) — Descripcion detallada de cada modo
- [Variables de entorno](./referencia-cli-variables-entorno.md) — Alternativas a flags via variables de entorno
- [Formatos de salida](./referencia-cli-formatos-salida.md) — Detalle de `--output-format` y `--json-schema`
