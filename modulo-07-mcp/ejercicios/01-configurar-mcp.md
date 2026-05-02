# Ejercicio 01: Configurar Servidores MCP

## Objetivo

Configurar servidores MCP reales, verificar su funcionamiento y medir el impacto en tokens.

---

## Parte 1: MCP Filesystem (10 min)

### Configurar

Crea `.claude/settings.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp/mcp-test"]
    }
  }
}
```

Prepara directorio de prueba:

```bash
mkdir -p /tmp/mcp-test
echo "Hola MCP" > /tmp/mcp-test/test.txt
echo '{"name": "test"}' > /tmp/mcp-test/data.json
```

### Verificar

```bash
claude
> /mcp                    # Ver servidor conectado
> /cost                   # Tokens base con MCP
> "Usa la herramienta filesystem para listar archivos en /tmp/mcp-test"
> "Lee el contenido de test.txt usando filesystem MCP"
> /cost                   # Tokens después de usar MCP
```

---

## Parte 2: MCP SQLite (15 min)

### Configurar

Actualiza `.claude/settings.json` manteniendo `filesystem` y anadiendo `sqlite`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp/mcp-test"]
    },
    "sqlite": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "/tmp/mcp-test/test.db"]
    }
  }
}
```

### Crear BD de prueba

```bash
sqlite3 /tmp/mcp-test/test.db << 'SQL'
CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT);
INSERT INTO users VALUES (1, 'Ana', 'ana@test.com');
INSERT INTO users VALUES (2, 'Carlos', 'carlos@test.com');
INSERT INTO users VALUES (3, 'Díana', 'díana@test.com');

CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER, total REAL, status TEXT);
INSERT INTO orders VALUES (1, 1, 99.99, 'completed');
INSERT INTO orders VALUES (2, 1, 150.00, 'pending');
INSERT INTO orders VALUES (3, 2, 75.50, 'completed');
SQL
```

### Usar

```bash
claude
> /mcp
> "Qué tablas hay en la base de datos?"
> "Muestra todos los usuarios"
> "Qué pedidos tiene Ana?"
> "Cual es el total de ventas completadas?"
> /cost
```

---

## Parte 3: Medir Impacto de Tokens (10 min)

### Sin MCP

```bash
claude --no-mcp
> /cost                   # Tokens base SIN MCP
> "Hola"
> /cost                   # Incremento por mensaje SIN MCP
> /exit
```

### Con 1 MCP

```bash
# Solo filesystem en settings.json
claude
> /cost                   # Tokens base CON 1 MCP
> "Hola"
> /cost                   # Incremento por mensaje CON 1 MCP
> /exit
```

### Con 2 MCPs

```bash
# filesystem + sqlite en settings.json
claude
> /cost                   # Tokens base CON 2 MCPs
> "Hola"
> /cost                   # Incremento por mensaje CON 2 MCPs
> /exit
```

### Tabla de Resultados

| Configuración | Tokens inicio | Tokens por "Hola" | Overhead |
|--------------|--------------|-------------------|---------|
| Sin MCP | ? | ? | 0 |
| 1 MCP (filesystem) | ? | ? | +? |
| 2 MCPs (fs + sqlite) | ? | ? | +? |

---

## Parte 4: Desactivar y Limpiar (5 min)

```
> /exit
```

Edita settings.json para dejar solo los MCPs que uses realmente.

---

## Criterios de Completitud

- [ ] Filesystem MCP configurado y funcionando
- [ ] SQLite MCP configurado y funcionando
- [ ] /mcp muestra servidores correctos
- [ ] Consultas a BD exitosas
- [ ] Tabla de impacto de tokens completada
- [ ] MCPs innecesarios desactivados
