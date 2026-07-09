# Estructura completa de la carpeta `.claude/` en un proyecto

> Referencia de todos los ficheros y directorios que puedes crear en la carpeta `.claude/` local de tu proyecto para configurar Claude Code.

---

## Vista general del árbol

```
mi-proyecto/
├── CLAUDE.md                          # Memoria compartida (raíz del proyecto)
├── CLAUDE.local.md                    # Memoria personal (gitignored)
├── .mcp.json                          # Servidores MCP del proyecto
│
└── .claude/
    ├── settings.json                  # Configuración compartida del proyecto
    ├── settings.local.json            # Configuración personal (gitignored)
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

## Ficheros de configuración

### `CLAUDE.md`

| Campo | Detalle |
|-------|---------|
| **Ubicación** | Raíz del proyecto o `.claude/CLAUDE.md` |
| **Compartido** | Sí (se commitea en git) |
| **Propósito** | Memoria persistente del proyecto que se carga automáticamente al iniciar sesión |

Contiene contexto del proyecto, convenciones de código, comandos útiles, estructura del repositorio, y cualquier instrucción que Claude deba conocer. Se puede generar automáticamente con `/init`.

Se pueden tener múltiples `CLAUDE.md` en distintos directorios (jerarquía). El más cercano al archivo en edición tiene prioridad.

```markdown
# Mi Proyecto

## Stack tecnológico
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
| **Ubicación** | Raíz del proyecto o `.claude/CLAUDE.local.md` |
| **Compartido** | No (gitignored automáticamente) |
| **Propósito** | Instrucciones personales que solo aplican a ti |

Ideal para preferencias individuales, rutas locales, o configuraciones que no quieres compartir con el equipo.

---

### `.claude/settings.json`

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `.claude/settings.json` |
| **Compartido** | Sí (se commitea en git) |
| **Propósito** | Configuración del proyecto: permisos, hooks, servidores MCP y plugins |

Es el fichero principal de configuración del proyecto. Se comparte con el equipo.

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
| `PostToolUse` | Después de que Claude use una herramienta |
| `PostToolUseFailure` | Cuando una herramienta falla |
| `Notification` | Cuando Claude genera una notificación |
| `Stop` | Cuando Claude termina su turno |
| `StopFailure` | Cuando Claude falla al detenerse |
| `SubagentStart` | Cuando un subagente inicia |
| `SubagentStop` | Cuando un subagente termina |
| `SessionStart` | Al iniciar o reanudar una sesión |
| `SessionEnd` | Al finalizar una sesión |
| `UserPromptSubmit` | Cuando el usuario envía un prompt |
| `PermissionRequest` | Cuando Claude solicita un permiso |
| `InstructionsLoaded` | Cuando se cargan las instrucciones (CLAUDE.md) |
| `TaskCreated` | Cuando se crea una tarea |
| `TaskCompleted` | Cuando se completa una tarea |
| `TeammateIdle` | Cuando un teammate de Agent Teams queda inactivo |
| `FileChanged` | Cuando un fichero cambia |
| `CwdChanged` | Cuando cambia el directorio de trabajo |
| `ConfigChange` | Cuando cambia la configuración |
| `PreCompact` | Antes de compactar el contexto |
| `PostCompact` | Después de compactar el contexto |
| `WorktreeCreate` | Cuando se crea un worktree |
| `WorktreeRemove` | Cuando se elimina un worktree |
| `Elicitation` | Cuando Claude solicita información al usuario |
| `ElicitationResult` | Cuando el usuario responde a una elicitacion |

---

### `.claude/settings.local.json`

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `.claude/settings.local.json` |
| **Compartido** | No (gitignored automáticamente) |
| **Propósito** | Sobreescrituras personales de configuración del proyecto |

Misma estructura que `settings.json`, pero para ajustes que no quieres compartir con el equipo (ej: permisos más permisivos para tu maquína de desarrollo).

---

### `.mcp.json`

| Campo | Detalle |
|-------|---------|
| **Ubicación** | Raíz del proyecto |
| **Compartido** | Si |
| **Propósito** | Configuración de servidores MCP a nivel de proyecto |

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
| **Propósito** | Definir agentes IA especializados para tareas concretas |

Cada subagente es un fichero Markdown con frontmatter YAML + un system prompt. Claude delega automáticamente a subagentes cuando la tarea encaja con su `description`.

**Campos del frontmatter:**

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| `name` | Si | Identificador único (minusculas y guiones) |
| `description` | Si | Cuando Claude debe delegar a este agente |
| `tools` | No | Herramientas permitidas. Si se omite, hereda todas |
| `disallowedTools` | No | Herramientas a denegar |
| `model` | No | `sonnet`, `opus`, `haiku` o `inherit` (por defecto) |
| `permissionMode` | No | `manual` (antes `default`), `acceptEdits`, `dontAsk`, `delegate`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Máximo de turnos del agente |
| `skills` | No | Skills a precargar en el contexto del agente |
| `mcpServers` | No | Servidores MCP disponibles para el agente |
| `hooks` | No | Hooks del ciclo de vida del agente |
| `memory` | No | Memoria persistente: `user`, `project` o `local` |

**Ejemplo:** `.claude/agents/revisor-código.md`

```markdown
---
name: revisor-código
description: Revisa código para calidad y buenas prácticas. Usar proactivamente después de cambios.
tools: Read, Grep, Glob, Bash
model: sonnet
---

Eres un revisor de código senior. Analiza el código y proporciona
feedback específico y accionable sobre calidad, seguridad y buenas prácticas.

Checklist de revisión:
- Código claro y legible
- Manejo adecuado de errores
- Sin secretos expuestos
- Validación de inputs
- Cobertura de tests
```

---

### `.claude/commands/` - Comandos slash personalizados (legacy)

| Campo | Detalle |
|-------|---------|
| **Compartido** | Si |
| **Propósito** | Crear atajos de prompts invocables con `/nombre` |

> **Nota:** Los commands han sido fusionados con skills. Los ficheros existentes en `commands/` siguen funcionando, pero se recomienda usar `skills/` para nuevos comandos.

Cada fichero `.md` en este directorio crea un comando `/nombre-del-fichero`. Soportan el mismo frontmatter que las skills.

**Ejemplo:** `.claude/commands/review-pr.md`

```markdown
---
description: Revisa el PR actual
---

Revisa el PR actual siguiendo nuestros estándares:

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
| **Propósito** | Extender las capacidades de Claude con instrucciones reutilizables |

Cada skill es un **directorio** con un fichero `SKILL.md` obligatorio y ficheros de soporte opcionales. Claude las usa automáticamente cuando son relevantes, o puedes invocarlas manualmente con `/nombre-skill`.

**Campos del frontmatter de SKILL.md:**

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| `name` | No | Nombre (por defecto usa el nombre del directorio) |
| `description` | Recomendado | Qué hace y cuándo usarla |
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
description: Despliega la aplicación a produccion
context: fork
disable-model-invocation: true
---

Despliega $ARGUMENTS a producción:

1. Ejecuta la suite de tests
2. Construye la aplicación
3. Publica en el target de despliegue
4. Verifica que el despliegue fue exitoso
```

**Sustituciones de variables disponibles en skills:**

| Variable | Descripción |
|----------|-------------|
| `$ARGUMENTS` | Todos los argumentos pasados |
| `$ARGUMENTS[N]` | Argumento por índice (base 0) |
| `$N` | Atajo para `$ARGUMENTS[N]` |
| `${CLAUDE_SESSION_ID}` | ID de la sesión actual |
| `` !`comando` `` | Inyección dinámica: ejecuta un comando shell y sustituye por su salida |

---

### `.claude/rules/` - Reglas de comportamiento

| Campo | Detalle |
|-------|---------|
| **Compartido** | Si |
| **Propósito** | Guías de comportamiento que se cargan automáticamente junto con CLAUDE.md |

Todos los ficheros Markdown en este directorio se cargan automáticamente con la misma prioridad que `CLAUDE.md`. No necesitan imports ni configuración adicional.

**Ejemplo:** `.claude/rules/estilo-código.md`

```markdown
# Reglas de estilo

- Usar TypeScript estricto en todo el proyecto
- Funciones puras siempre que sea posible
- Máximo 80 caracteres por línea
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
| **Propósito** | Conocimiento acumulado por subagentes entre sesiones |

Cuando un subagente tiene `memory: project` en su frontmatter, almacena aquí sus aprendizajes. Cada agente tiene su propia subcarpeta con un `MEMORY.md`.

---

### `.claude/agent-memory-local/` - Memoria persistente de agentes (local)

| Campo | Detalle |
|-------|---------|
| **Compartido** | No (gitignored) |
| **Propósito** | Igual que `agent-memory/` pero para conocimiento que no se commitea |

Se activa con `memory: local` en el frontmatter del subagente.

---

## Fichero `.claude/.gitignore` recomendado

```gitignore
# Configuración personal (no compartir)
settings.local.json
CLAUDE.local.md
agent-memory-local/

# Nota: settings.json, CLAUDE.md, agents/, commands/,
# skills/ y rules/ SI deben commitearse
```

---

## Jerarquía de prioridad

Los ajustes se resuelven de mayor a menor prioridad:

| Prioridad | Origen | Ejemplo |
|-----------|--------|---------|
| 1 (mayor) | Gestionado (enterprise) | Políticas de la organización |
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
| `CLAUDE.md` (raíz) | `~/CLAUDE.md` |

---

## Referencias

- [Documentación oficial de Claude Code - Settings](https://code.claude.com/docs/en/settings)
- [Documentación oficial - Subagentes](https://code.claude.com/docs/en/sub-agents)
- [Documentación oficial - Skills](https://code.claude.com/docs/en/skills)
- [Documentación oficial - Hooks](https://code.claude.com/docs/en/hooks)
- [Blog: Using CLAUDE.md files](https://claude.com/blog/using-claude-md-files)
- [Blog: How to configure hooks](https://claude.com/blog/how-to-configure-hooks)
- [Ejemplo completo de configuración](https://github.com/ChrisWiles/claude-code-showcase)
