# Referencia Rapida - Claude Code CLI

## Modos de Ejecucion

```bash
claude                          # Interactivo
claude -p "prompt"              # One-shot
cat file | claude -p "prompt"   # Pipe
claude --resume                 # Continuar sesion
```

## Flags Principales

| Flag | Corto | Descripcion |
|------|-------|-------------|
| `--print` | `-p` | Modo one-shot |
| `--resume` | | Continuar sesion |
| `--model` | | Elegir modelo (opus/sonnet/haiku) |
| `--output-format` | | json, stream-json, text |
| `--max-turns` | | Limitar iteraciones |
| `--allowedTools` | | Tools permitidos |
| `--verbose` | | Output detallado |
| `--no-mcp` | | Sin servidores MCP |
| `--dangerously-skip-permissions` | | Sin permisos (solo CI) |

## Slash Commands

### Sesion
| Comando | Funcion |
|---------|---------|
| `/clear` | Limpiar contexto |
| `/compact [foco]` | Comprimir conversacion |
| `/exit` | Salir |
| `/resume` | Reanudar sesion anterior |

### Info
| Comando | Funcion |
|---------|---------|
| `/help` | Ayuda |
| `/cost` | Tokens y coste |
| `/model [nombre]` | Ver/cambiar modelo |
| `/doctor` | Diagnostico |
| `/status` | Estado sesion |

### Config
| Comando | Funcion |
|---------|---------|
| `/init` | Crear CLAUDE.md |
| `/permissions` | Gestionar permisos |
| `/mcp` | Ver servidores MCP |
| `/config` | Ver configuracion |
| `/memory` | Memoria automatica |

### Modo
| Comando | Funcion |
|---------|---------|
| `/plan` | Activar Plan Mode |
| `Shift+Tab` | Toggle Plan/Normal |

## Atajos de Teclado

| Atajo | Accion |
|-------|--------|
| `Enter` | Enviar |
| `Shift+Enter` | Nueva linea |
| `Shift+Tab` | Toggle Plan Mode |
| `Tab` | Autocompletar |
| `Esc` | Cancelar |
| `Esc Esc` | Salir |
| `Alt+T` | Toggle Extended Thinking |
| `Ctrl+L` | Limpiar pantalla |

## Modelos

| Modelo | Uso | Coste (input/output por 1M tokens) |
|--------|-----|-------------------------------------|
| **Haiku** | Tareas simples | $1 / $5 |
| **Sonnet** | Desarrollo diario | $3 / $15 |
| **Opus** | Planificacion, debugging complejo | $5 / $25 |

## Recetas Comunes

```bash
# Commit message automatico
git diff --staged | claude -p "Genera commit message (conventional commits)"

# Code review de PR
git diff main..HEAD | claude -p "Revisa este diff buscando bugs"

# Documentar funcion
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
1 tarea = 1 sesion (o /clear entre tareas)
Monitoriza /cost regularmente
Prompts especificos > prompts vagos
```
