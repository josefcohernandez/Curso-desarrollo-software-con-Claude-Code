# 01 - Qué es MCP (Model Context Protocol)

## Definición

MCP es un **estándar abierto** creado por Anthropic que permite a modelos de IA
conectarse con herramientas y datos externos. Es como un "USB para IA":
un protocolo universal para conectar cualquier herramienta.

---

## Arquitectura

```
Claude Code (Cliente MCP)
    ↕ JSON-RPC
Servidor MCP
    ↕
Herramienta/Servicio (PostgreSQL, GitHub, Slack, etc.)
```

Claude Code actúa como **cliente MCP** que se comunica con **servidores MCP**.
Cada servidor expone herramientas (tools) que Claude puede invocar.

---

## Qué Expone un Servidor MCP

| Tipo | Descripción | Ejemplo |
|------|------------|---------|
| **Tools** | Acciones ejecutables | `query_database`, `create_issue` |
| **Resources** | Datos consultables | Schema de BD, archivos |
| **Prompts** | Templates de prompts | Prompts predefinidos para tareas comunes |

---

## Transportes

| Transporte | Cómo funciona | Uso típico |
|-----------|--------------|-----------|
| **stdio** | Proceso hijo, comunicación por stdin/stdout | Local (más común) |
| **HTTP/SSE** | Servidor HTTP con Server-Sent Events | Remoto |
| **OAuth 2.0** | HTTP con autenticación OAuth | Servicios cloud |

La mayoría de servidores MCP usan **stdio**: Claude Code lanza el proceso
del servidor y se comunica por stdin/stdout.

---

## Servidores MCP Populares

| Servidor | Qué hace | Herramientas |
|----------|---------|-------------|
| **PostgreSQL** | Consultar/modificar BD | query, list_tables, describe_table |
| **GitHub** | Issues, PRs, repos | create_issue, list_prs, get_file |
| **Filesystem** | Acceso a archivos | read_file, write_file, list_directory |
| **Slack** | Mensajes y canales | send_message, list_channels |
| **Puppeteer** | Navegador web | navigate, screenshot, click |
| **Memory** | Almacenamiento persistente | store, retrieve, search |
| **SQLite** | BD local | query, execute |
| **Brave Search** | Búsqueda web | search |

Hay cientos de servidores MCP disponibles. Catálogo: https://github.com/modelcontextprotocol/servers

---

## Impacto en Tokens

**Cada servidor MCP activo consume tokens** en cada mensaje, porque Claude
necesita conocer las herramientas disponibles:

| Servidores activos | Overhead por mensaje |
|-------------------|---------------------|
| 0 | 0 tokens |
| 1 (5 tools) | ~500-1,000 tokens |
| 3 (15 tools) | ~2,000-4,000 tokens |
| 5+ (30+ tools) | ~5,000-10,000 tokens |

Esto se aplica a **cada mensaje**, así que en una sesión de 20 mensajes
con 3 MCPs activos, son ~40K-80K tokens extra solo de overhead.

---

## MCP vs Herramientas Built-in

Claude Code ya tiene herramientas integradas (Read, Write, Edit, Bash, etc.).
MCP añade herramientas **externas**:

| Built-in | MCP |
|----------|-----|
| Read/Write/Edit archivos | Consultar base de datos |
| Bash (comandos shell) | Interactuar con APIs |
| Grep/Glob (búsqueda) | Servicios cloud |
| WebFetch/WebSearch | Herramientas personalizadas |

**Regla**: Si puedes hacerlo con Bash o built-in, no necesitas MCP.
MCP es para integraciones que no se pueden hacer con shell commands.

---

## Override de tamaño de resultados MCP (v2.1.91)

Por defecto, los resultados de herramientas MCP se truncan cuando superan el límite de tokens configurado (`MAX_MCP_OUTPUT_TOKENS`). Desde v2.1.91, los servidores MCP pueden declarar un override vía la anotación `_meta["anthropic/maxResultSizeChars"]` para permitir resultados de hasta **500.000 caracteres** sin truncación.

Esto es útil para herramientas que devuelven schemas de base de datos completos, documentos largos o resultados de búsqueda extensos donde el truncado perdería información crítica.

```json
{
  "content": [
    {
      "type": "text",
      "text": "... schema completo de 200K caracteres ...",
      "_meta": {
        "anthropic/maxResultSizeChars": 500000
      }
    }
  ]
}
```

> **Nota:** Este override lo declara el **servidor MCP**, no el cliente. Si estás desarrollando un servidor MCP propio y necesitas devolver resultados grandes, añade la anotación `_meta` al contenido de la respuesta.

### Conexión MCP no bloqueante en modo headless (v2.1.89)

La variable de entorno `MCP_CONNECTION_NONBLOCKING=true` hace que el modo `-p` (headless) **no espere** a que todos los servidores MCP conecten antes de empezar a procesar. Esto es útil en pipelines CI/CD donde un servidor MCP lento o no disponible no debe bloquear la ejecución:

```bash
MCP_CONNECTION_NONBLOCKING=true claude -p "analiza el código" --max-turns 5
```

---

## Cuándo Usar MCP

| Escenario | ¿MCP recomendado? |
|-----------|-----------------|
| Consultar PostgreSQL | Sí (mejor que Bash + psql) |
| Crear issues en GitHub | Depende (gh CLI funciona bien) |
| Leer archivos locales | No (Read built-in es mejor) |
| Interactuar con Jira | Sí (no hay buena CLI alternativa) |
| Buscar en Slack | Sí |
| Ejecutar scripts | No (Bash built-in) |
