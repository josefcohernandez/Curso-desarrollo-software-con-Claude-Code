# 03 - Sesiones y Continuidad

Una vez que se conocen los modos de ejecución disponibles, el siguiente paso es entender cómo Claude Code gestiona la continuidad del trabajo: qué es exactamente una sesión, cómo persiste entre invocaciones y cuándo conviene retomarla en lugar de comenzar desde cero.

## Concepto de Sesión

Una sesión en Claude Code es una conversación continua con un contexto compartido.
Todo lo que dices, los archivos que Claude lee y las acciones que ejecuta se acumulan
en la ventana de contexto de esa sesión.

---

## Tipos de Sesión

### Sesión Interactiva

```bash
claude                     # Nueva sesión
```

Conversación en tiempo real. Tú escribes, Claude responde, tú revisas.

### Sesión One-Shot (no interactiva)

```bash
claude -p "genera un Dockerfile para Node.js 22"
```

Un solo prompt, una sola respuesta. No hay continuidad.

### Sesión por Pipe

```bash
cat error.log | claude -p "analiza estos errores y sugiere fixes"
echo "SELECT * FROM users" | claude -p "optimiza esta query SQL"
```

Envía datos por stdin. Útil para scripts y automatización.

---

## Continuidad: Resume

Claude Code guarda el historial de tus sesiones. Puedes retomarlas:

```bash
# Continuar la última sesión
claude --resume

# Listar sesiones recientes
claude sessions list

# Continuar sesión específica por ID
claude --resume abc123def
```

### Cuándo usar Resume

| Escenario | Acción |
|-----------|--------|
| Dejaste una tarea a medias | `claude --resume` |
| Quieres revisar lo que hiciste | `claude --resume <id>` |
| Tarea nueva no relacionada | `claude` (sesión limpia) |
| Cambiaste de proyecto | `claude` (sesión limpia) |

> **Importante**: Resume carga todo el historial previo en el contexto.
> Si la sesión anterior era larga, puedes perder espacio de contexto.

---

## Los 3 Modos de Ejecución

### 1. Interactivo (por defecto)

```bash
claude
```

- Conversación bidireccional
- Claude pide confirmación para acciones según permisos
- Puedes corregir y redirigir en tiempo real

### 2. One-Shot (-p / --print)

```bash
claude -p "tu prompt aquí"
claude --print "tu prompt aquí"
```

- Un prompt, una respuesta
- Ideal para scripts, aliases, integración con otros tools
- No hay interacción posterior

### 3. Pipe (stdin)

```bash
echo "código" | claude -p "revisa este código"
cat file.txt | claude -p "resume este archivo"
git diff | claude -p "genera un commit message"
```

- Combina con otros comandos Unix
- El contenido de stdin se incluye en el prompt

---

## Flags Útiles de CLI

| Flag | Descripción | Ejemplo |
|------|------------|---------|
| `-p, --print` | Modo one-shot | `claude -p "hola"` |
| `--resume` | Continuar sesión | `claude --resume` |
| `--model` | Especificar modelo | `claude --model opus` |
| `--allowedTools` | Tools permitidos | `claude --allowedTools "Read,Glob"` |
| `--output-format` | Formato de salida | `claude -p "x" --output-format json` |
| `--max-turns` | Limitar iteraciones | `claude -p "x" --max-turns 5` |
| `--verbose` | Output detallado | `claude --verbose` |
| `--no-mcp` | Sin servidores MCP | `claude --no-mcp` |

---

## Formatos de Salida

Para modo one-shot, puedes controlar el formato:

```bash
# Texto plano (por defecto)
claude -p "explica X"

# JSON estructurado
claude -p "lista las dependencias" --output-format json

# Stream (en tiempo real)
claude -p "genera código largo" --output-format stream-json
```

---

## Títulos de Sesión Generados por IA

En la extensión de VSCode, Claude Code genera automáticamente un **título descriptivo** para cada sesión basándose en el contenido de la conversación. Esto facilita identificar sesiones pasadas al hacer resume sin necesidad de recordar IDs o fechas.

Los títulos se generan al vuelo y se actualizan conforme avanza la conversación. Por ejemplo, una sesión que comienza con "arregla el bug de login" puede titularse automáticamente como "Fix: autenticación con caracteres especiales".

---

## Mejores Prácticas de Sesión

1. **Una tarea = una sesión** (o `/clear` entre tareas)
2. **Resume solo para continuar** trabajo previo, no para "recordar"
3. **One-shot para automatización**, interactivo para desarrollo
4. **Monitoriza `/cost`** regularmente
5. **`/compact` si la sesión es larga** y necesitas seguir
6. **`Esc` para cancelar** si Claude va por mal camino

---

## Ejemplo: Flujo de un Día de Trabajo

```bash
# Mañana: bug fix
cd ~/proyecto
claude
> "Hay un bug en el login: usuarios con @ en el password no pueden entrar"
> [Claude investiga, propone fix, tú apruebas]
> /exit

# Mediodía: nueva feature
claude
> "Implementa endpoint GET /api/users/:id/orders con paginación"
> [Claude implementa]
> "Ejecuta los tests"
> [Claude ejecuta y corrige si fallan]
> /exit

# Tarde: code review
git diff main..feature-branch | claude -p "Revisa este diff buscando bugs y mejoras"

# Automatización: commit message
git diff --staged | claude -p "Genera un commit message conciso para estos cambios"
```
