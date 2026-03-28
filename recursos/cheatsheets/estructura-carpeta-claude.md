# Estructura completa de la carpeta `.claude/` en un proyecto

> Referencia de todos los ficheros y directorios que puedes crear en la carpeta `.claude/` local de tu proyecto para configurar Claude Code.

---

## Vista general del arbol

```
mi-proyecto/
├── CLAUDE.md                          # Memoria compartida (raiz del proyecto)
├── CLAUDE.local.md                    # Memoria personal (gitignored)
├── .mcp.json                          # Servidores MCP del proyecto
│
└── .claude/
    ├── settings.json                  # Configuracion compartida del proyecto
    ├── settings.local.json            # Configuracion personal (gitignored)
    ├── CLAUDE.md                      # Memoria alternativa (dentro de .claude/)
    ├── CLAUDE.local.md                # Memoria personal alternativa
    ├── .gitignore                     # Ignorar ficheros locales/personales
    │
    ├── agents/                        # Subagentes personalizados
    │   └── <nombre-agente>.md
    │
    ├── commands/                      # Comandos slash personalizados (legacy)
    │   └── <nombre-comando>.md
    │
    ├── skills/                        # Skills del proyecto
    │   └── <nombre-skill>/
    │       ├── SKILL.md               # Instrucciones principales (obligatorio)
    │       ├── template.md            # Plantillas opcionales
    │       ├── examples/              # Ejemplos opcionales
    │       └── scripts/               # Scripts auxiliares
    │
    ├── rules/                         # Reglas de comportamiento
    │   └── <nombre-regla>.md
    │
    ├── agent-memory/                  # Memoria persistente de agentes (compartida)
    │   └── <nombre-agente>/
    │       └── MEMORY.md
    │
    └── agent-memory-local/            # Memoria persistente de agentes (local)
        └── <nombre-agente>/
            └── MEMORY.md
```

---

## Ficheros de configuracion

### `CLAUDE.md`

| Campo | Detalle |
|-------|---------|
| **Ubicacion** | Raiz del proyecto o `.claude/CLAUDE.md` |
| **Compartido** | Si (se commitea en git) |
| **Proposito** | Memoria persistente del proyecto que se carga automaticamente al iniciar sesion |

Contiene contexto del proyecto, convenciones de codigo, comandos utiles, estructura del repositorio, y cualquier instruccion que Claude deba conocer. Se puede generar automaticamente con `/init`.

Se pueden tener multiples `CLAUDE.md` en distintos directorios (jerarquia). El mas cercano al archivo en edicion tiene prioridad.

```markdown
# Mi Proyecto

## Stack tecnologico
- Frontend: React + TypeScript
- Backend: Node.js + Express

## Convenciones
- Usar camelCase para variables
- Tests con Jest
```

---

### `CLAUDE.local.md`

| Campo | Detalle |
|-------|---------|
| **Ubicacion** | Raiz del proyecto o `.claude/CLAUDE.local.md` |
| **Compartido** | No (gitignored automaticamente) |
| **Proposito** | Instrucciones personales que solo aplican a ti |

Ideal para preferencias individuales, rutas locales, o configuraciones que no quieres compartir con el equipo.

---

### `.claude/settings.json`

| Campo | Detalle |
|-------|---------|
| **Ubicacion** | `.claude/settings.json` |
| **Compartido** | Si (se commitea en git) |
| **Proposito** | Configuracion del proyecto: permisos, hooks, servidores MCP y plugins |

Es el fichero principal de configuracion del proyecto. Se comparte con el equipo.

```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep", "Bash(npm test *)"],
    "deny": ["Task(Explore)"]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/validar-comando.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint:fix"
          }
        ]
      }
    ]
  },
  "mcpServers": {
    "mi-servidor": {
      "command": "npx",
      "args": ["-y", "mi-mcp-server"]
    }
  },
  "env": {
    "NODE_ENV": "development"
  }
}
```

**Eventos de hooks disponibles (25 eventos):**

| Evento | Cuando se ejecuta |
|--------|-------------------|
| `PreToolUse` | Antes de que Claude use una herramienta |
| `PostToolUse` | Despues de que Claude use una herramienta |
| `PostToolUseFailure` | Cuando una herramienta falla |
| `Notification` | Cuando Claude genera una notificacion |
| `Stop` | Cuando Claude termina su turno |
| `StopFailure` | Cuando Claude falla al detenerse |
| `SubagentStart` | Cuando un subagente inicia |
| `SubagentStop` | Cuando un subagente termina |
| `SessionStart` | Al iniciar o reanudar una sesion |
| `SessionEnd` | Al finalizar una sesion |
| `UserPromptSubmit` | Cuando el usuario envia un prompt |
| `PermissionRequest` | Cuando Claude solicita un permiso |
| `InstructionsLoaded` | Cuando se cargan las instrucciones (CLAUDE.md) |
| `TaskCreated` | Cuando se crea una tarea |
| `TaskCompleted` | Cuando se completa una tarea |
| `TeammateIdle` | Cuando un teammate de Agent Teams queda inactivo |
| `FileChanged` | Cuando un fichero cambia |
| `CwdChanged` | Cuando cambia el directorio de trabajo |
| `ConfigChange` | Cuando cambia la configuracion |
| `PreCompact` | Antes de compactar el contexto |
| `PostCompact` | Despues de compactar el contexto |
| `WorktreeCreate` | Cuando se crea un worktree |
| `WorktreeRemove` | Cuando se elimina un worktree |
| `Elicitation` | Cuando Claude solicita informacion al usuario |
| `ElicitationResult` | Cuando el usuario responde a una elicitacion |

---

### `.claude/settings.local.json`

| Campo | Detalle |
|-------|---------|
| **Ubicacion** | `.claude/settings.local.json` |
| **Compartido** | No (gitignored automaticamente) |
| **Proposito** | Sobreescrituras personales de configuracion del proyecto |

Misma estructura que `settings.json`, pero para ajustes que no quieres compartir con el equipo (ej: permisos mas permisivos para tu maquina de desarrollo).

---

### `.mcp.json`

| Campo | Detalle |
|-------|---------|
| **Ubicacion** | Raiz del proyecto |
| **Compartido** | Si |
| **Proposito** | Configuracion de servidores MCP a nivel de proyecto |

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

---

## Directorios

### `.claude/agents/` - Subagentes personalizados

| Campo | Detalle |
|-------|---------|
| **Compartido** | Si |
| **Proposito** | Definir agentes IA especializados para tareas concretas |

Cada subagente es un fichero Markdown con frontmatter YAML + un system prompt. Claude delega automaticamente a subagentes cuando la tarea encaja con su `description`.

**Campos del frontmatter:**

| Campo | Obligatorio | Descripcion |
|-------|-------------|-------------|
| `name` | Si | Identificador unico (minusculas y guiones) |
| `description` | Si | Cuando Claude debe delegar a este agente |
| `tools` | No | Herramientas permitidas. Si se omite, hereda todas |
| `disallowedTools` | No | Herramientas a denegar |
| `model` | No | `sonnet`, `opus`, `haiku` o `inherit` (por defecto) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `delegate`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Maximo de turnos del agente |
| `skills` | No | Skills a precargar en el contexto del agente |
| `mcpServers` | No | Servidores MCP disponibles para el agente |
| `hooks` | No | Hooks del ciclo de vida del agente |
| `memory` | No | Memoria persistente: `user`, `project` o `local` |

**Ejemplo:** `.claude/agents/revisor-codigo.md`

```markdown
---
name: revisor-codigo
description: Revisa codigo para calidad y buenas practicas. Usar proactivamente despues de cambios.
tools: Read, Grep, Glob, Bash
model: sonnet
---

Eres un revisor de codigo senior. Analiza el codigo y proporciona
feedback especifico y accionable sobre calidad, seguridad y buenas practicas.

Checklist de revision:
- Codigo claro y legible
- Manejo adecuado de errores
- Sin secretos expuestos
- Validacion de inputs
- Cobertura de tests
```

---

### `.claude/commands/` - Comandos slash personalizados (legacy)

| Campo | Detalle |
|-------|---------|
| **Compartido** | Si |
| **Proposito** | Crear atajos de prompts invocables con `/nombre` |

> **Nota:** Los commands han sido fusionados con skills. Los ficheros existentes en `commands/` siguen funcionando, pero se recomienda usar `skills/` para nuevos comandos.

Cada fichero `.md` en este directorio crea un comando `/nombre-del-fichero`. Soportan el mismo frontmatter que las skills.

**Ejemplo:** `.claude/commands/review-pr.md`

```markdown
---
description: Revisa el PR actual
---

Revisa el PR actual siguiendo nuestros estandares:

1. Lee el diff con `gh pr diff`
2. Analiza los cambios
3. Genera un resumen con puntos clave
```

Se invoca con: `/review-pr`

---

### `.claude/skills/` - Skills del proyecto

| Campo | Detalle |
|-------|---------|
| **Compartido** | Si |
| **Proposito** | Extender las capacidades de Claude con instrucciones reutilizables |

Cada skill es un **directorio** con un fichero `SKILL.md` obligatorio y ficheros de soporte opcionales. Claude las usa automaticamente cuando son relevantes, o puedes invocarlas manualmente con `/nombre-skill`.

**Campos del frontmatter de SKILL.md:**

| Campo | Obligatorio | Descripcion |
|-------|-------------|-------------|
| `name` | No | Nombre (por defecto usa el nombre del directorio) |
| `description` | Recomendado | Que hace y cuando usarla |
| `argument-hint` | No | Pista para argumentos (ej: `[issue-number]`) |
| `disable-model-invocation` | No | `true` = solo invocacion manual con `/nombre` |
| `user-invocable` | No | `false` = oculta del menu `/`, solo para Claude |
| `allowed-tools` | No | Herramientas permitidas sin pedir permiso |
| `model` | No | Modelo a usar cuando la skill esta activa |
| `context` | No | `fork` = ejecutar en un subagente aislado |
| `agent` | No | Tipo de subagente cuando `context: fork` |
| `hooks` | No | Hooks del ciclo de vida de la skill |

**Ejemplo:** `.claude/skills/deploy/SKILL.md`

```yaml
---
name: deploy
description: Despliega la aplicacion a produccion
context: fork
disable-model-invocation: true
---

Despliega $ARGUMENTS a produccion:

1. Ejecuta la suite de tests
2. Construye la aplicacion
3. Publica en el target de despliegue
4. Verifica que el despliegue fue exitoso
```

**Sustituciones de variables disponibles en skills:**

| Variable | Descripcion |
|----------|-------------|
| `$ARGUMENTS` | Todos los argumentos pasados |
| `$ARGUMENTS[N]` | Argumento por indice (base 0) |
| `$N` | Atajo para `$ARGUMENTS[N]` |
| `${CLAUDE_SESSION_ID}` | ID de la sesion actual |
| `` !`comando` `` | Inyeccion dinamica: ejecuta un comando shell y sustituye por su salida |

---

### `.claude/rules/` - Reglas de comportamiento

| Campo | Detalle |
|-------|---------|
| **Compartido** | Si |
| **Proposito** | Guias de comportamiento que se cargan automaticamente junto con CLAUDE.md |

Todos los ficheros Markdown en este directorio se cargan automaticamente con la misma prioridad que `CLAUDE.md`. No necesitan imports ni configuracion adicional.

**Ejemplo:** `.claude/rules/estilo-codigo.md`

```markdown
# Reglas de estilo

- Usar TypeScript estricto en todo el proyecto
- Funciones puras siempre que sea posible
- Maximo 80 caracteres por linea
- Imports agrupados: stdlib > terceros > locales
```

**Ejemplo:** `.claude/rules/seguridad.md`

```markdown
# Reglas de seguridad

- Nunca hardcodear secretos o API keys
- Validar todos los inputs del usuario
- Usar consultas parametrizadas para SQL
- Sanitizar output para prevenir XSS
```

---

### `.claude/agent-memory/` - Memoria persistente de agentes (compartida)

| Campo | Detalle |
|-------|---------|
| **Compartido** | Si (se puede commitear) |
| **Proposito** | Conocimiento acumulado por subagentes entre sesiones |

Cuando un subagente tiene `memory: project` en su frontmatter, almacena aqui sus aprendizajes. Cada agente tiene su propia subcarpeta con un `MEMORY.md`.

---

### `.claude/agent-memory-local/` - Memoria persistente de agentes (local)

| Campo | Detalle |
|-------|---------|
| **Compartido** | No (gitignored) |
| **Proposito** | Igual que `agent-memory/` pero para conocimiento que no se commitea |

Se activa con `memory: local` en el frontmatter del subagente.

---

## Fichero `.claude/.gitignore` recomendado

```gitignore
# Configuracion personal (no compartir)
settings.local.json
CLAUDE.local.md
agent-memory-local/

# Nota: settings.json, CLAUDE.md, agents/, commands/,
# skills/ y rules/ SI deben commitearse
```

---

## Jerarquia de prioridad

Los ajustes se resuelven de mayor a menor prioridad:

| Prioridad | Origen | Ejemplo |
|-----------|--------|---------|
| 1 (mayor) | Gestionado (enterprise) | Politicas de la organizacion |
| 2 | Argumentos CLI | `--model opus`, `--agents '{...}'` |
| 3 | Local del proyecto | `.claude/settings.local.json`, `CLAUDE.local.md` |
| 4 | Proyecto | `.claude/settings.json`, `CLAUDE.md` |
| 5 (menor) | Usuario global | `~/.claude/settings.json`, `~/CLAUDE.md` |

---

## Equivalencia proyecto vs. usuario global

Casi todos los directorios de `.claude/` del proyecto tienen un equivalente en `~/.claude/` (home del usuario) que aplica a **todos** los proyectos:

| Proyecto (local) | Usuario (global) |
|-------------------|------------------|
| `.claude/settings.json` | `~/.claude/settings.json` |
| `.claude/agents/` | `~/.claude/agents/` |
| `.claude/commands/` | `~/.claude/commands/` |
| `.claude/skills/` | `~/.claude/skills/` |
| `CLAUDE.md` (raiz) | `~/CLAUDE.md` |

---

## Referencias

- [Documentacion oficial de Claude Code - Settings](https://code.claude.com/docs/en/settings)
- [Documentacion oficial - Subagentes](https://code.claude.com/docs/en/sub-agents)
- [Documentacion oficial - Skills](https://code.claude.com/docs/en/skills)
- [Documentacion oficial - Hooks](https://code.claude.com/docs/en/hooks)
- [Blog: Using CLAUDE.md files](https://claude.com/blog/using-claude-md-files)
- [Blog: How to configure hooks](https://claude.com/blog/how-to-configure-hooks)
- [Ejemplo completo de configuracion](https://github.com/ChrisWiles/claude-code-showcase)
