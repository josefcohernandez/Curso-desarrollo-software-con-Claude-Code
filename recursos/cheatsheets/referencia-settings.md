# Referencia — Settings y configuración (`settings.json`)

> Documentación exhaustiva de todas las claves disponibles en los ficheros de configuración de Claude Code: `.claude/settings.json`, `.claude/settings.local.json` y `~/.claude/settings.json`.

Índice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Ficheros de configuración

Claude Code resuelve la configuración fusionando varios ficheros en orden de prioridad:

| Prioridad | Fichero | Compartido | Descripción |
|-----------|---------|------------|-------------|
| 1 (mayor) | Managed (enterprise) | — | Políticas de la organización, no se pueden anular |
| 2 | Argumentos CLI | — | `--settings`, `--setting-sources`, flags de arranque |
| 3 | `.claude/settings.local.json` | No (gitignored) | Configuración personal del proyecto |
| 4 | `.claude/settings.json` | Sí | Configuración compartida del proyecto |
| 5 (menor) | `~/.claude/settings.json` | — | Configuración global del usuario |

Los arrays (permisos, hooks, etc.) se **concatenan y desduplicam** en lugar de reemplazarse. Los valores escalares siguen la prioridad: la fuente de mayor prioridad gana.

---

## Esquema general

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",

  "model": "claude-sonnet-4-6",
  "effortLevel": "high",
  "alwaysThinkingEnabled": true,
  "agent": "mi-agente",
  "language": "spanish",

  "tui": "fullscreen",
  "autoScrollEnabled": false,
  "editorMode": "vim",

  "permissions": {},
  "sandbox": {},
  "autoMode": {},

  "env": {},
  "hooks": {},
  "mcpServers": {},

  "prUrlTemplate": "https://reviews.example.com/{owner}/{repo}/pull/{number}",
  "attribution": {},
  "companyAnnouncements": []
}
```

---

## Modelo y razonamiento

| Clave | Tipo | Valores | Descripción |
|-------|------|---------|-------------|
| `model` | string | `"claude-sonnet-4-6"`, `"opus"`, ... | Modelo por defecto para la sesión |
| `effortLevel` | string | `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` | Nivel de esfuerzo persistente. `"max"` no persiste entre sesiones |
| `alwaysThinkingEnabled` | boolean | `true` / `false` | Activa el extended thinking de forma permanente |
| `agent` | string | nombre del agente | Agente por defecto para el proyecto |

---

## Interfaz y renderizado

| Clave | Tipo | Valores | Descripción |
|-------|------|---------|-------------|
| `tui` | string | `"fullscreen"` / `"inline"` | Modo de renderizado por defecto. `"fullscreen"` usa alt-screen sin parpadeo con scrollback virtualizado; `"inline"` renderiza en flujo de texto normal. Se puede cambiar en sesión con `/tui` |
| `autoScrollEnabled` | boolean | `true` / `false` | Auto-scroll al final de la salida en modo `fullscreen`. `false` para deshabilitar. Los prompts de permisos siempre se desplazan a la vista independientemente de este valor. Configurable en `/config` |
| `editorMode` | string | `"vim"` / `"emacs"` / `"default"` | Modo de edición del prompt. Configurable en `/config` |
| `language` | string | `"spanish"`, `"english"`, ... | Idioma de la interfaz |

### Ejemplo

```json
{
  "tui": "fullscreen",
  "autoScrollEnabled": false,
  "editorMode": "vim"
}
```

---

## Permisos

### Estructura

```json
{
  "permissions": {
    "allow": [],
    "deny": [],
    "ask": [],
    "additionalDirectories": [],
    "defaultMode": "default",
    "disableBypassPermissionsMode": "disable",
    "skipDangerousModePermissionPrompt": true
  }
}
```

### Claves de permisos

| Clave | Tipo | Descripción |
|-------|------|-------------|
| `allow` | array | Reglas que se ejecutan sin pedir permiso |
| `deny` | array | Reglas bloqueadas. Claude no puede ejecutarlas aunque el usuario lo pida |
| `ask` | array | Reglas que requieren confirmación explícita del usuario |
| `additionalDirectories` | array | Directorios adicionales a los que Claude puede acceder con Read/Edit |
| `defaultMode` | string | Modo de permisos por defecto al arrancar: `"default"`, `"acceptEdits"`, `"plan"`, `"bypassPermissions"` |
| `disableBypassPermissionsMode` | string | `"disable"` para evitar que se active `bypassPermissions` |
| `skipDangerousModePermissionPrompt` | boolean | `true` para saltar el prompt de confirmación al entrar en modo `bypassPermissions` |

### Sintaxis de reglas

| Regla | Efecto |
|-------|--------|
| `"Bash"` | Todos los comandos Bash |
| `"Bash(npm run *)"` | Comandos que empiezan por `npm run` |
| `"Bash(git log *)"` | Comandos que empiezan por `git log` |
| `"Read(~/.zshrc)"` | Lectura del fichero `.zshrc` del usuario |
| `"Read(./.env)"` | Lectura del fichero `.env` del proyecto |
| `"Edit(./src/**)"` | Editar cualquier fichero bajo `src/` |
| `"WebFetch(domain:example.com)"` | Peticiones fetch a `example.com` |
| `"Task(Explore)"` | Limitar uso de subagentes de exploración |

**Evaluación**: `deny` → `ask` → `allow` (la primera coincidencia gana).

### Ejemplo completo de permisos

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(npm run *)",
      "Bash(git log *)",
      "Bash(git diff *)"
    ],
    "deny": [
      "Bash(curl *)",
      "Bash(wget *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  }
}
```

---

## Sandbox y red

```json
{
  "sandbox": {
    "network": {
      "allowedDomains": ["api.github.com", "*.npmjs.com"],
      "deniedDomains": ["sensitive.internal.example.com"]
    }
  }
}
```

| Clave | Tipo | Descripción |
|-------|------|-------------|
| `sandbox.network.allowedDomains` | array | Dominios permitidos para tráfico saliente (soporta wildcards como `*.example.com`) |
| `sandbox.network.deniedDomains` | array | Dominios bloqueados incluso si están en `allowedDomains`. Tiene **precedencia** sobre la allowlist. Se fusiona desde todas las fuentes de configuración |

> **Nota:** `deniedDomains` actúa como lista de exclusión explícita: un dominio en `deniedDomains` queda bloqueado aunque coincida con un patrón wildcard en `allowedDomains`.

---

## Auto Mode

Configura el comportamiento del clasificador automático de Auto Mode.

```json
{
  "autoMode": {
    "environment": ["$defaults"],
    "allow": ["$defaults", "Allow npm run build"],
    "soft_deny": ["$defaults", "Never run terraform apply without review"]
  }
}
```

| Clave | Tipo | Descripción |
|-------|------|-------------|
| `autoMode.allow` | array | Operaciones permitidas automáticamente por el clasificador |
| `autoMode.soft_deny` | array | Operaciones que requieren confirmación (no hay bloqueo duro) |
| `autoMode.environment` | array | Reglas de entorno para el clasificador |

### Uso de `"$defaults"`

Incluir la cadena literal `"$defaults"` en cualquiera de los arrays hereda las reglas internas de Anthropic en esa posición. Permite **extender** en lugar de reemplazar:

```json
{
  "autoMode": {
    "soft_deny": [
      "$defaults",
      "Never modify infrastructure files",
      "Always ask before deleting files"
    ]
  }
}
```

### Otras claves de Auto Mode

| Clave | Tipo | Descripción |
|-------|------|-------------|
| `disableAutoMode` | string | `"disable"` para deshabilitar Auto Mode completamente |
| `useAutoModeDuringPlan` | boolean | Usar Auto Mode durante el modo Plan (por defecto: `true`) |

---

## MCP (Model Context Protocol)

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      },
      "alwaysLoad": true
    },
    "mi-servidor-pesado": {
      "command": "node",
      "args": ["./mcp-server.js"],
      "alwaysLoad": false
    }
  }
}
```

| Clave del servidor | Tipo | Descripción |
|--------------------|------|-------------|
| `command` | string | Comando para arrancar el servidor MCP |
| `args` | array | Argumentos del comando |
| `env` | object | Variables de entorno para el proceso del servidor |
| `alwaysLoad` | boolean | `true` para cargar todas las herramientas del servidor sin deferral (carga diferida). Útil para servidores con muchas herramientas que se usan frecuentemente |

### Control de servidores MCP

| Clave global | Tipo | Descripción |
|--------------|------|-------------|
| `allowedMcpServers` | array | Allowlist de servidores MCP permitidos |
| `deniedMcpServers` | array | Denylist de servidores MCP bloqueados |
| `allowManagedMcpServersOnly` | boolean | Solo permite servidores gestionados por la organización |
| `enableAllProjectMcpServers` | boolean | Habilita automáticamente todos los servidores de `.mcp.json` del proyecto |
| `enabledMcpjsonServers` | array | Lista de servidores de `.mcp.json` a habilitar |
| `disabledMcpjsonServers` | array | Lista de servidores de `.mcp.json` a deshabilitar |

---

## Integraciones y colaboración

| Clave | Tipo | Valores / Ejemplo | Descripción |
|-------|------|-------------------|-------------|
| `prUrlTemplate` | string | `"https://reviews.example.com/{owner}/{repo}/pull/{number}"` | URL personalizada para el badge de code-review en el footer de los PR. Soporta: `{host}`, `{owner}`, `{repo}`, `{number}`, `{url}` |
| `companyAnnouncements` | array | `["Mensaje bienvenida"]` | Mensajes que aparecen al arrancar Claude Code (uso enterprise) |

---

## Variables de entorno por proyecto

```json
{
  "env": {
    "NODE_ENV": "development",
    "BASH_DEFAULT_TIMEOUT_MS": "60000",
    "MAX_THINKING_TOKENS": "8000",
    "DISABLE_TELEMETRY": "1"
  }
}
```

Todas las variables de entorno documentadas en [referencia-cli-variables-entorno.md](./referencia-cli-variables-entorno.md) se pueden fijar aquí. Las variables definidas en `settings.json` del proyecto se aplican a todos los miembros del equipo; las de `settings.local.json` solo al usuario local.

---

## Atribución de commits y PRs

```json
{
  "attribution": {
    "commit": "🤖 Generated with Claude Code",
    "pr": ""
  }
}
```

| Clave | Descripción |
|-------|-------------|
| `attribution.commit` | Texto que se añade a los mensajes de commit generados por Claude |
| `attribution.pr` | Texto que se añade a las descripciones de PR |

---

## Hooks

Los hooks se configuran como eventos con sus correspondientes listas de handlers. Ver [estructura-carpeta-claude.md](./estructura-carpeta-claude.md) para la lista completa de eventos y la estructura de los handlers.

```json
{
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
  }
}
```

---

## Ejemplo completo para un equipo de desarrollo

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6",
  "tui": "fullscreen",
  "autoScrollEnabled": true,
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(npm run *)",
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git status)"
    ],
    "deny": [
      "Bash(curl *)",
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  },
  "sandbox": {
    "network": {
      "allowedDomains": ["api.github.com", "registry.npmjs.org"],
      "deniedDomains": ["internal.empresa.com"]
    }
  },
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      },
      "alwaysLoad": true
    }
  },
  "env": {
    "NODE_ENV": "development",
    "BASH_DEFAULT_TIMEOUT_MS": "60000"
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint:fix 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

---

## Ver también

- [Variables de entorno](./referencia-cli-variables-entorno.md) — Variables configurables en la sección `env`
- [estructura-carpeta-claude.md](./estructura-carpeta-claude.md) — Todos los ficheros de `.claude/` y su jerarquía
- [Flags de arranque](./referencia-cli-flags-arranque.md) — `--settings`, `--setting-sources` y `--mcp-config`
- [Slash commands](./referencia-cli-slash-commands.md) — `/config` para editar settings de forma interactiva
