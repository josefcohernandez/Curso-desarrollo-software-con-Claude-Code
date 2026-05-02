# Referencia CLI — Slash Commands

> Documentación exhaustiva de todos los slash commands disponibles en el modo interactivo de Claude Code.

Índice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Cómo funcionan los slash commands

Los slash commands se invocan escribiendo `/` seguido del nombre del comando en el prompt interactivo. Al escribir `/` aparece un menú con todos los comandos disponibles y las skills del proyecto. Puedes filtrar escribiendo letras adicionales.

```
/                      → abre el menú de comandos
/cl                    → filtra y muestra /clear, /color, /compact, /copy, /cost, /context...
/clear                 → ejecuta el comando directamente
```

**Nota:** No todos los comandos son visibles para todos los usuarios. Algunos dependen de la plataforma, el plan, o el entorno. Por ejemplo, `/desktop` solo aparece en macOS y Windows, `/upgrade` solo en planes Pro y Max, y `/terminal-setup` se oculta cuando el terminal ya soporta sus keybindings de forma nativa.

---

## Referencia completa de comandos integrados

### Gestión de sesión y contexto

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/clear` | `/clear` | Limpia el historial de conversación y libera el contexto. **El hábito más importante para controlar costes** | Alias: `/reset`, `/new` |
| `/compact` | `/compact [instrucciones]` | Compacta la conversación con instrucciones de foco opcionales. Claude resume el contexto anterior preservando lo indicado | Sin instrucciones compacta con criterio propio; con instrucciones preserva lo especificado |
| `/resume` | `/resume [sesión]` | Reanuda una conversación por ID o nombre, o abre el selector de sesiones | Alias: `/continue` |
| `/rename` | `/rename [nombre]` | Renombra la sesión actual y muestra el nombre en la barra del prompt. Sin nombre, auto-genera uno a partir del historial | El nombre aparece en `/resume` y en el título del terminal |
| `/rewind` | `/rewind` | Retrocede la conversación y/o el código a un punto anterior, o resume desde un mensaje seleccionado | Alias: `/checkpoint`, `/undo`. Ver [checkpointing](https://code.claude.com/docs/en/checkpointing) |
| `/undo` | `/undo` | Alias de `/rewind`. Retrocede la conversación al punto anterior | Alias de `/rewind` |
| `/recap` | `/recap` | Genera un resumen de la sesión actual. También se activa automáticamente cuando Claude detecta una ausencia larga del usuario (away summary) | — |
| `/branch` | `/branch [nombre]` | Crea una rama de la conversación actual en este punto | Alias: `/fork` |
| `/export` | `/export [nombre-fichero]` | Exporta la conversación actual como texto plano. Con nombre, escribe al fichero. Sin nombre, ofrece copiar al portapapeles o guardar | — |

### Modelos y rendimiento

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/model` | `/model [modelo]` | Selecciona o cambia el modelo de IA. Con flechas izquierda/derecha, ajusta el nivel de esfuerzo para modelos que lo soportan. El cambio es inmediato | — |
| `/effort` | `/effort [low\|medium\|high\|xhigh\|max]` | Establece el nivel de esfuerzo del modelo. Sin argumento abre un slider interactivo para seleccionar el nivel. Con argumento: `low`, `medium`, `high`, `xhigh`, `max`. Los niveles `low`, `medium` y `high` persisten entre sesiones; `max` solo para la sesión actual | — |
| `/fast` | `/fast [on\|off]` | Activa o desactiva el modo rápido | — |
| `/powerup` | `/powerup` | Lecciones interactivas con demos animadas de features de Claude Code. Ideal para descubrir funcionalidades (v2.1.90) | — |
| `/loop` | `/loop [intervalo] <prompt>` | Skill que ejecuta un prompt repetidamente en un intervalo (ej: `/loop 5m comprueba si el deploy ha terminado`). El intervalo por defecto es 10 minutos | Alias: `/proactive` (v2.1.105). Es una skill bundled, no un comando built-in |

### Configuración e información

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/config` | `/config` | Abre la interfaz de Settings para ajustar tema, modelo, estilo de output, duración de turno y otras preferencias. Incluye toggle "Show turn duration" para mostrar cuánto tarda cada respuesta (v2.1.79+) | Alias: `/settings` |
| `/status` | `/status` | Abre la interfaz de Settings (pestaña Status) mostrando versión, modelo, cuenta y conectividad | — |
| `/context` | `/context` | Visualiza el uso actual del contexto como una cuadrícula de colores. Muestra sugerencias de optimización | — |
| `/usage` | `/usage` | Fusiona `/cost` y `/stats`. Muestra costes de la sesión (desglose por modelo y cache-hit) y estadísticas de uso diario, historial de sesiones, rachas y preferencias de modelos | — |
| `/cost` | `/cost` | Atajo de `/usage`. Muestra estadísticas de uso de tokens con desglose por modelo y cache-hit para usuarios de subscription (v2.1.92). Ver [guía de seguimiento de costes](https://code.claude.com/docs/en/costs) | Atajo de `/usage` |
| `/stats` | `/stats` | Atajo de `/usage`. Visualiza el uso diario, historial de sesiones, rachas y preferencias de modelos | Atajo de `/usage` |
| `/insights` | `/insights` | Genera un informe analizando tus sesiones de Claude Code: áreas del proyecto, patrones, puntos de fricción | — |

### Memoria y CLAUDE.md

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/memory` | `/memory` | Edita los ficheros de memoria `CLAUDE.md`, activa/desactiva auto-memory, y ver entradas de auto-memory | — |
| `/init` | `/init` | Inicializa el proyecto con una guía `CLAUDE.md`. Con `CLAUDE_CODE_NEW_INIT=true` arranca un flujo interactivo que también configura skills, hooks y ficheros de memoria personal | — |

### Herramientas, permisos y hooks

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/permissions` | `/permissions` | Ver o actualizar permisos. Muestra las herramientas permitidas y denegadas | Alias: `/allowed-tools` |
| `/hooks` | `/hooks` | Ver configuraciones de hooks para eventos de herramientas | — |

### MCP (Model Context Protocol)

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/mcp` | `/mcp` | Gestióna conexiones de servidores MCP y autenticación OAuth. Muestra conectores ocultos por duplicados con un hint para eliminarlos | — |

### Agentes y skills

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/agents` | `/agents` | Gestióna configuraciones de agentes | — |
| `/skills` | `/skills` | Lista las skills disponibles. Incluye caja de búsqueda type-to-filter para filtrar por nombre mientras escribes | — |
| `/less-permission-prompts` | `/less-permission-prompts` | Skill bundled que escanea los transcripts de la sesión y propone entradas para la allowlist de `settings.json`, reduciendo los prompts de permiso futuros | — |
| `/ultrareview` | `/ultrareview [<PR#>]` | Revisión de código multi-agente en la nube. Con número de PR lanza la revisión sobre ese PR; sin argumento, actúa sobre los cambios actuales | Ver también subcomando `claude ultrareview` para uso no-interactivo |
| `/plugin` | `/plugin` | Gestióna plugins de Claude Code | — |
| `/reload-plugins` | `/reload-plugins` | Recarga todos los plugins activos para aplicar cambios pendientes sin reiniciar. Reporta conteos y errores de carga | — |

### Edición y visualización

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/copy` | `/copy [N]` | Copia la última respuesta del asistente al portapapeles. Con número N, copia la N-esima respuesta más reciente. Muestra selector interactivo si hay bloques de código | — |
| `/diff` | `/diff` | Abre un visor de diff interactivo mostrando cambios sin commit y diffs por turno. Usa flechas izquierda/derecha para cambiar entre el diff de git y los turnos individuales | — |

### Preguntas laterales

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/btw` | `/btw <pregunta>` | Hace una pregunta rápida sin añadir al historial de conversación. La respuesta aparece en un overlay descartable | Funciona incluso mientras Claude está procesando. Sin acceso a herramientas |

### Modo Plan

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/plan` | `/plan` | Entra en modo plan directamente desde el prompt | Equivalente a `Shift+Tab` hasta llegar a Plan mode |
| `/ultraplan` | `/ultraplan [prompt]` | Inicia una sesión de planificación extendida con razonamiento profundo. Desde v2.1.101, auto-crea un entorno cloud por defecto sin necesidad de `--remote` | Combina effort max con sesión remota |

### Integraciónes

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/ide` | `/ide` | Gestióna integraciónes con IDEs y muestra el estado | — |
| `/chrome` | `/chrome` | Configura los ajustes de Claude en Chrome | — |
| `/install-github-app` | `/install-github-app` | Configura la GitHub App de Claude para un repositorio | Guia paso a paso para seleccionar repo y configurar la integración |
| `/install-slack-app` | `/install-slack-app` | Instala la app de Claude en Slack. Abre el navegador para completar el flujo OAuth | — |
| `/remote-control` | `/remote-control` | Hace que esta sesión este disponible para control remoto desde claude.ai | Alias: `/rc` |
| `/desktop` | `/desktop` | Continua la sesión actual en la app de escritorio de Claude Code | Solo macOS y Windows. Alias: `/app` |
| `/mobile` | `/mobile` | Muestra código QR para descargar la app móvil de Claude | Alias: `/ios`, `/android` |
| `/voice` | `/voice` | Activa el modo push-to-talk para dictado por voz. Mantener la barra espaciadora para hablar, soltarla para enviar. Soporta 20 idiomás | Requiere cuenta Claude.ai. Configurable en `/config`. Ver [atajos de teclado](./referencia-cli-atajos-teclado.md) para el atajo Space |
| `/schedule` | `/schedule [descripción]` | Crea, actualiza, lista o ejecuta táreas programadas en la nube (Cloud scheduled tasks) | — |

### Sesiones remotas

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/remote-env` | `/remote-env` | Configura el entorno remoto por defecto para sesiones web iniciadas con `--remote` | — |

### Diagnostico

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/doctor` | `/doctor` | Diagnostica y verifica la instalación y configuración de Claude Code. Desde v2.1.105 muestra iconos de estado y ofrece la opción `f` para que Claude repare automáticamente los problemás detectados | Útil para resolver problemás de configuración |
| `/feedback` | `/feedback [report]` | Envia feedback sobre Claude Code | Alias: `/bug` |
| `/team-onboarding` | `/team-onboarding` | Genera automáticamente una guía de rampa para nuevos miembros del equipo basándose en el uso local de Claude Code (CLAUDE.md, settings, skills, hooks configurados) | v2.1.101. Útil para documentar la configuración del equipo |

### Apariencia y renderizado

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/tui` | `/tui [fullscreen\|inline]` | Cambia el modo de renderizado para la sesión actual. `fullscreen` usa la pantalla completa con alt-screen; `inline` renderiza en flujo de texto normal | Persiste hasta cerrar la sesión. El valor por defecto se puede fijar con `tui` en `settings.json` |
| `/focus` | `/focus` | Activa la focus view: muestra solo el prompt, resumen de herramientas y respuesta final, ocultando el transcript completo | Antes se activaba con `Ctrl+O` en modo `NO_FLICKER`. Ahora `Ctrl+O` alterna normal/detallado |
| `/theme` | `/theme` | Cambia el tema de color. Incluye variantes claras y oscuras, temás para daltonismo, y temás ANSI | — |
| `/color` | `/color [color\|default]` | Establece el color de la barra del prompt para la sesión actual: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`. `default` para resetear | — |

### Editor

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/vim` | `/vim` | **[ELIMINADO en v2.1.92]** Alternaba entre modos Vim y Normal. Ahora se configura en `/config` → Editor mode | Deprecado: usar `/config` |

### Informacion del sistema

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/help` | `/help` | Muestra ayuda y comandos disponibles | — |
| `/keybindings` | `/keybindings` | Abre o crea el fichero de configuración de keybindings | — |
| `/terminal-setup` | `/terminal-setup` | Configura keybindings del terminal para Shift+Enter y otros atajos | Solo visible en terminales que lo necesitan |
| `/statusline` | `/statusline` | Configura la línea de estado de Claude Code. Sin argumentos, auto-configura desde el prompt del shell. Los scripts de statusline reciben el campo `rate_limits` con información sobre límites de uso actuales (v2.1.80+) | — |
| `/release-notes` | `/release-notes` | Abre un selector interactivo de versiones para navegar el changelog (v2.1.92). Antes mostraba el changelog completo | — |

### Autenticación

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/login` | `/login` | Inicia sesión en la cuenta de Anthropic | — |
| `/logout` | `/logout` | Cierra sesión de la cuenta de Anthropic | — |
| `/privacy-settings` | `/privacy-settings` | Ver y actualizar configuración de privacidad | Solo planes Pro y Max |
| `/upgrade` | `/upgrade` | Abre la pagina de upgrade para cambiar a un plan superior | Solo visible según el plan actual |

### Táreas en segundo plano

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/tasks` | `/tasks` | Lista y gestiona táreas en segundo plano | — |

### Directorios

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/add-dir` | `/add-dir <ruta>` | Añade un nuevo directorio de trabajo a la sesión actual | — |

### Otras opciones

| Comando | Sintaxis | Descripción | Notas |
|---------|----------|-------------|-------|
| `/sandbox` | `/sandbox` | Activa/desactiva el modo sandbox | Solo en plataformás compatibles |
| `/security-review` | `/security-review` | Analiza los cambios pendientes en el branch actual buscando vulnerabilidades. Revisa el git diff e identifica riesgos | — |
| `/pr-comments` | `/pr-comments [PR]` | Obtiene y muestra comentarios de un pull request de GitHub. Detecta el PR del branch actual automáticamente | Requiere `gh` CLI |
| `/extra-usage` | `/extra-usage` | Configura uso extra para seguir trabajando cuando se alcancen los rate limits | — |
| `/passes` | `/passes` | Comparte una semana gratuita de Claude Code con amigos | Solo visible si la cuenta es elegible |
| `/stickers` | `/stickers` | Pedir stickers de Claude Code | — |
| `/exit` | `/exit` | Sale del CLI | Alias: `/quit` |

---

## Prompts de servidores MCP

Los servidores MCP pueden exponer prompts que aparecen como comandos. Usan el formato:

```
/mcp__<servidor>__<prompt>
```

Estos comandos se descubren dinámicamente desde los servidores conectados. Por ejemplo, si tienes un servidor MCP llamado `github` con un prompt `create-pr`:

```
/mcp__github__create-pr
```

---

## Skills invocables como slash commands

Además de los comandos integrados, las **skills** de tu proyecto (ubicadas en `.claude/skills/`) son invocables directamente con `/nombre-skill`. Aparecen junto a los comandos integrados en el menú `/`.

```
/nombre-skill [argumentos]
```

Las skills del usuario global (`~/.claude/skills/`) también estan disponibles en todos los proyectos.

### Skills incluidas por defecto

Claude Code incluye algunas skills de serie que aparecen en el menú `/`:

| Skill | Descripción |
|-------|-------------|
| `/simplify` | Simplifica el código seleccionado |
| `/batch` | Procesa múltiples elementos en lote |
| `/debug` | Inicia un flujo de depuración guiado |
| `/claude-api` | Carga material de referencia del Claude API/SDK para construir aplicaciones con la API de Anthropic |
| `/loop` | Ejecuta un prompt repetidamente en un intervalo (ej: `/loop 5m comprueba el deploy`) |

### Crear skills personalizadas

Para crear una skill invocable como slash command, crea un directorio en `.claude/skills/nombre-skill/` con un fichero `SKILL.md`. Ver [estructura-carpeta-claude.md](./estructura-carpeta-claude.md) para la documentacion completa.

---

## Comandos heredados (legacy)

Los ficheros en `.claude/commands/` siguen funcionando como slash commands pero se recomienda usar `skills/` para nuevos comandos. El comando `/review` fue eliminado y requiere instalar el plugin `code-review`:

```
claude plugin install code-review@claude-code-marketplace
```

---

## Ver también

- [Atajos de teclado](./referencia-cli-atajos-teclado.md) — Atajos para usar junto a los slash commands
- [estructura-carpeta-claude.md](./estructura-carpeta-claude.md) — Cómo crear skills y agentes personalizados
- [Modos de ejecución](./referencia-cli-modos-ejecucion.md) — Los slash commands solo estan disponibles en modo interactivo
