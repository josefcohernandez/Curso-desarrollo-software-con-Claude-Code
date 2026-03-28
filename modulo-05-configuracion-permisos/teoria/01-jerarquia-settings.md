# 01 - Jerarquía de Configuración

## Los 5 Niveles

Claude Code tiene 5 niveles de configuración con **precedencia estricta**:

```
Managed (más alta)     ~/.claude/managed/        Administrador empresa
  ↓
CLI Flags              --model, --allowedTools    Por ejecución
  ↓
Local                  .claude/settings.local.json No se commitea
  ↓
Project                .claude/settings.json       Compartido equipo
  ↓
User (más baja)        ~/.claude/settings.json     Personal global
```

**Regla**: El nivel superior siempre gana. Managed > CLI > Local > Project > User.

---

## Nivel 1: Managed (~/.claude/managed/)

Configuración impuesta por administradores de empresa.
Los usuarios **no pueden sobreescribirla**.

```json
// ~/.claude/managed/settings.json
{
  "permissions": {
    "deny": ["Bash(rm -rf*)", "Bash(sudo*)", "Bash(curl*|wget*)"]
  },
  "model": "claude-sonnet-4-20250514"
}
```

Uso: Políticas de seguridad corporativas, restricciones de modelo, compliance.

---

## Nivel 2: CLI Flags

Se aplican solo a la ejecución actual:

```bash
claude --model opus
claude --allowedTools "Read,Glob,Grep"
claude --no-mcp
claude --max-turns 10
```

Útil para testing o tareas específicas sin cambiar configuración permanente.

---

## Nivel 3: Local (.claude/settings.local.json)

Configuración personal del desarrollador **para este proyecto**.
**No se commitea** (añadir a .gitignore).

```json
{
  "permissions": {
    "allow": ["Bash(npm test:*)", "Write(src/**)"]
  },
  "env": {
    "ANTHROPIC_MODEL": "claude-sonnet-4-6"
  }
}
```

Uso: Preferencias personales que no aplican al equipo.

---

## Nivel 4: Project (.claude/settings.json)

Configuración compartida del proyecto. **Se commitea** al repositorio.

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(npm test:*)",
      "Bash(npm run lint:*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(npm publish*)"
    ]
  },
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "DATABASE_URL": "${DATABASE_URL}" }
    }
  }
}
```

Uso: Convenciones del equipo, MCPs compartidos, permisos base.

---

## Nivel 5: User (~/.claude/settings.json)

Configuración personal global (aplica a todos los proyectos):

```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep"]
  },
  "env": {
    "ANTHROPIC_MODEL": "claude-sonnet-4-6"
  }
}
```

Uso: Preferencias globales del desarrollador.

---

## Estructura de settings.json

```json
{
  "permissions": {
    "allow": ["..."],   // Permitir sin preguntar
    "deny": ["..."]     // Bloquear siempre
    // Todo lo demás: ask (preguntar al usuario)
  },
  "env": {
    "VARIABLE": "valor"  // Variables de entorno
  },
  "mcpServers": {
    "nombre": { }    // Servidores MCP
  },
  "hooks": {
    "PreToolUse": [],  // Hooks por evento
    "PostToolUse": []
  }
}
```

---

## Opciones de Configuración Adicionales

### Status Line (línea de estado)

Claude Code muestra una línea de estado en la parte inferior del CLI con información de la sesión activa: modelo en uso, tokens consumidos, modo de permisos y estado de herramientas MCP. Esta línea se puede configurar en `settings.json`:

```json
{
  "statusLine": {
    "show": true,
    "format": "compact"
  }
}
```

Útil para mantener visibilidad del coste y el modelo sin necesidad de ejecutar `/cost` o `/status` manualmente.

### Directorios Adicionales con `--add-dir` y `additionalDirectories`

El flag `--add-dir` permite añadir directorios de trabajo adicionales al contexto de la sesión. Es especialmente útil en monorepos o cuando Claude Code necesita acceder a ficheros fuera del directorio actual:

```bash
# Dar acceso a librerías compartidas y documentación
claude --add-dir ../shared-libs --add-dir ../docs
```

Esta opción también se puede persistir en `settings.json` mediante la clave `additionalDirectories`, de forma que se aplique a todas las sesiones del proyecto sin tener que especificarla en cada ejecución:

```json
{
  "additionalDirectories": [
    "../shared-libs",
    "../docs"
  ]
}
```

**Caso de uso típico — monorepo con proyectos separados:**

```bash
# Estructura del monorepo
monorepo/
  frontend/    <-- directorio actual
  backend/
  shared/

# Dar acceso al backend y a módulos compartidos desde el frontend
claude --add-dir ../backend --add-dir ../shared
```

Con `additionalDirectories` en `.claude/settings.json` del directorio `frontend/`, Claude Code cargará automáticamente esos directorios en cada sesión, sin necesidad de flags adicionales.

---

## Resolución de Conflictos

```
Ejemplo: settings.json de proyecto tiene allow: ["Bash(npm test)"]
         managed tiene deny: ["Bash(*)"]

Resultado: Bash(npm test) está DENIED
(Managed siempre gana)

Ejemplo: Project tiene allow: ["Write(src/**)"]
         Local tiene deny: ["Write(src/config/*)"]

Resultado: Write(src/config/*) está DENIED
(Local tiene mayor precedencia que Project)
```

### Regla de deny

**deny SIEMPRE gana** independientemente del nivel.
Si cualquier nivel dice deny, la acción se bloquea.

---

## Ver Configuración Actual

```bash
claude
> /permissions    # Ver permisos efectivos
> /config         # Ver configuración completa
> /mcp            # Ver servidores MCP activos
```

---

## Tabla Resumen

| Nivel | Archivo | ¿Commitear? | Quién configura | Precedencia |
|-------|---------|------------|----------------|------------|
| Managed | ~/.claude/managed/ | N/A | Admin empresa | 1 (máx) |
| CLI | flags | N/A | Dev (por ejecución) | 2 |
| Local | .claude/settings.local.json | No (.gitignore) | Dev (personal) | 3 |
| Project | .claude/settings.json | Sí | Equipo | 4 |
| User | ~/.claude/settings.json | No | Dev (global) | 5 (mín) |
