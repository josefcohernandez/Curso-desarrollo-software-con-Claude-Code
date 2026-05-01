# 02 - Configuración de MCP

## Dónde Configurar

La forma recomendada de añadir servidores MCP es con el CLI:

```bash
claude mcp add nombre-servidor -- npx -y @modelcontextprotocol/server-nombre
```

Los servidores se almacenan en archivos separados según el scope:

| Nivel | Archivo | Scope |
|-------|---------|-------|
| Project | `.mcp.json` | Compartido equipo (commitear) |
| User | `~/.claude.json` | Personal global |
| Local | `~/.claude.json` (scope local) | Personal proyecto (no commitear) |
| Managed | `managed-mcp.json` (directorio del sistema) | Enterprise |

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
| `alwaysLoad` | Carga todas las herramientas inmediatamente | `true` |

### `alwaysLoad: true` — Carga inmediata de herramientas (v2.1.121)

Por defecto, cuando Tool Search está activo, las herramientas de un servidor se marcan como diferidas (deferred) y se cargan bajo demanda. Si configuras `alwaysLoad: true` en un servidor, **todas sus herramientas se cargan en contexto al inicio de la sesión**, sin pasar por el mecanismo de tool-search deferral.

Cuándo usar esta opción:

- El servidor tiene pocas herramientas (5 o menos) y se usan en casi todos los mensajes.
- El coste de buscar la herramienta en cada mensaje es mayor que el overhead de tenerla siempre en contexto.
- Quieres garantizar que Claude no tenga que hacer una búsqueda previa antes de invocar la herramienta.

```json
{
  "mcpServers": {
    "mi-servidor": {
      "command": "node",
      "args": ["server.js"],
      "alwaysLoad": true
    }
  }
}
```

> **Nota:** `alwaysLoad: true` es la excepción, no la regla. Para servidores con muchas herramientas o de uso ocasional, la configuración por defecto con Tool Search sigue siendo preferible para mantener el overhead de tokens bajo control. Consulta el fichero [`04-deferred-tools-y-tool-search.md`](04-deferred-tools-y-tool-search.md) para entender el impacto en tokens.

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

### Servidores ocultos por duplicados (v2.1.122)

Si un servidor configurado localmente tiene la misma URL que un conector de claude.ai, el conector de claude.ai quedaba oculto en versiones anteriores sin ninguna indicación. Desde v2.1.122, el comando `/mcp` muestra los conectores ocultos por duplicado con un indicador visual y un hint que explica cómo eliminar el servidor local duplicado para que el conector de claude.ai vuelva a estar activo.

Esto es útil cuando un equipo usa conectores compartidos desde claude.ai y un miembro del equipo tiene configurado localmente el mismo servidor: el comando `/mcp` ahora avisa de la situación en lugar de silenciarla.

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

### Reintentos automáticos en errores transitorios (v2.1.121)

Cuando un servidor MCP falla al arrancar (error de red, proceso que tarda en inicializarse, dependencia no disponible en ese instante), Claude Code realiza **hasta 3 reintentos automáticos** antes de marcar el servidor como no disponible. El reintento tiene un intervalo de espera creciente entre intentos.

Esto reduce los falsos negativos en entornos con servicios que tardan en estar listos, como contenedores Docker con tiempos de arranque variables o servidores que dependen de una base de datos que aún está inicializándose. No requiere configuración adicional: el comportamiento es automático desde v2.1.121.

> Si el servidor sigue sin conectar tras los 3 reintentos, aparecerá en `/mcp` con estado de error. En ese caso, verifica los logs con `claude --verbose`.

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
