# 02 - Configuración de MCP

## Dónde Configurar

| Nivel | Archivo | Scope |
|-------|---------|-------|
| Project | `.claude/settings.json` | Compartido equipo (commitear) |
| User | `~/.claude/settings.json` | Personal global |
| Local | `.claude/settings.local.json` | Personal proyecto (no commitear) |

---

## Formato de Configuración

```json
{
  "mcpServers": {
    "nombre-servidor": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-nombre"],
      "env": {
        "VARIABLE": "valor",
        "DYNAMIC": "${ENV_VAR}"
      }
    }
  }
}
```

### Campos

| Campo | Descripción | Ejemplo |
|-------|------------|---------|
| `command` | Ejecutable del servidor | `npx`, `node`, `python` |
| `args` | Argumentos | `["-y", "@mcp/server-postgres"]` |
| `env` | Variables de entorno | `{"DB_URL": "${DATABASE_URL}"}` |

### Variables Dinámicas

Usa `${NOMBRE}` para referenciar variables de entorno del sistema:

```json
{
  "env": {
    "DATABASE_URL": "${DATABASE_URL}",
    "GITHUB_TOKEN": "${GITHUB_TOKEN}"
  }
}
```

Esto evita hardcodear secrets en la configuración.

---

## Variables de Entorno para headersHelper

> **Novedad v3.2 (v2.1.85)**

Cuando un servidor MCP usa `headersHelper` (un script externo que genera cabeceras de autenticación), Claude Code inyecta automáticamente dos variables de entorno que identifican qué servidor está solicitando las cabeceras:

| Variable | Descripción |
|----------|-------------|
| `CLAUDE_CODE_MCP_SERVER_NAME` | Nombre del servidor MCP tal como está configurado en settings.json |
| `CLAUDE_CODE_MCP_SERVER_URL` | URL del servidor MCP |

Esto permite usar **un solo script** `headersHelper` para múltiples servidores:

```bash
#!/bin/bash
# headers-helper.sh — un script, múltiples servidores

case "$CLAUDE_CODE_MCP_SERVER_NAME" in
  "api-produccion")
    echo "{\"Authorization\": \"Bearer $(vault read -field=token secret/prod)\"}"
    ;;
  "api-staging")
    echo "{\"Authorization\": \"Bearer $(vault read -field=token secret/staging)\"}"
    ;;
  *)
    echo "{}"
    ;;
esac
```

---

## Deduplicación de Servidores MCP

> **Novedad v3.2 (v2.1.85)**

Cuando un servidor MCP está configurado tanto localmente (en `.claude/settings.json`) como en los conectores de claude.ai, Claude Code los **deduplica automáticamente**: la configuración local siempre tiene prioridad. Esto evita que aparezcan herramientas duplicadas en la sesión.

---

## Verificar Servidores Activos

```bash
claude
> /mcp
```

Muestra: servidores conectados, herramientas disponibles, estado.

---

## Tool Search

**Tool Search** carga herramientas MCP bajo demanda en vez de todas a la vez:

```bash
# Activar Tool Search
export ENABLE_MCP_TOOL_SEARCH=auto:5
```

| Modo | Comportamiento |
|------|---------------|
| `auto:N` | Carga las top N herramientas más relevantes bajo demanda |
| `off` | Todas las herramientas cargadas siempre (por defecto) |

Con Tool Search activado:
- Se reduce el overhead de tokens por mensaje
- Claude busca la herramienta correcta cuando la necesita
- Solo las herramientas relevantes se cargan en el contexto

---

## Configurar Permisos para MCP

Las herramientas MCP aparecen como `mcp__servidor__herramienta`:

```json
{
  "permissions": {
    "allow": [
      "mcp__postgres__query",
      "mcp__postgres__list_tables"
    ],
    "deny": [
      "mcp__postgres__execute"
    ]
  }
}
```

---

## Troubleshooting

### Servidor no conecta

```bash
# Verificar que el paquete existe
npx -y @modelcontextprotocol/server-postgres --help

# Verificar variables de entorno
echo $DATABASE_URL

# Ver logs de MCP
claude --verbose
> /mcp
```

### Herramientas no aparecen

1. Verificar que el servidor está en settings.json correcto
2. Verificar `/mcp` en sesión interactiva
3. Reiniciar Claude Code (a veces necesario tras cambiar config)

### Timeout de conexión

```json
{
  "mcpServers": {
    "mi-servidor": {
      "command": "node",
      "args": ["server.js"],
      "timeout": 30000
    }
  }
}
```

---

## Ejemplo Completo

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/docs"],
      "env": {}
    }
  },
  "permissions": {
    "allow": [
      "mcp__postgres__query",
      "mcp__postgres__list_tables",
      "mcp__filesystem__read_file"
    ],
    "deny": [
      "mcp__postgres__execute",
      "mcp__filesystem__write_file"
    ]
  }
}
```
