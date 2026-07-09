# Referencia CLI — Flags de arranque

> Documentación exhaustiva de todos los flags disponibles al invocar `claude` desde la línea de comandos.

Índice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Convención de lectura

- `<arg>` — argumento obligatorio
- `[arg]` — argumento opcional
- **Solo print** — el flag solo funciona con `-p` / `--print`
- Los flags se pueden combinar libremente salvo que se indique lo contrario

---

## Tabla completa de flags

### Gestión de sesión

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--continue` | `-c` | boolean | Carga la conversación más reciente en el directorio actual | `claude -c` |
| `--resume` | `-r` | string | Reanuda una sesión específica por ID o nombre, o abre el selector interactivo. En modo `-p`, acepta títulos asignados con `/rename` o `--name` (v2.1.101) | `claude -r "refactor-auth"` |
| `--fork-session` | — | boolean | Al reanudar, crea un nuevo ID de sesión en lugar de reutilizar el original (usar con `--resume` o `--continue`) | `claude --resume abc123 --fork-session` |
| `--from-pr` | — | string/number | Reanuda sesiones vinculadas a un PR de GitHub específico. Acepta número o URL de PR | `claude --from-pr 123` |
| `--name` | `-n` | string | Asigna un nombre visible a la sesión, mostrado en `/resume` y en el título del terminal | `claude -n "mi-feature"` |
| `--session-id` | — | string (UUID) | Usa un ID de sesión específico para la conversación (debe ser UUID válido) | `claude --session-id "550e8400-..."` |
| `--no-session-persistence` | — | boolean | **Solo print.** No guarda la sesión en disco (más rápido, no se puede reanudar) | `claude -p --no-session-persistence "query"` |

### Modelo y razonamiento

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--model` | — | string | Modelo para la sesión. Acepta alias (`sonnet`, `opus`) o nombre completo | `claude --model claude-opus-4-6` |
| `--effort` | — | string | Nivel de esfuerzo: `low`, `medium`, `high`, `max` (Opus 4.6 solo). No persiste en settings | `claude --effort high` |
| `--fallback-model` | — | string | Modelo(s) de fallback si el principal está sobrecargado. Acepta hasta 3 modelos separados por coma, probados en orden. Ya no está restringido a `-p`: también aplica a sesiones interactivas (v2.1.166) | `claude --fallback-model sonnet,haiku "query"` |

### Herramientas y permisos

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--allowedTools` | — | string[] | Herramientas que se ejecutan sin pedir permiso. Ver [sintaxis de reglas de permisos](https://code.claude.com/docs/en/settings#permission-rule-syntax) | `--allowedTools "Bash(git log *)" "Read"` |
| `--disallowedTools` | — | string[] | Herramientas que se eliminan del contexto del modelo y no pueden usarse | `--disallowedTools "Bash(rm *)" "Edit"` |
| `--tools` | — | string | Restringe que herramientas integradas puede usar Claude. `""` para desactivar todas, `"default"` para todas, o nombres separados por coma. En builds nativas, listar explícitamente `Grep` y/o `Glob` habilita las tools de búsqueda dedicadas en lugar de las genéricas equivalentes vía Bash (v2.1.162) | `--tools "Bash,Edit,Read,Grep,Glob"` |
| `--permission-mode` | — | string | Inicia en el modo de permisos indicado: `manual`, `acceptEdits`, `plan`, `bypassPermissions`. El modo `default` fue renombrado a `manual` en v2.1.200; `default` se sigue aceptando como alias por compatibilidad | `claude --permission-mode plan` |
| `--dangerously-skip-permissions` | — | boolean | Omite todos los prompts de permisos, incluidos los de escritura en directorios sensibles como `.claude/`, `.git/`, `.vscode/` y ficheros de configuración del shell (`.bashrc`, `.zshrc`, etc.), que antes de v2.1.126 seguían pidiendo confirmación explícita. **Usar solo en entornos aislados y controlados** | `claude --dangerously-skip-permissions` |
| `--safe-mode` | — | boolean | Arranca con CLAUDE.md, plugins, skills, hooks y servidores MCP deshabilitados. Útil para aislar si un problema viene de la configuración del proyecto/usuario o del propio Claude Code (v2.1.169) | `claude --safe-mode` |
| `--allow-dangerously-skip-permissions` | — | boolean | Habilita el bypass de permisos como opción sin activarlo inmediatamente. Permite composición con `--permission-mode` | `claude --permission-mode plan --allow-dangerously-skip-permissions` |
| `--permission-prompt-tool` | — | string | **Solo print.** Herramienta MCP para gestionar prompts de permisos en modo no interactivo | `claude -p --permission-prompt-tool mcp_auth "query"` |
| `--disable-slash-commands` | — | boolean | Desactiva todas las skills y comandos para esta sesión | `claude --disable-slash-commands` |

### System prompt

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--system-prompt` | — | string | Reemplaza el system prompt por defecto con el texto indicado | `claude --system-prompt "Eres un experto en Python"` |
| `--system-prompt-file` | — | path | Reemplaza el system prompt con el contenido de un fichero | `claude --system-prompt-file ./prompts/review.txt` |
| `--append-system-prompt` | — | string | Añade texto al final del system prompt por defecto (sin reemplazarlo) | `claude --append-system-prompt "Usa siempre TypeScript estricto"` |
| `--append-system-prompt-file` | — | path | Añade el contenido de un fichero al final del system prompt por defecto | `claude --append-system-prompt-file ./style-rules.txt` |

**Nota:** `--system-prompt` y `--system-prompt-file` son mutuamente excluyentes. Los flags append pueden combinarse con cualquiera de los flags de reemplazo. Para la mayoría de casos, usa append para preservar las capacidades integradas de Claude Code.

### Directorios y workspace

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--add-dir` | — | string[] | Añade directorios de trabajo adicionales. Valida que cada ruta exista | `claude --add-dir ../apps ../lib` |
| `--worktree` | `-w` | string | Inicia Claude en un git worktree aislado en `.claude/worktrees/<nombre>` | `claude -w feature-auth` |

### Configuración y settings

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--settings` | — | string | Ruta a un fichero JSON de settings o string JSON para cargar configuración adicional | `claude --settings ./settings.json` |
| `--setting-sources` | — | string | Lista separada por comás de fuentes de settings a cargar: `user`, `project`, `local` | `claude --setting-sources user,project` |
| `--mcp-config` | — | string[] | Carga servidores MCP desde ficheros JSON o strings (separados por espacios) | `claude --mcp-config ./mcp.json` |
| `--strict-mcp-config` | — | boolean | Usa solo los servidores MCP de `--mcp-config`, ignorando todas las demás configuraciones MCP | `claude --strict-mcp-config --mcp-config ./mcp.json` |

### Agentes

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--agent` | — | string | Especifica un agente para la sesión actual (sobreescribe la configuración de `agent`) | `claude --agent mi-agente-personalizado` |
| `--agents` | — | JSON string | Define subagentes personalizados dinámicamente vía JSON. Usa los mismos campos que el frontmatter de subagentes, más un campo `prompt` | `claude --agents '{"reviewer":{"description":"Revisa código","prompt":"Eres un revisor"}}'` |
| `--teammate-mode` | — | string | Modo de visualización de compañeros de equipo: `auto` (defecto), `in-process`, o `tmux` | `claude --teammate-mode in-process` |

### Flags del subcomando `claude agents`

El comando `claude agents` (dashboard de sesiones, ver [Modos de ejecución](./referencia-cli-modos-ejecucion.md)) acepta flags propios de consulta y de dispatch (lanzamiento de nuevas sesiones background). Detalle completo en el [Módulo 16](../../modulo-16-agentes-background-workflows/teoria/01-agent-view.md).

| Flag | Tipo | Descripción | Ejemplo | Versión |
|------|------|-------------|---------|---------|
| `--cwd` | path | Acota el listado de `claude agents` a las sesiones de un directorio concreto | `claude agents --cwd ~/proyectos/taskflow-api` | v2.1.141 |
| `--json` | boolean | Salida estructurada de `claude agents` para scripting (ver [formatos de salida](./referencia-cli-formatos-salida.md)) | `claude agents --json` | v2.1.145 |
| `--add-dir` | path[] | Directorios adicionales accesibles para la sesión lanzada desde el dashboard | `claude agents --add-dir ../shared-lib` | v2.1.143 |
| `--settings` | path | Fichero de settings alternativo para la sesión lanzada | `claude agents --settings ./settings-migracion.json` | v2.1.143 |
| `--mcp-config` | path | Configuración de servidores MCP a cargar en la sesión lanzada | `claude agents --mcp-config ./mcp.json` | v2.1.143 |
| `--plugin-dir` | path | Plugin local a cargar en la sesión lanzada | `claude agents --plugin-dir ./my-plugins` | v2.1.143 |
| `--permission-mode` | string | Modo de permisos de la sesión lanzada (`manual`, `acceptEdits`, `plan`, `bypassPermissions`) | `claude agents --permission-mode acceptEdits` | v2.1.143 |
| `--model` | string | Modelo a usar en la sesión lanzada | `claude agents --model opus` | v2.1.143 |
| `--effort` | string | Nivel de esfuerzo de razonamiento de la sesión lanzada | `claude agents --effort high` | v2.1.143 |
| `--dangerously-skip-permissions` | boolean | Omite confirmaciones de permisos en la sesión lanzada. Usar con extrema precaución | `claude agents --dangerously-skip-permissions` | v2.1.143 |

### Inicializacion y mantenimiento

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--init` | — | boolean | Ejecuta hooks de inicialización e inicia el modo interactivo | `claude --init` |
| `--init-only` | — | boolean | Ejecuta hooks de inicialización y sale (sin sesión interactiva) | `claude --init-only` |
| `--maintenance` | — | boolean | Ejecuta hooks de mantenimiento y sale | `claude --maintenance` |
| `--bare` | — | boolean | **Solo print.** Salta auto-discovery de hooks, skills, plugins, servidores MCP, auto memory y CLAUDE.md al arrancar. Reduce la latencia de inicio en llamadas scripteadas. Combinado habitualmente con `-p` | `claude -p --bare "query"` |

### Output y formato (modo print)

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--print` | `-p` | boolean | Modo no interactivo: emite la respuesta y sale | `claude -p "query"` |
| `--exclude-dynamic-system-prompt-sections` | — | boolean | **Solo print.** Excluye las secciones dinámicas del system prompt (CLAUDE.md, reglas contextuales). Mejora la tasa de prompt cache hits cuando múltiples usuarios comparten la misma configuración base (v2.1.98) | `claude -p --exclude-dynamic-system-prompt-sections "query"` |
| `--output-format` | — | string | **Solo print.** Formato de salida: `text` (defecto), `json`, `stream-json` | `claude -p "query" --output-format json` |
| `--input-format` | — | string | **Solo print.** Formato de entrada: `text` (defecto), `stream-json` | `claude -p --input-format stream-json` |
| `--json-schema` | — | JSON string | **Solo print.** Valida el output contra un JSON Schema una vez que el agente completa su workflow | `claude -p --json-schema '{"type":"object",...}' "query"` |
| `--include-partial-messages` | — | boolean | **Solo print.** Incluye eventos de streaming parciales (requiere formato `stream-json`) | `claude -p --output-format stream-json --include-partial-messages "query"` |
| `--max-turns` | — | number | **Solo print.** Limita el número de turnos agentivos. Sale con error al alcanzar el límite | `claude -p --max-turns 3 "query"` |
| `--max-budget-usd` | — | float | **Solo print.** Tope de gasto en dólares antes de detener la ejecución | `claude -p --max-budget-usd 5.00 "query"` |
| `--verbose` | — | boolean | Activa logging detallado, muestra el output completo turno a turno | `claude --verbose` |

### Integraciónes

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--chrome` | — | boolean | Habilita la integración con el navegador Chrome para automatizacion web | `claude --chrome` |
| `--no-chrome` | — | boolean | Deshabilita la integración con Chrome para esta sesión | `claude --no-chrome` |
| `--ide` | — | boolean | Conecta automáticamente al IDE al arrancar si hay exactamente uno disponible | `claude --ide` |
| `--channels` | — | string[] | Habilita servidores de canal nombrados para enviar mensajes a esta sesión | `claude --channels plugin:fakechat@claude-plugins-official` |
| `--plugin-dir` | — | string | Carga plugins desde un directorio solo para esta sesión. Repetir el flag para múltiples directorios. Desde v2.1.128 también acepta la ruta a un archivo `.zip` de plugin | `claude --plugin-dir ./my-plugins` |
| `--plugin-url` | — | URL | Descarga e instala un plugin desde un archivo `.zip` alojado en una URL, solo para esta sesión | `claude --plugin-url https://ejemplo.com/mi-plugin.zip` |

### Control remoto

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--remote` | — | string | Crea una nueva sesión web en claude.ai con la descripción de tarea indicada | `claude --remote "Arregla el bug de login"` |
| `--remote-control` | `--rc` | string | Inicia sesión interactiva con Remote Control habilitado para control desde claude.ai o la app | `claude --remote-control "Mi Proyecto"` |
| `--remote-control-session-name-prefix` | — | string | Sobreescribe el prefijo del nombre de sesión Remote Control (por defecto usa el hostname de la máquina, ej: `myhost-graceful-unicorn`) (v2.1.92) | `claude --rc "Proyecto" --remote-control-session-name-prefix "ci-build"` |
| `--teleport` | — | boolean | Reanuda una sesión web en el terminal local | `claude --teleport` |

### API y desarrollo

| Flag | Alias | Tipo | Descripción | Ejemplo |
|------|-------|------|-------------|---------|
| `--betas` | — | string[] | Cabeceras beta a incluir en las peticiones API (solo usuarios con API key) | `claude --betas interleaved-thinking` |
| `--debug` | — | string | Activa modo debug con filtrado opcional de categorias (ej: `"api,hooks"` o `"!statsig,!file"`) | `claude --debug "api,mcp"` |
| `--version` | `-v` | boolean | Muestra la versión instalada de Claude Code | `claude -v` |
| `--enable-auto-mode` | — | boolean | **[ELIMINADO en v2.1.111]** Desbloqueaba Auto Mode en el ciclo de `Shift+Tab`. Auto Mode está disponible directamente si el plan lo soporta, sin necesidad de este flag | — |
| `--tmux` | — | string | Crea una sesión tmux para el worktree. Requiere `--worktree`. Usa paneles nativos de iTerm2 si está disponible; pasar `--tmux=classic` para tmux tradicional | `claude -w feature --tmux` |
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

### Revisión de código con model específico

```bash
git diff --staged | claude -p "revisa estos cambios" \
  --model opus \
  --append-system-prompt "Enfócate en seguridad y rendimiento"
```

### Sesion de desarrollo con agente especializado

```bash
claude \
  --agent revisor-código \
  --permission-mode acceptEdits \
  --name "sprint-23-auth" \
  --add-dir ../shared-utils
```

### Modo plan para táreas complejas

```bash
claude "implementa el sistema de notificaciones" \
  --permission-mode plan \
  --model opus
```

### Automatización con output estructurado

```bash
claude -p "analiza el proyecto y genera un informe de dependencias" \
  --output-format json \
  --no-session-persistence \
  --max-turns 10 \
  > informe-dependencias.json
```

### Entorno enterprise con MCP específico

```bash
claude \
  --strict-mcp-config \
  --mcp-config ./empresa-mcp.json \
  --permission-mode manual \
  --setting-sources user,project
```

---

## Modos de permisos (`--permission-mode`)

| Modo | Comportamiento | Caso de uso |
|------|---------------|-------------|
| `manual` | Pregunta antes de ejecutar acciónes que modifican el sistema. Nombre actual del modo antes llamado `default` (renombrado en v2.1.200; `default` se sigue aceptando como alias) | Uso normal diario |
| `acceptEdits` | Acepta automáticamente ediciónes de ficheros, pregunta para Bash | Implementación activa |
| `plan` | Solo propone planes, no ejecuta nada | Revisión de arquitectura, code review |
| `bypassPermissions` | Totalmente autonomo, no pregunta nada. **Solo para entornos aislados** | Automatización controlada |

---

## Ver también

- [Modos de ejecución](./referencia-cli-modos-ejecucion.md) — Descripción detallada de cada modo
- [Variables de entorno](./referencia-cli-variables-entorno.md) — Alternativas a flags vía variables de entorno
- [Formatos de salida](./referencia-cli-formatos-salida.md) — Detalle de `--output-format` y `--json-schema`
