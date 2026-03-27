# 05 - MCP Elicitation

## Objetivos de aprendizaje

Al terminar este tema sabrás:

- Qué es MCP elicitation y por qué existe
- Cuándo un servidor MCP solicita input al usuario (form mode y URL mode)
- Cómo construir un servidor MCP que use elicitation
- Cómo interceptar y automatizar respuestas con los hooks `Elicitation` y `ElicitationResult`
- En qué se diferencia elicitation de las herramientas interactivas tradicionales

---

## Qué es MCP Elicitation

MCP elicitation (introducido en Claude Code v2.1.76) es la capacidad de un servidor MCP de **solicitar input estructurado al usuario en mitad de la ejecución de una tarea**, sin necesidad de conocer todos los parámetros de antemano.

Hasta su aparición, los servidores MCP recibían todos los argumentos de una herramienta en el momento de la invocación. Si faltaba algún dato crítico (credenciales, confirmación de operación, parámetros condicionales), la única salida era fallar o devolver un error al modelo.

Con elicitation, el servidor puede pausar la ejecución, mostrar un diálogo al usuario y continuar con la respuesta recibida. Esto abre un modelo de interacción mucho más parecido al de las aplicaciones reales:

```
Claude invoca herramienta MCP
    ↓
Servidor MCP detecta que necesita input adicional
    ↓
Servidor solicita elicitation al cliente (Claude Code)
    ↓
Claude Code muestra diálogo al usuario (form o URL)
    ↓
Usuario responde
    ↓
Respuesta llega al servidor MCP
    ↓
Servidor completa la operación y devuelve resultado
```

---

## Los dos modos de elicitation

### Form mode

En form mode, Claude Code muestra un diálogo con campos de formulario. El servidor define la estructura del formulario mediante un JSON Schema que especifica qué campos pedir, sus tipos y cuáles son obligatorios.

Tipos de campo soportados:

| Tipo JSON Schema | Interfaz mostrada | Ejemplo de uso |
|-----------------|-------------------|----------------|
| `string` | Campo de texto libre | Nombre de usuario, ruta de archivo |
| `number` / `integer` | Campo numérico | Puerto, límite de resultados |
| `boolean` | Casilla de verificación | Confirmar operación destructiva |
| `string` con `enum` | Lista desplegable | Seleccionar entorno (dev/staging/prod) |
| `object` con propiedades | Sección con subcampos | Credenciales con usuario + contraseña |

Ejemplo de JSON Schema que describe un formulario de credenciales:

```json
{
  "type": "object",
  "title": "Credenciales de base de datos",
  "properties": {
    "host": {
      "type": "string",
      "title": "Host",
      "description": "Dirección del servidor PostgreSQL"
    },
    "port": {
      "type": "integer",
      "title": "Puerto",
      "default": 5432
    },
    "username": {
      "type": "string",
      "title": "Usuario"
    },
    "password": {
      "type": "string",
      "title": "Contraseña"
    },
    "database": {
      "type": "string",
      "title": "Base de datos"
    }
  },
  "required": ["host", "username", "password", "database"]
}
```

### URL mode

En URL mode, Claude Code abre un flujo basado en navegador. El servidor proporciona una URL (habitualmente el punto de inicio de un flujo OAuth o una página de aprobación) y el usuario interactúa con ella para completar la autenticación u otorgar permisos.

Este modo es el adecuado para:

- Flujos OAuth 2.0 con proveedores externos (GitHub, Google, Salesforce, etc.)
- Páginas de consentimiento personalizadas
- Procesos de aprobación que requieren la interfaz web de un servicio

El servidor recibe la confirmación una vez que el usuario completa el flujo en el navegador.

---

## Cómo implementa un servidor MCP la elicitation

El SDK de MCP expone el método `server.requestElicitation()` (o equivalente según el lenguaje). El servidor lo llama durante el handler de una herramienta, espera la respuesta y continúa con la lógica.

### Ejemplo: servidor con form mode

El siguiente servidor expone una herramienta `conectar_base_de_datos` que solicita las credenciales mediante elicitation en lugar de recibirlas como argumentos de la herramienta:

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server(
  { name: "db-connector", version: "1.0.0" },
  { capabilities: { tools: {}, elicitation: {} } }
);

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "conectar_base_de_datos",
      description: "Conecta a una base de datos PostgreSQL y verifica la conexión",
      inputSchema: {
        type: "object",
        properties: {
          entorno: {
            type: "string",
            enum: ["development", "staging", "production"],
            description: "Entorno al que conectar"
          }
        },
        required: ["entorno"]
      }
    }
  ]
}));

server.setRequestHandler("tools/call", async (request, { requestElicitation }) => {
  if (request.params.name === "conectar_base_de_datos") {
    const { entorno } = request.params.arguments;

    // Solicitar credenciales mediante elicitation
    const elicitationResult = await requestElicitation({
      message: `Introduce las credenciales para el entorno ${entorno}`,
      requestedSchema: {
        type: "object",
        properties: {
          host: { type: "string", title: "Host" },
          port: { type: "integer", title: "Puerto", default: 5432 },
          username: { type: "string", title: "Usuario" },
          password: { type: "string", title: "Contraseña" },
          database: { type: "string", title: "Base de datos" }
        },
        required: ["host", "username", "password", "database"]
      }
    });

    if (elicitationResult.action !== "accept") {
      return {
        content: [{ type: "text", text: "Conexión cancelada por el usuario." }]
      };
    }

    const { host, port, username, database } = elicitationResult.content;

    // Usar las credenciales para conectar (lógica real aquí)
    return {
      content: [
        {
          type: "text",
          text: `Conexión establecida con ${database} en ${host}:${port || 5432} como ${username}`
        }
      ]
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

### Ejemplo: servidor con URL mode para OAuth

El siguiente servidor expone una herramienta `autorizar_github` que inicia un flujo OAuth:

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import crypto from "crypto";

const server = new Server(
  { name: "github-oauth", version: "1.0.0" },
  { capabilities: { tools: {}, elicitation: {} } }
);

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "autorizar_github",
      description: "Inicia el flujo OAuth para obtener acceso a repositorios de GitHub",
      inputSchema: {
        type: "object",
        properties: {
          scopes: {
            type: "string",
            description: "Permisos a solicitar (ej: repo,read:user)"
          }
        },
        required: ["scopes"]
      }
    }
  ]
}));

server.setRequestHandler("tools/call", async (request, { requestElicitation }) => {
  if (request.params.name === "autorizar_github") {
    const { scopes } = request.params.arguments;
    const state = crypto.randomUUID();

    // Construir la URL del flujo OAuth
    const authUrl = new URL("https://github.com/login/oauth/authorize");
    authUrl.searchParams.set("client_id", process.env.GITHUB_CLIENT_ID);
    authUrl.searchParams.set("scope", scopes);
    authUrl.searchParams.set("state", state);
    authUrl.searchParams.set("redirect_uri", "http://localhost:8080/callback");

    // Solicitar al usuario que complete el flujo en el navegador
    const result = await requestElicitation({
      message: "Abre el navegador para autorizar el acceso a GitHub",
      mode: "url",
      url: authUrl.toString()
    });

    if (result.action !== "accept") {
      return {
        content: [{ type: "text", text: "Autorización cancelada." }]
      };
    }

    // En un caso real, aquí se intercambiaría el code por un token
    return {
      content: [{ type: "text", text: "Autorización completada. Token almacenado en sesión." }]
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

---

## Hooks de elicitation

Claude Code v2.1.76 introduce dos hooks específicos para interceptar el ciclo de elicitation. Ambos se configuran en `.claude/settings.json` dentro de la sección `hooks`.

### Hook Elicitation

Se ejecuta cuando un servidor MCP solicita input, **antes de mostrar el diálogo al usuario**. Permite responder automáticamente sin que el usuario tenga que escribir nada.

Datos que recibe el hook por stdin:

```json
{
  "session_id": "abc123",
  "transcript_path": "/home/usuario/.claude/projects/mi-proyecto/transcript.jsonl",
  "cwd": "/home/usuario/mi-proyecto",
  "permission_mode": "default",
  "hook_event_name": "Elicitation",
  "mcp_server_name": "db-connector",
  "message": "Introduce las credenciales para el entorno development",
  "mode": "form",
  "requested_schema": {
    "type": "object",
    "properties": {
      "host": { "type": "string", "title": "Host" },
      "port": { "type": "integer", "title": "Puerto" },
      "username": { "type": "string", "title": "Usuario" },
      "password": { "type": "string", "title": "Contraseña" },
      "database": { "type": "string", "title": "Base de datos" }
    },
    "required": ["host", "username", "password", "database"]
  }
}
```

Para responder automáticamente, el hook escribe en stdout:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "Elicitation",
    "action": "accept",
    "content": {
      "host": "localhost",
      "port": 5432,
      "username": "mi_usuario",
      "password": "mi_contraseña",
      "database": "mi_base_de_datos"
    }
  }
}
```

Valores posibles para `action`:

| Valor | Efecto |
|-------|--------|
| `accept` | Proporciona los valores del formulario; no se muestra el diálogo |
| `decline` | Rechaza la solicitud |
| `cancel` | Cancela la elicitation |

Si el hook termina con exit code 0 sin escribir nada en stdout, Claude Code muestra el diálogo al usuario de forma normal.

### Hook ElicitationResult

Se ejecuta después de que el usuario (o el hook Elicitation) responde, **antes de que la respuesta llegue al servidor MCP**. Permite modificar o rechazar la respuesta.

Datos que recibe por stdin:

```json
{
  "session_id": "abc123",
  "transcript_path": "/home/usuario/.claude/projects/mi-proyecto/transcript.jsonl",
  "cwd": "/home/usuario/mi-proyecto",
  "permission_mode": "default",
  "hook_event_name": "ElicitationResult",
  "mcp_server_name": "db-connector",
  "action": "accept",
  "content": {
    "host": "localhost",
    "username": "mi_usuario",
    "password": "mi_contraseña",
    "database": "mi_base_de_datos"
  }
}
```

Para modificar la respuesta antes de enviarla al servidor:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "ElicitationResult",
    "action": "accept",
    "content": {
      "host": "localhost",
      "port": 5432,
      "username": "mi_usuario",
      "password": "mi_contraseña",
      "database": "mi_base_de_datos"
    }
  }
}
```

### Configuración de los hooks en settings.json

```json
{
  "hooks": {
    "Elicitation": [
      {
        "matcher": "db-connector",
        "hooks": [
          {
            "type": "command",
            "command": "/home/usuario/.claude/hooks/auto-credenciales.sh"
          }
        ]
      }
    ],
    "ElicitationResult": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "/home/usuario/.claude/hooks/log-elicitation.sh"
          }
        ]
      }
    ]
  }
}
```

El campo `matcher` acepta el nombre exacto de un servidor MCP o `"*"` para interceptar elicitations de cualquier servidor.

---

## Ejemplo completo: auto-autenticación con variables de entorno

Este script intercepta las elicitations del servidor `db-connector` y responde automáticamente usando variables de entorno, eliminando la necesidad de escribir credenciales manualmente en cada sesión:

```bash
#!/bin/bash
# ~/.claude/hooks/auto-credenciales.sh

INPUT=$(cat)

SERVER=$(echo "$INPUT" | jq -r '.mcp_server_name')
MODE=$(echo "$INPUT" | jq -r '.mode')

# Solo actuar si es el servidor correcto en form mode
if [ "$SERVER" != "db-connector" ] || [ "$MODE" != "form" ]; then
  exit 0  # Dejar que aparezca el diálogo normal
fi

# Verificar que las variables de entorno están disponibles
if [ -z "$DB_HOST" ] || [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ]; then
  exit 0  # Sin variables, mostrar diálogo al usuario
fi

jq -n \
  --arg host "$DB_HOST" \
  --arg user "$DB_USERNAME" \
  --arg pass "$DB_PASSWORD" \
  --arg db "${DB_NAME:-mi_base_de_datos}" \
  '{
    "hookSpecificOutput": {
      "hookEventName": "Elicitation",
      "action": "accept",
      "content": {
        "host": $host,
        "port": 5432,
        "username": $user,
        "password": $pass,
        "database": $db
      }
    }
  }'
```

Con las variables de entorno definidas en el shell (`DB_HOST`, `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME`), el servidor recibirá las credenciales automáticamente sin interrumpir la tarea de Claude.

---

## Casos de uso habituales

| Escenario | Modo | Por qué elicitation y no argumentos directos |
|-----------|------|---------------------------------------------|
| Credenciales de base de datos en tiempo de ejecución | form | Evita almacenar secrets en el contexto o en el CLAUDE.md |
| Seleccionar entorno antes de un deploy | form | La decisión depende del estado de la conversación, no se sabe de antemano |
| Confirmar borrado de datos | form (boolean) | Operación destructiva que requiere confirmación explícita |
| Autenticación OAuth con GitHub/Google | url | El flujo de consentimiento requiere interacción en el navegador |
| Aprobación de PR en sistema interno | url | La plataforma de revisión tiene su propia UI web |
| Recopilar parámetros complejos de un informe | form (objeto anidado) | Muchos campos opcionales con valores por defecto |

---

## Diferencias con las herramientas interactivas tradicionales

Los mecanismos previos para obtener input del usuario durante una tarea tienen limitaciones que elicitation resuelve:

| Aspecto | Argumentos de herramienta | Prompt al usuario (texto libre) | MCP Elicitation |
|---------|--------------------------|--------------------------------|-----------------|
| Estructura del input | Definida por JSON Schema | Sin estructura, texto libre | Definida por JSON Schema |
| Momento de recolección | Antes de invocar la herramienta | Cualquiera, interrumpe el flujo | Dentro del handler, durante la ejecución |
| Flujos OAuth | No soportado | No soportado | Soportado (URL mode) |
| Automatizable con hooks | No | No | Si (hooks Elicitation y ElicitationResult) |
| Validación de tipos | En el servidor, post-invocación | Manual, en el servidor | En el cliente, antes de enviar |
| UX | Transparente para el usuario | Interrupción visible en el chat | Diálogo nativo del cliente |

---

## OAuth y RFC 9728

> **Novedad v3.2 (v2.1.85)**

MCP OAuth ahora cumple con **RFC 9728 (Protected Resource Metadata)** para el descubrimiento del servidor de autorización. En la práctica, esto significa que cuando un servidor MCP requiere autenticación OAuth, Claude Code puede descubrir automáticamente el endpoint de autorización a partir de los metadatos del recurso protegido, sin necesidad de que el servidor especifique manualmente la URL del authorization server.

Para los desarrolladores de servidores MCP esto implica:
- El servidor puede publicar sus metadatos según RFC 9728 en `/.well-known/oauth-protected-resource`
- Claude Code los lee y localiza el authorization server automáticamente
- Se simplifica la configuración del cliente, especialmente en entornos multi-tenant

Además, se ha corregido el flujo de **step-up authorization**: cuando un servidor responde con `403 insufficient_scope` y existe un refresh token previo, Claude Code ahora inicia correctamente el flujo de re-autorización con los scopes elevados, en lugar de fallar silenciosamente.

---

## Configuración y permisos necesarios

Para que elicitation funcione correctamente, el servidor MCP debe declarar la capacidad `elicitation` al registrarse. Si no la declara, Claude Code no enviará las solicitudes de elicitation y el servidor recibirá un error.

```json
{
  "capabilities": {
    "tools": {},
    "elicitation": {}
  }
}
```

En cuanto a permisos del lado del cliente, elicitation no requiere configuración adicional en `settings.json` más allá de tener el servidor MCP habilitado. Los hooks son opcionales y se configuran solo si se quiere automatizar las respuestas.

Si el servidor MCP está configurado con permisos restrictivos en `permissions.deny`, las operaciones que requieren elicitation no se ven afectadas directamente (la elicitation ocurre antes de que la herramienta ejecute la operación), aunque las operaciones subsiguientes sí respetan los permisos:

```json
{
  "mcpServers": {
    "db-connector": {
      "command": "node",
      "args": ["/ruta/al/servidor/db-connector.js"]
    }
  },
  "permissions": {
    "allow": ["mcp__db-connector__conectar_base_de_datos"],
    "deny": ["mcp__db-connector__drop_table"]
  }
}
```

---

## Errores comunes

**Olvidar declarar la capacidad `elicitation` en el servidor**: Si el servidor llama a `requestElicitation()` sin haberla declarado en `capabilities`, Claude Code devuelve un error de protocolo. Siempre incluir `"elicitation": {}` en el objeto de capacidades al crear el servidor.

**Asumir que `action` siempre es `"accept"`**: El usuario puede cancelar o rechazar el diálogo. El handler debe comprobar el valor de `action` y gestionar los casos `"decline"` y `"cancel"` con mensajes de error o salidas limpias.

**Usar form mode para flujos OAuth**: Los flujos OAuth requieren interacción con el navegador y redirecciones. Usar form mode para este caso no funciona. URL mode es el modo correcto para OAuth.

**Poner secrets en `content` del hook sin leerlos de variables de entorno**: Si el script del hook tiene credenciales hardcoded, quedan expuestos en el sistema de ficheros. Siempre leer de variables de entorno o de un gestor de secretos.

**No gestionar el timeout**: Si el usuario no responde en un tiempo razonable, la elicitation puede quedar bloqueada. Los hooks pueden implementar un timeout con `exit 2` (equivalente a `decline`) si el proceso supera un límite de tiempo.

---

## Puntos clave

- MCP elicitation permite a los servidores MCP solicitar input estructurado al usuario **durante la ejecución de una herramienta**, no solo antes de invocarla.
- Existen dos modos: **form mode** (formulario con campos tipados definidos por JSON Schema) y **URL mode** (flujo basado en navegador para OAuth y aprobaciones).
- El servidor debe declarar `"elicitation": {}` en sus capacidades al registrarse; sin esa declaración, las solicitudes fallan.
- El hook **Elicitation** intercepta la solicitud antes de mostrar el diálogo: permite responder automáticamente desde un script usando variables de entorno u otras fuentes.
- El hook **ElicitationResult** intercepta la respuesta del usuario antes de enviarla al servidor: permite modificar o rechazar la respuesta.
- Ambos hooks se configuran en `.claude/settings.json` bajo la clave `hooks` y pueden usar `matcher` con el nombre del servidor MCP o `"*"` para todos.
- El campo `action` en la respuesta puede ser `"accept"`, `"decline"` o `"cancel"`; el servidor debe gestionar los tres casos.
- Elicitation es la solución correcta para credenciales mid-task, confirmaciones de operaciones destructivas, selección de entorno y flujos OAuth.

---

## Siguiente paso

Continua con los ejercicios del módulo: [`../ejercicios/02-crear-mcp-server.md`](../ejercicios/02-crear-mcp-server.md) para construir y desplegar tu propio servidor MCP con elicitation en un escenario real.
