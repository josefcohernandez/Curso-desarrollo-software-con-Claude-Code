# 01 - Referencia Completa de Comandos CLI

Esta sección cubre en detalle todos los comandos, flags y modos de ejecución que ofrece Claude Code desde la línea de comandos. Dominar esta referencia permite integrar Claude Code tanto en el flujo de trabajo diario como en pipelines de automatización, aprovechando al máximo cada modalidad según la tarea que se tenga entre manos.

---

## 1. Modos de Ejecución

Claude Code ofrece tres modos principales de ejecución. Entender cuándo usar cada uno es clave para ser productivo.

### 1.1 Modo Interactivo

```bash
claude
```

Abre una sesión interactiva donde puedes mantener una conversación continua con Claude. Es el modo más común para desarrollo activo.

**Cuándo usarlo:**
- Desarrollo iterativo (escribir código, probar, ajustar)
- Exploración de un codebase
- Tareas que requieren varias interacciones
- Depuración paso a paso

**Ejemplo:**
```bash
$ claude
╭──────────────────────────────────────╮
│ ✻ Welcome to Claude Code!            │
│                                      │
│   /help for commands                 │
│   Type your question to get started  │
╰──────────────────────────────────────╯

> Analiza la estructura de este proyecto y dime qué framework usa
```

### 1.2 Modo One-Shot con Query Inline

```bash
claude "tu pregunta aquí"
```

Inicia una sesión interactiva con un mensaje inicial. Claude procesará tu pregunta y quedará esperando más instrucciones.

**Cuándo usarlo:**
- Quieres arrancar con una tarea específica pero podrías necesitar dar seguimiento
- Primera interacción de una sesión de trabajo

**Ejemplo:**
```bash
claude "Explica qué hace la función processPayment en src/services/payment.ts"
```

### 1.3 Modo No Interactivo (Pipe / One-Shot)

```bash
claude -p "tu pregunta aquí"
```

Ejecuta una única consulta, imprime la respuesta y termina. No mantiene sesión. Ideal para scripts y automatización.

**Cuándo usarlo:**
- Scripts de automatización (CI/CD, hooks)
- Procesamiento en batch
- Integración con otras herramientas vía pipe
- Cuando necesitas una única respuesta rápida

**Ejemplo:**
```bash
# Pregunta directa
claude -p "Genera un .gitignore para un proyecto Node.js con TypeScript"

# Pipe desde archivo
cat src/utils/helpers.ts | claude -p "Encuentra posibles bugs en este código"

# Pipe desde comando
git diff --staged | claude -p "Escribe un mensaje de commit para estos cambios"

# Encadenar con otros comandos
claude -p "Genera un Dockerfile para una app Node.js 20 con pnpm" > Dockerfile
```

### 1.4 Comparativa de Modos

| Característica | Interactivo (`claude`) | Query (`claude "..."`) | No interactivo (`-p`) |
|---|---|---|---|
| Sesión persistente | Sí | Sí | No |
| Múltiples turnos | Sí | Sí | No |
| Ideal para | Desarrollo | Inicio rápido | Scripts/CI |
| Usa stdin | No | No | Sí (opcional) |
| Formato salida | Renderizado | Renderizado | Texto plano / JSON |

---

## 2. Comandos Principales

### 2.1 `claude`

Inicia el modo interactivo. Es el punto de entrada principal.

```bash
claude                          # Sesión nueva
claude "analiza este proyecto"  # Sesión nueva con mensaje inicial
```

### 2.2 `claude -p "query"`

Modo no interactivo. Procesa una consulta y termina.

```bash
claude -p "¿Qué versión de Node.js necesita este proyecto?"
```

### 2.3 Pipe: `cat file | claude -p`

Envía contenido de archivos o comandos como contexto a Claude.

```bash
# Archivo como entrada
cat package.json | claude -p "Lista las dependencias de producción"

# Salida de comando como entrada
docker logs my-app --tail 50 | claude -p "¿Hay errores críticos en estos logs?"

# Múltiples archivos
cat src/models/*.py | claude -p "Genera un diagrama ER de estos modelos"
```

### 2.4 `claude -c` (Continue)

Reanuda la sesión interactiva más reciente del directorio actual.

```bash
claude -c                           # Retoma la última sesión
claude -c "ahora añade los tests"   # Retoma con un mensaje inicial
```

### 2.5 `claude -r` (Resume)

Abre un selector interactivo para elegir qué sesión reanudar.

```bash
claude -r                           # Selector de sesiones
claude -r "nombre-de-sesion"        # Reanuda sesión por nombre
```

### 2.6 `claude update`

Actualiza Claude Code a la última versión disponible.

```bash
claude update
```

### 2.7 `claude mcp`

Gestiona servidores MCP (Model Context Protocol). Permite añadir, listar y eliminar servidores de contexto.

```bash
claude mcp add nombre-servidor comando arg1 arg2  # Añadir servidor
claude mcp list                                    # Listar servidores
claude mcp remove nombre-servidor                  # Eliminar servidor
```

**Ejemplo práctico:**
```bash
# Añadir servidor MCP de filesystem
claude mcp add filesystem npx -y @modelcontextprotocol/server-filesystem /ruta/proyecto

# Añadir servidor MCP de base de datos PostgreSQL
claude mcp add postgres npx -y @modelcontextprotocol/server-postgres postgresql://user:pass@localhost/db
```

---

## 3. Flags por Categoría

### 3.1 Flags de Sesión

Controlan cómo se crean y reanudan las sesiones de trabajo.

| Flag | Descripción | Ejemplo |
|------|-------------|---------|
| `--continue`, `-c` | Reanuda la sesión más reciente del directorio actual | `claude -c` |
| `--resume`, `-r` | Abre selector de sesiones o reanuda por nombre | `claude -r "mi-sesion"` |
| `--fork-session` | Crea una copia (fork) de la sesión al reanudar. Se usa junto con `-c` o `-r` | `claude -c --fork-session` |
| `--session-id` | Reanuda una sesión específica por su ID interno | `claude --session-id abc123` |

**Ejemplo de flujo con sesiones:**
```bash
# Día 1: trabajas en una feature
claude "Implementa el endpoint POST /api/users"
# ... trabajas, usas /rename para llamarla "feature-users"

# Día 2: retomas donde lo dejaste
claude -c                    # Continúa la última sesión
# o
claude -r "feature-users"   # Busca por nombre

# Quieres probar algo sin afectar la sesión original
claude -c --fork-session     # Crea una copia para experimentar
```

### 3.2 Flags de Modelo

Permiten seleccionar qué modelo de Claude utilizar.

| Flag | Descripción | Ejemplo |
|------|-------------|---------|
| `--model` | Selecciona el modelo a usar | `claude --model opus` |
| `--fallback-model` | Modelo alternativo si el principal no está disponible | `claude --model opus --fallback-model sonnet` |

**Modelos disponibles:**

| Modelo | Uso recomendado | Velocidad | Capacidad |
|--------|----------------|-----------|-----------|
| `sonnet` | Uso general, buen balance velocidad/calidad | Rápida | Alta |
| `opus` | Tareas complejas, razonamiento profundo | Moderada | Muy alta |
| `haiku` | Tareas simples, consultas rápidas | Muy rápida | Buena |

**Ejemplos:**
```bash
# Usar Opus para refactoring complejo
claude --model opus "Refactoriza el módulo de autenticación para usar JWT"

# Usar Haiku para consultas rápidas en modo pipe
cat error.log | claude -p --model haiku "Resume los errores principales"

# Modelo con fallback
claude --model opus --fallback-model sonnet
```

### 3.3 Flags de Salida

Controlan el formato en que Claude devuelve las respuestas. Especialmente útiles en modo `-p`.

| Flag | Descripción | Ejemplo |
|------|-------------|---------|
| `--output-format` | Formato de salida: `text`, `json`, `stream-json` | `claude -p --output-format json "..."` |
| `--json-schema` | Fuerza la salida a cumplir un schema JSON específico | `claude -p --json-schema '{"type":"object",...}'` |
| `--verbose` | Muestra información detallada de depuración | `claude --verbose` |

**Formatos de salida explicados:**

#### `text` (por defecto en modo `-p`)
Devuelve texto plano sin formato adicional.
```bash
claude -p --output-format text "¿Qué versión de Python usa este proyecto?"
# Salida: Este proyecto usa Python 3.11
```

#### `json`
Devuelve un objeto JSON estructurado con metadata.
```bash
claude -p --output-format json "Lista los endpoints de la API"
```
Respuesta:
```json
{
  "type": "result",
  "subtype": "success",
  "cost_usd": 0.003,
  "is_error": false,
  "duration_ms": 1250,
  "duration_api_ms": 1100,
  "num_turns": 1,
  "result": "Los endpoints son:\n- GET /api/users\n- POST /api/users\n..."
}
```

#### `stream-json`
Emite eventos JSON línea por línea en tiempo real. Ideal para integraciones.
```bash
claude -p --output-format stream-json "Explica este código"
```
Cada línea es un evento JSON independiente:
```json
{"type":"assistant","message":{"content":[{"type":"text","text":"Este código..."}]}}
{"type":"result","subtype":"success","cost_usd":0.002,...}
```

#### Schema JSON personalizado
```bash
claude -p --json-schema '{
  "type": "object",
  "properties": {
    "bugs": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "archivo": {"type": "string"},
          "linea": {"type": "number"},
          "descripcion": {"type": "string"},
          "severidad": {"type": "string", "enum": ["baja", "media", "alta", "critica"]}
        },
        "required": ["archivo", "linea", "descripcion", "severidad"]
      }
    }
  },
  "required": ["bugs"]
}' "Analiza src/ en busca de bugs"
```

### 3.4 Flags de Permisos

Controlan qué acciones puede realizar Claude de forma autónoma.

| Flag | Descripción | Ejemplo |
|------|-------------|---------|
| `--permission-mode` | Modo de permisos: `default`, `acceptEdits`, `plan`, `bypassPermissions` | `claude --permission-mode plan` |
| `--allowedTools` | Lista de herramientas permitidas sin pedir confirmación | `claude --allowedTools "Read,Grep,Glob"` |
| `--disallowedTools` | Lista de herramientas bloqueadas | `claude --disallowedTools "Bash"` |
| `--dangerously-skip-permissions` | Omite TODAS las confirmaciones de permisos (PELIGROSO) | Solo para CI/CD controlado |

**Modos de permisos:**

| Modo | Comportamiento | Uso recomendado |
|------|---------------|-----------------|
| `default` | Pide confirmación para acciones destructivas | Uso diario normal |
| `acceptEdits` | Acepta ediciones automáticamente, pregunta para Bash | Tareas de confianza, scripts supervisados |
| `plan` | Solo planifica, no ejecuta cambios | Revisión de código, planificación |
| `bypassPermissions` | Omite todos los permisos (solo en entornos aislados) | CI/CD, entornos sandboxed |

**Ejemplo con herramientas permitidas:**
```bash
# Solo permite lectura, sin escritura ni ejecución
claude --allowedTools "Read,Grep,Glob,WebFetch" \
  -p "Analiza la arquitectura de este proyecto"

# Permite todo excepto ejecución de comandos
claude --disallowedTools "Bash" \
  "Refactoriza los modelos de datos"
```

> **ADVERTENCIA:** El flag `--dangerously-skip-permissions` solo debe usarse en entornos de CI/CD aislados, dentro de contenedores, y NUNCA en tu máquina local de desarrollo. Permite que Claude ejecute cualquier comando sin pedir confirmación.

### 3.5 Flags de Prompt del Sistema

Permiten personalizar las instrucciones del sistema que recibe Claude.

| Flag | Descripción | Ejemplo |
|------|-------------|---------|
| `--system-prompt` | Reemplaza completamente el prompt del sistema | `claude -p --system-prompt "Eres un experto en seguridad" "Analiza..."` |
| `--append-system-prompt` | Añade instrucciones al prompt del sistema por defecto | `claude -p --append-system-prompt "Responde siempre en español" "..."` |
| `--system-prompt-file` | Carga el prompt del sistema desde un archivo | `claude -p --system-prompt-file ./prompts/reviewer.txt "..."` |

**Ejemplo práctico:**
```bash
# Crear un archivo de prompt para revisiones de código
cat > prompts/code-reviewer.txt << 'EOF'
Eres un revisor de código senior. Analiza el código proporcionado y:
1. Identifica bugs potenciales
2. Sugiere mejoras de rendimiento
3. Verifica buenas prácticas de seguridad
4. Evalúa la legibilidad y mantenibilidad
Responde siempre en español con ejemplos de código corregido.
EOF

# Usarlo en una revisión
git diff main...feature-branch | claude -p \
  --system-prompt-file prompts/code-reviewer.txt \
  "Revisa estos cambios"
```

### 3.6 Flags de Límites

Controlan el consumo de recursos y la duración de las sesiones.

| Flag | Descripción | Ejemplo |
|------|-------------|---------|
| `--max-turns` | Número máximo de turnos (interacciones) en la sesión | `claude -p --max-turns 5 "..."` |
| `--max-budget-usd` | Presupuesto máximo en dólares para la sesión | `claude --max-budget-usd 1.00` |

**Ejemplos:**
```bash
# Limitar a 3 turnos (útil en CI/CD)
claude -p --max-turns 3 "Corrige los errores de lint en src/"

# Presupuesto máximo de 50 centavos
claude --max-budget-usd 0.50 "Refactoriza el módulo de pagos"

# Combinación para automatización controlada
claude -p \
  --max-turns 10 \
  --max-budget-usd 2.00 \
  --model sonnet \
  "Genera tests unitarios para todos los servicios en src/services/"
```

### 3.7 Flags Avanzados

Para casos de uso especializados y configuraciones avanzadas.

| Flag | Descripción | Ejemplo |
|------|-------------|---------|
| `--agents` | Define subagentes personalizados dinámicamente vía JSON. Usa los mismos campos que el frontmatter de subagentes, más un campo `prompt` | `claude --agents '{"reviewer":{"description":"Revisa código","prompt":"Eres un revisor"}}'` |
| `--mcp-config` | Carga configuración MCP desde archivo JSON | `claude --mcp-config ./mcp-servers.json` |
| `--tools` | Restringe qué herramientas integradas puede usar Claude. `""` para desactivar todas, `"default"` para todas, o nombres separados por coma | `claude --tools "Bash,Edit,Read"` |
| `--add-dir` | Añade directorios adicionales al contexto | `claude --add-dir ../shared-lib --add-dir ../common` |
| `--chrome` | Habilita la integración con el navegador Chrome para automatización web | `claude --chrome` |
| `--remote` | Crea una nueva sesión web en claude.ai con la descripción de tarea indicada | `claude --remote "Arregla el bug de login"` |
| `--teleport` | Reanuda una sesión web en el terminal local | `claude --teleport` |

**Ejemplo: Múltiples directorios**
```bash
# Trabajar con un monorepo
claude --add-dir ../packages/shared \
       --add-dir ../packages/ui-components \
       "El componente UserCard no renderiza correctamente el avatar"
```

**Ejemplo: Configuración MCP desde archivo**
```bash
# Archivo mcp-servers.json
cat > mcp-servers.json << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/project"]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost/mydb"
      }
    }
  }
}
EOF

claude --mcp-config ./mcp-servers.json
```

---

## 4. Combinaciones Útiles

### 4.1 Revisión de PR

```bash
# Obtener diff del PR y revisarlo
gh pr diff 42 | claude -p \
  --append-system-prompt "Eres un revisor de código experto. Busca bugs, problemas de seguridad y sugerencias de mejora." \
  "Revisa este PR"
```

### 4.2 Generación de Documentación

```bash
# Documentar una API completa
claude -p \
  --output-format json \
  --model opus \
  "Genera documentación OpenAPI 3.0 para todos los endpoints en src/routes/"
```

### 4.3 Análisis de Logs

```bash
# Analizar logs de producción
kubectl logs deployment/api-server --tail=200 | claude -p \
  --model haiku \
  "Identifica patrones de error y sugiere causas raíz"
```

### 4.4 Migración de Código

```bash
# Migrar de JavaScript a TypeScript
claude --model opus \
  --max-budget-usd 5.00 \
  "Migra todos los archivos .js en src/ a TypeScript (.ts) manteniendo la funcionalidad"
```

### 4.5 Pipeline de CI/CD

```bash
# En un workflow de GitHub Actions
claude -p \
  --dangerously-skip-permissions \
  --output-format json \
  --max-turns 5 \
  --max-budget-usd 1.00 \
  "Ejecuta los tests, identifica fallos y sugiere correcciones"
```

---

## 5. Ejemplos por Rol

### Para Backend

```bash
# Analizar rendimiento de queries SQL
cat queries/slow-queries.sql | claude -p "Optimiza estas queries SQL"

# Generar migración de base de datos
claude "Crea una migración para añadir la tabla 'audit_logs' con campos: id, user_id, action, resource, timestamp"

# Revisar seguridad de endpoints
claude -p --model opus "Revisa todos los endpoints en src/routes/ buscando vulnerabilidades OWASP Top 10"
```

### Para Frontend

```bash
# Convertir componente de clase a funcional
cat src/components/UserProfile.jsx | claude -p "Convierte este componente de clase a funcional con hooks"

# Generar tests de componentes
claude "Genera tests con React Testing Library para el componente LoginForm"

# Revisar accesibilidad
claude -p --model opus "Audita la accesibilidad (WCAG 2.1 AA) de los componentes en src/components/"
```

### Para DevOps

```bash
# Generar Dockerfile optimizado
claude -p "Genera un Dockerfile multi-stage para esta aplicación Node.js con pnpm"

# Analizar configuración de Kubernetes
cat k8s/*.yaml | claude -p "Revisa estas configuraciones de K8s buscando problemas de seguridad y rendimiento"

# Crear workflow de GitHub Actions
claude "Crea un workflow de GitHub Actions que haga lint, test y deploy a staging en push a develop"
```

### Para QA

```bash
# Generar casos de prueba
claude -p "Genera casos de prueba exhaustivos para el flujo de checkout basándote en src/pages/Checkout.tsx"

# Analizar cobertura
cat coverage/lcov.info | claude -p "Identifica las áreas del código con menor cobertura y sugiere tests prioritarios"

# Crear tests E2E
claude "Crea tests E2E con Playwright para el flujo de registro de usuario"
```

---

## Resumen

| Necesitas... | Usa... |
|---|---|
| Sesión de trabajo interactiva | `claude` |
| Arrancar con una tarea concreta | `claude "tarea"` |
| Respuesta única para script | `claude -p "pregunta"` |
| Enviar archivo como contexto | `cat archivo \| claude -p "..."` |
| Retomar la última sesión | `claude -c` |
| Elegir qué sesión retomar | `claude -r` |
| Modelo más potente | `--model opus` |
| Respuesta en JSON | `--output-format json` |
| Solo lectura/planificación | `--permission-mode plan` |
| Limitar gasto | `--max-budget-usd X` |
| Personalizar instrucciones | `--system-prompt "..."` |
