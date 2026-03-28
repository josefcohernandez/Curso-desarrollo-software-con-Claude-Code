# Cheatsheet General de Claude Code

> Referencia rapida para el dia a dia. Imprime o guarda esta pagina.

---

## Comandos de inicio

| Comando | Descripcion |
|---------|-------------|
| `claude` | Iniciar sesion interactiva |
| `claude "pregunta"` | Iniciar sesion con pregunta inicial |
| `claude -p "query"` | Modo one-shot (no interactivo) |
| `cat archivo \| claude -p "analiza"` | Pipe: enviar contenido a Claude |
| `claude -c` | Continuar la sesion mas reciente |
| `claude -r` | Elegir sesion para reanudar |
| `claude --model opus` | Iniciar con modelo especifico |
| `claude --model opusplan` | Opus para planificar, Sonnet para ejecutar |

---

## Slash Commands (modo interactivo)

| Comando | Descripcion | Cuando usarlo |
|---------|-------------|---------------|
| `/clear` | Limpiar contexto completamente | **Entre tareas no relacionadas** |
| `/compact` | Compactar contexto con foco | Cuando el contexto se llena pero quieres continuar |
| `/compact Enfocate en los cambios de API` | Compactar con instrucciones | Preservar solo lo relevante |
| `/context` | Ver uso del contexto | Monitorizar consumo |
| `/cost` | Ver costes de la sesion | Controlar gasto |
| `/model sonnet` | Cambiar modelo | Alternar segun la tarea |
| `/model opus` | Cambiar a Opus | Para razonamiento complejo |
| `/init` | Generar CLAUDE.md inicial | Al empezar un proyecto nuevo |
| `/memory` | Ver/editar memoria | Gestionar CLAUDE.md |
| `/permissions` | Ver permisos activos | Verificar configuracion |
| `/hooks` | Ver hooks configurados | Verificar hooks |
| `/mcp` | Gestionar servidores MCP | Activar/desactivar MCP |
| `/agents` | Gestionar agentes | Agent Teams |
| `/resume` | Reanudar sesion anterior | Volver a trabajo previo |
| `/rename nombre` | Renombrar sesion | Organizar sesiones |
| `/rewind` | Retroceder al estado anterior | Cuando Claude va mal camino |
| `/doctor` | Diagnostico de configuracion | Resolver problemas |
| `/bug` | Reportar un bug | Reportar problemas a Anthropic |

---

## Atajos de teclado

| Atajo | Accion |
|-------|--------|
| `Ctrl+C` | Parar a Claude a mitad de accion |
| `Esc` + `Esc` | Menu de rewind (deshacer) |
| `Shift+Tab` | Ciclar modos de permiso: Normal → Auto-Accept → Plan |
| `Ctrl+O` | Ver pensamiento de Claude (verbose mode) |
| `Ctrl+G` | Abrir plan en editor de texto |
| `Ctrl+B` | Enviar tarea al background |
| `Alt+T` / `Option+T` | Activar/desactivar extended thinking |
| `Alt+O` / `Option+O` | Activar/desactivar fast mode |
| `Ctrl+T` | Mostrar/ocultar lista de tareas |

---

## Modos de permisos

| Modo | Comportamiento | Atajo |
|------|---------------|-------|
| **Normal** (`default`) | Pregunta antes de ejecutar la mayoria de acciones | Por defecto |
| **Auto-accept** (`acceptEdits`) | Aprueba ediciones automaticamente, pregunta para Bash | `Shift+Tab` x1 |
| **Plan** (`plan`) | Solo propone planes, no ejecuta nada | `Shift+Tab` x2 |

> Modos adicionales (`auto`, `bypassPermissions`) se pueden habilitar con `--enable-auto-mode` o `--permission-mode`.

---

## Tecnicas de ahorro de tokens (Top 5)

1. **`/clear` entre tareas** — El habito mas importante
2. **Prompts especificos** — "valida el email en auth.ts" > "mejora el codigo"
3. **Subagentes para investigacion** — Mantienen su propio contexto
4. **Sonnet por defecto** — Opus solo para arquitectura/debugging complejo
5. **Desactivar MCP no usado** — Cada servidor consume contexto incluso idle

---

## Modelos y cuando usarlos

| Modelo | Coste relativo | Usar para |
|--------|---------------|-----------|
| **Haiku 4.5** | $ | Preguntas rapidas, subagentes simples, batch |
| **Sonnet 4.6** | $$ | Desarrollo diario (80% del tiempo) |
| **Opus 4.6** | $$ | Arquitectura, debugging complejo, security review (~1.7x Sonnet) |
| **opusplan** | $$ | Opus para planificar + Sonnet para implementar |

---

## Patron de trabajo recomendado

```
1. /clear (empezar limpio)
2. Describir tarea con contexto especifico
3. Revisar plan de Claude (Shift+Tab → Plan mode si es complejo)
4. Aprobar/ajustar plan
5. Shift+Tab → Auto-accept para implementacion
6. Verificar: tests, diff, revisar cambios
7. Commit si todo esta bien
8. /clear antes de la siguiente tarea
```

---

## Variables de entorno utiles

| Variable | Valor | Efecto |
|----------|-------|--------|
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `1` | Sin telemetria |
| `MAX_THINKING_TOKENS` | `8000` | Limitar tokens de pensamiento |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | `16000` | Limitar output |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `1` | Habilitar Agent Teams |
| `ENABLE_TOOL_SEARCH` | `auto:5` | Tool Search al 5% de contexto |

---

## Flujo de trabajo con Git

```bash
# Revisar cambios antes de commit
claude -p "revisa los cambios staged y sugiere un buen mensaje de commit" < <(git diff --staged)

# Review de PR
gh pr diff 123 | claude -p "review de seguridad y calidad de este PR"

# Generar release notes
git log v1.0..HEAD --oneline | claude -p "genera release notes en formato markdown"
```

---

## Recursos rapidos

- Docs oficiales: https://code.claude.com/docs
- Reportar bugs: https://github.com/anthropics/claude-code/issues
- MCP: https://modelcontextprotocol.io
- GitHub Action: https://github.com/anthropics/claude-code-action
