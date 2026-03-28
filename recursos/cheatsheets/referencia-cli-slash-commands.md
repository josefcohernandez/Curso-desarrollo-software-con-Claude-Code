# Referencia CLI — Slash Commands

> Documentacion exhaustiva de todos los slash commands disponibles en el modo interactivo de Claude Code.

Indice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Como funcionan los slash commands

Los slash commands se invocan escribiendo `/` seguido del nombre del comando en el prompt interactivo. Al escribir `/` aparece un menu con todos los comandos disponibles y las skills del proyecto. Puedes filtrar escribiendo letras adicionales.

```
/                      → abre el menu de comandos
/cl                    → filtra y muestra /clear, /color, /compact, /copy, /cost, /context...
/clear                 → ejecuta el comando directamente
```

**Nota:** No todos los comandos son visibles para todos los usuarios. Algunos dependen de la plataforma, el plan, o el entorno. Por ejemplo, `/desktop` solo aparece en macOS y Windows, `/upgrade` solo en planes Pro y Max, y `/terminal-setup` se oculta cuando el terminal ya soporta sus keybindings de forma nativa.

---

## Referencia completa de comandos integrados

### Gestion de sesion y contexto

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/clear` | `/clear` | Limpia el historial de conversacion y libera el contexto. **El habito mas importante para controlar costes** | Alias: `/reset`, `/new` |
| `/compact` | `/compact [instrucciones]` | Compacta la conversacion con instrucciones de foco opcionales. Claude resume el contexto anterior preservando lo indicado | Sin instrucciones compacta con criterio propio; con instrucciones preserva lo especificado |
| `/resume` | `/resume [sesion]` | Reanuda una conversacion por ID o nombre, o abre el selector de sesiones | Alias: `/continue` |
| `/rename` | `/rename [nombre]` | Renombra la sesion actual y muestra el nombre en la barra del prompt. Sin nombre, auto-genera uno a partir del historial | El nombre aparece en `/resume` y en el titulo del terminal |
| `/rewind` | `/rewind` | Retrocede la conversacion y/o el codigo a un punto anterior, o resume desde un mensaje seleccionado | Alias: `/checkpoint`. Ver [checkpointing](https://code.claude.com/docs/en/checkpointing) |
| `/branch` | `/branch [nombre]` | Crea una rama de la conversacion actual en este punto | Alias: `/fork` |
| `/export` | `/export [nombre-fichero]` | Exporta la conversacion actual como texto plano. Con nombre, escribe al fichero. Sin nombre, ofrece copiar al portapapeles o guardar | — |

### Modelos y rendimiento

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/model` | `/model [modelo]` | Selecciona o cambia el modelo de IA. Con flechas izquierda/derecha, ajusta el nivel de esfuerzo para modelos que lo soportan. El cambio es inmediato | — |
| `/effort` | `/effort [low\|medium\|high\|max]` | Establece el nivel de esfuerzo del modelo. `low`, `medium`, `high` persisten entre sesiones. `max` solo para la sesion actual (requiere Opus 4.6) | Sin argumento muestra el nivel actual |
| `/fast` | `/fast [on\|off]` | Activa o desactiva el modo rapido | — |
| `/loop` | `/loop [intervalo] <prompt>` | Skill que ejecuta un prompt repetidamente en un intervalo (ej: `/loop 5m comprueba si el deploy ha terminado`). El intervalo por defecto es 10 minutos | Es una skill bundled, no un comando built-in |

### Configuracion e informacion

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/config` | `/config` | Abre la interfaz de Settings para ajustar tema, modelo, estilo de output, y otras preferencias | Alias: `/settings` |
| `/status` | `/status` | Abre la interfaz de Settings (pestana Status) mostrando version, modelo, cuenta y conectividad | — |
| `/context` | `/context` | Visualiza el uso actual del contexto como una cuadricula de colores. Muestra sugerencias de optimizacion | — |
| `/cost` | `/cost` | Muestra estadisticas de uso de tokens. Ver [guia de seguimiento de costes](https://code.claude.com/docs/en/costs) | — |
| `/usage` | `/usage` | Muestra los limites del plan y el estado de los rate limits | — |
| `/stats` | `/stats` | Visualiza el uso diario, historial de sesiones, rachas y preferencias de modelos | — |
| `/insights` | `/insights` | Genera un informe analizando tus sesiones de Claude Code: areas del proyecto, patrones, puntos de friccion | — |

### Memoria y CLAUDE.md

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/memory` | `/memory` | Edita los ficheros de memoria `CLAUDE.md`, activa/desactiva auto-memory, y ver entradas de auto-memory | — |
| `/init` | `/init` | Inicializa el proyecto con una guia `CLAUDE.md`. Con `CLAUDE_CODE_NEW_INIT=true` arranca un flujo interactivo que tambien configura skills, hooks y ficheros de memoria personal | — |

### Herramientas, permisos y hooks

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/permissions` | `/permissions` | Ver o actualizar permisos. Muestra las herramientas permitidas y denegadas | Alias: `/allowed-tools` |
| `/hooks` | `/hooks` | Ver configuraciones de hooks para eventos de herramientas | — |

### MCP (Model Context Protocol)

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/mcp` | `/mcp` | Gestiona conexiones de servidores MCP y autenticacion OAuth | — |

### Agentes y skills

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/agents` | `/agents` | Gestiona configuraciones de agentes | — |
| `/skills` | `/skills` | Lista las skills disponibles | — |
| `/plugin` | `/plugin` | Gestiona plugins de Claude Code | — |
| `/reload-plugins` | `/reload-plugins` | Recarga todos los plugins activos para aplicar cambios pendientes sin reiniciar. Reporta conteos y errores de carga | — |

### Edicion y visualizacion

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/copy` | `/copy [N]` | Copia la ultima respuesta del asistente al portapapeles. Con numero N, copia la N-esima respuesta mas reciente. Muestra selector interactivo si hay bloques de codigo | — |
| `/diff` | `/diff` | Abre un visor de diff interactivo mostrando cambios sin commit y diffs por turno. Usa flechas izquierda/derecha para cambiar entre el diff de git y los turnos individuales | — |

### Preguntas laterales

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/btw` | `/btw <pregunta>` | Hace una pregunta rapida sin anadir al historial de conversacion. La respuesta aparece en un overlay descartable | Funciona incluso mientras Claude esta procesando. Sin acceso a herramientas |

### Modo Plan

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/plan` | `/plan` | Entra en modo plan directamente desde el prompt | Equivalente a `Shift+Tab` hasta llegar a Plan mode |

### Integraciones

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/ide` | `/ide` | Gestiona integraciones con IDEs y muestra el estado | — |
| `/chrome` | `/chrome` | Configura los ajustes de Claude en Chrome | — |
| `/install-github-app` | `/install-github-app` | Configura la GitHub App de Claude para un repositorio | Guia paso a paso para seleccionar repo y configurar la integracion |
| `/install-slack-app` | `/install-slack-app` | Instala la app de Claude en Slack. Abre el navegador para completar el flujo OAuth | — |
| `/remote-control` | `/remote-control` | Hace que esta sesion este disponible para control remoto desde claude.ai | Alias: `/rc` |
| `/desktop` | `/desktop` | Continua la sesion actual en la app de escritorio de Claude Code | Solo macOS y Windows. Alias: `/app` |
| `/mobile` | `/mobile` | Muestra codigo QR para descargar la app movil de Claude | Alias: `/ios`, `/android` |
| `/voice` | `/voice` | Activa el modo push-to-talk para dictado por voz. Mantener la barra espaciadora para hablar, soltarla para enviar. Soporta 20 idiomas | Requiere cuenta Claude.ai. Configurable en `/config`. Ver [atajos de teclado](./referencia-cli-atajos-teclado.md) para el atajo Space |
| `/schedule` | `/schedule [descripcion]` | Crea, actualiza, lista o ejecuta tareas programadas en la nube (Cloud scheduled tasks) | — |

### Sesiones remotas

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/remote-env` | `/remote-env` | Configura el entorno remoto por defecto para sesiones web iniciadas con `--remote` | — |

### Diagnostico

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/doctor` | `/doctor` | Diagnostica y verifica la instalacion y configuracion de Claude Code | Util para resolver problemas de configuracion |
| `/feedback` | `/feedback [report]` | Envia feedback sobre Claude Code | Alias: `/bug` |

### Apariencia

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/theme` | `/theme` | Cambia el tema de color. Incluye variantes claras y oscuras, temas para daltonismo, y temas ANSI | — |
| `/color` | `/color [color\|default]` | Establece el color de la barra del prompt para la sesion actual: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`. `default` para resetear | — |

### Editor

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/vim` | `/vim` | Alterna entre los modos de edicion Vim y Normal | Se puede configurar de forma permanente en `/config` |

### Informacion del sistema

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/help` | `/help` | Muestra ayuda y comandos disponibles | — |
| `/keybindings` | `/keybindings` | Abre o crea el fichero de configuracion de keybindings | — |
| `/terminal-setup` | `/terminal-setup` | Configura keybindings del terminal para Shift+Enter y otros atajos | Solo visible en terminales que lo necesitan |
| `/statusline` | `/statusline` | Configura la linea de estado de Claude Code. Sin argumentos, auto-configura desde el prompt del shell | — |
| `/release-notes` | `/release-notes` | Ver el changelog completo, con la version mas reciente mas proxima al prompt | — |

### Autenticacion

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/login` | `/login` | Inicia sesion en la cuenta de Anthropic | — |
| `/logout` | `/logout` | Cierra sesion de la cuenta de Anthropic | — |
| `/privacy-settings` | `/privacy-settings` | Ver y actualizar configuracion de privacidad | Solo planes Pro y Max |
| `/upgrade` | `/upgrade` | Abre la pagina de upgrade para cambiar a un plan superior | Solo visible segun el plan actual |

### Tareas en segundo plano

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/tasks` | `/tasks` | Lista y gestiona tareas en segundo plano | — |

### Directorios

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/add-dir` | `/add-dir <ruta>` | Anade un nuevo directorio de trabajo a la sesion actual | — |

### Otras opciones

| Comando | Sintaxis | Descripcion | Notas |
|---------|----------|-------------|-------|
| `/sandbox` | `/sandbox` | Activa/desactiva el modo sandbox | Solo en plataformas compatibles |
| `/security-review` | `/security-review` | Analiza los cambios pendientes en el branch actual buscando vulnerabilidades. Revisa el git diff e identifica riesgos | — |
| `/pr-comments` | `/pr-comments [PR]` | Obtiene y muestra comentarios de un pull request de GitHub. Detecta el PR del branch actual automaticamente | Requiere `gh` CLI |
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

Estos comandos se descubren dinamicamente desde los servidores conectados. Por ejemplo, si tienes un servidor MCP llamado `github` con un prompt `create-pr`:

```
/mcp__github__create-pr
```

---

## Skills invocables como slash commands

Ademas de los comandos integrados, las **skills** de tu proyecto (ubicadas en `.claude/skills/`) son invocables directamente con `/nombre-skill`. Aparecen junto a los comandos integrados en el menu `/`.

```
/nombre-skill [argumentos]
```

Las skills del usuario global (`~/.claude/skills/`) tambien estan disponibles en todos los proyectos.

### Skills incluidas por defecto

Claude Code incluye algunas skills de serie que aparecen en el menu `/`:

| Skill | Descripcion |
|-------|-------------|
| `/simplify` | Simplifica el codigo seleccionado |
| `/batch` | Procesa multiples elementos en lote |
| `/debug` | Inicia un flujo de depuracion guiado |
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

## Ver tambien

- [Atajos de teclado](./referencia-cli-atajos-teclado.md) — Atajos para usar junto a los slash commands
- [estructura-carpeta-claude.md](./estructura-carpeta-claude.md) — Como crear skills y agentes personalizados
- [Modos de ejecucion](./referencia-cli-modos-ejecucion.md) — Los slash commands solo estan disponibles en modo interactivo
