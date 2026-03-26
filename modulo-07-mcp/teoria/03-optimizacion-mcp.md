# 03 - Optimización y Seguridad MCP

## El Problema: Overhead de Tokens

Cada servidor MCP consume tokens **en cada mensaje** porque Claude necesita
conocer las herramientas disponibles. Con 3-5 servidores, el overhead
puede ser de 5K-10K tokens por mensaje.

> **Novedad v3.1 (v2.1.84):** Las descripciones de herramientas MCP ahora estan **limitadas a 2KB**. Descripciones mas largas se truncan automaticamente. Esto reduce el overhead de tokens en servidores con muchas herramientas o descripciones verbose.

---

## Estrategias de Optimización

### 1. Tool Search

```bash
export ENABLE_MCP_TOOL_SEARCH=auto:5
```

Carga solo las herramientas relevantes bajo demanda. Reduce overhead de 5K a ~500 tokens.

### 2. Activar Solo los Necesarios

```json
// Para proyecto que solo usa PostgreSQL:
{
  "mcpServers": {
    "postgres": { }
    // "github": { }      ← comentado
    // "slack": { }        ← comentado
  }
}
```

### 3. Usar Local para Servidores Temporales

```json
// .claude/settings.local.json (no commitear)
{
  "mcpServers": {
    "mi-debug-server": { }
  }
}
```

Así no contaminas la config del equipo con servidores temporales.

### 4. Preferir Built-in Cuando Sea Posible

| Tarea | MCP | Built-in |
|-------|-----|---------|
| Leer archivo | filesystem MCP | Read (mejor) |
| Ejecutar comando | - | Bash (mejor) |
| Consultar BD | postgres MCP (mejor) | Bash + psql |
| Crear issue GitHub | github MCP | Bash + gh CLI (similar) |

---

## Cuándo Vale la Pena MCP

| Escenario | ¿MCP recomendado? | Razón |
|-----------|-----------------|-------|
| BD como parte central del trabajo | Sí | Queries frecuentes justifican overhead |
| Integración Jira/Slack diaria | Sí | No hay buena alternativa CLI |
| GitHub ocasional | No | `gh` CLI funciona bien |
| Filesystem local | No | Built-in Read/Write es mejor |
| API interna de la empresa | Sí | Crea tu propio server |

---

## Crear tu Propio Servidor MCP

Para integraciones específicas de tu empresa:

```javascript
// server.js
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({ name: "mi-servidor", version: "1.0.0" }, {
  capabilities: { tools: {} }
});

server.setRequestHandler("tools/list", async () => ({
  tools: [{
    name: "mi_herramienta",
    description: "Descripción de lo que hace",
    inputSchema: {
      type: "object",
      properties: {
        parametro: { type: "string", description: "Qué es" }
      },
      required: ["parametro"]
    }
  }]
}));

server.setRequestHandler("tools/call", async (request) => {
  if (request.params.name === "mi_herramienta") {
    const { parametro } = request.params.arguments;
    // Tu lógica aquí
    return { content: [{ type: "text", text: `Resultado: ${parametro}` }] };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

---

## Dynamic Filtering en Web Search/Fetch

> **Novedad v3.0**

Cuando Claude usa web search o web fetch, puede aplicar **dynamic filtering** para filtrar y procesar los resultados mediante code execution antes de incorporarlos al contexto. Esto reduce la cantidad de tokens que entran en la ventana de contexto y mejora la relevancia de la información.

```
Ejemplo: Claude busca "últimas vulnerabilidades de Node.js" en la web,
recibe 10 resultados, ejecuta código para filtrar solo las CVEs de
severidad alta del último mes, y solo incorpora esos resultados filtrados
al contexto.
```

Este filtrado es automático cuando Claude lo considera útil. La ejecución de código asociada al filtrado es **gratuita** (no se factura por separado).

---

## Seguridad MCP

### Riesgos

| Riesgo | Descripción | Mitigación |
|--------|------------|-----------|
| **Prompt injection** | Servidor devuelve texto malicioso | Usar servidores confiables |
| **Datos sensibles** | BD expuesta vía MCP | Permisos deny para execute |
| **Terceros maliciosos** | Servidor MCP con backdoor | Auditar código, usar oficiales |
| **Secrets en config** | Tokens hardcoded | Usar ${ENV_VAR} siempre |
| **Escritura no autorizada** | MCP modifica datos | Permisos granulares |

### Mejores Prácticas

1. **Solo servidores oficiales o auditados**
2. **Secrets en variables de entorno**, nunca en settings.json
3. **Permisos deny para operaciones destructivas** (execute, delete, write)
4. **Tool Search para minimizar superficie** de ataque
5. **Revisar herramientas** expuestas: `/mcp` y verificar que son las esperadas
6. **No confiar ciegamente** en output de servidores MCP terceros

```json
{
  "permissions": {
    "allow": ["mcp__postgres__query"],
    "deny": [
      "mcp__postgres__execute",
      "mcp__postgres__drop_table",
      "mcp__postgres__create_table"
    ]
  }
}
```
