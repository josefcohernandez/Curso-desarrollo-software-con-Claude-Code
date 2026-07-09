# Referencia Rápida - Claude Code CLI

## Modos de Ejecución

```bash
claude                          # Interactivo
claude -p "prompt"              # One-shot
cat file | claude -p "prompt"   # Pipe
claude --resume                 # Continuar sesión
```

## Flags Principales

| Flag | Corto | Descripción |
|------|-------|-------------|
| `--print` | `-p` | Modo one-shot |
| `--resume` | | Continuar sesión |
| `--model` | | Elegir modelo (opus/sonnet/haiku) |
| `--output-format` | | `json`, `stream-json`, `text` |
| `--max-turns` | | Limitar iteraciones |
| `--allowedTools` | | Tools permitidos |
| `--verbose` | | Output detallado |
| `--no-mcp` | | Sin servidores MCP |
| `--dangerously-skip-permissions` | | Sin permisos (solo CI) |
| `--safe-mode` | | Arranca sin CLAUDE.md, plugins, skills, hooks ni MCP (troubleshooting) |

## Slash Commands

### Sesión
| Comando | Función |
|---------|---------|
| `/clear` | Limpiar contexto |
| `/compact [foco]` | Compactar conversación |
| `/exit` | Salir |
| `/resume` | Reanudar sesión anterior |
| `/cd <ruta>` | Cambiar de directorio sin romper el prompt cache |
| `/rewind` | Deshacer turno / volver a un punto de control (incluso antes de `/clear`) |

### Info
| Comando | Función |
|---------|---------|
| `/help` | Ayuda |
| `/cost` | Tokens y coste |
| `/model [nombre]` | Ver o cambiar modelo |
| `/doctor` (o `/checkup`) | Chequeo completo: diagnostica y repara |
| `/status` | Estado de la sesión |

### Config
| Comando | Función |
|---------|---------|
| `/init` | Crear CLAUDE.md |
| `/permissions` | Gestionar permisos |
| `/mcp` | Ver servidores MCP |
| `/config` | Ver configuración |
| `/memory` | Memoria automática |

### Modo
| Comando | Función |
|---------|---------|
| `/plan` | Activar Plan Mode |
| `Shift+Tab` | Alternar entre Plan y Normal |

## Atajos de Teclado

| Atajo | Acción |
|-------|--------|
| `Enter` | Enviar |
| `Shift+Enter` | Nueva línea |
| `Shift+Tab` | Alternar Plan Mode |
| `Tab` | Autocompletar |
| `Esc` | Cancelar |
| `Esc Esc` | Salir |
| `Alt+T` | Alternar Extended Thinking |
| `Ctrl+L` | Limpiar pantalla |

## Modelos

| Modelo | Uso | Coste (input/output por 1M tokens) |
|--------|-----|-------------------------------------|
| **Haiku** | Tareas simples | $1 / $5 |
| **Sonnet** | Desarrollo diario | $3 / $15 |
| **Opus** | Planificación, debugging complejo | $5 / $25 |

## Recetas Comunes

```bash
# Commit message automático
git diff --staged | claude -p "Genera commit message (conventional commits)"

# Code review de PR
git diff main..HEAD | claude -p "Revisa este diff buscando bugs"

# Documentar función
claude -p "Documenta todas las funciones en src/utils.ts"

# Generar tests
claude -p "Genera tests unitarios para src/auth/service.ts"

# Analizar logs
tail -100 app.log | claude -p "Analiza errores y sugiere fixes"

# Explicar error
claude -p "Explica este error: [pegar error]"
```

## Regla de Oro

```
1 tarea = 1 sesión (o /clear entre tareas)
Monitoriza /cost regularmente
Prompts específicos > prompts vagos
```
