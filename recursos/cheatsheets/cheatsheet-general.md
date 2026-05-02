# Cheatsheet General de Claude Code

> Referencia rápida para el día a día. Imprime o guarda esta página.

---

## Comandos de inicio

| Comando | Descripción |
|---------|-------------|
| `claude` | Iniciar sesión interactiva |
| `claude "pregunta"` | Iniciar sesión con pregunta inicial |
| `claude -p "query"` | Modo one-shot (no interactivo) |
| `cat archivo \| claude -p "analiza"` | Pipe: enviar contenido a Claude |
| `claude -c` | Continuar la sesión más reciente |
| `claude -r` | Elegir sesión para reanudar |
| `claude --model opus` | Iniciar con un modelo específico |
| `claude --model opusplan` | Opus para planificar, Sonnet para ejecutar |

---

## Slash Commands (modo interactivo)

| Comando | Descripción | Cuándo usarlo |
|---------|-------------|---------------|
| `/clear` | Limpiar contexto completamente | **Entre tareas no relacionadas** |
| `/compact` | Compactar contexto con foco | Cuando el contexto se llena pero quieres continuar |
| `/compact Enfócate en los cambios de API` | Compactar con instrucciones | Preservar solo lo relevante |
| `/context` | Ver uso del contexto | Monitorizar consumo |
| `/cost` | Ver costes de la sesión | Controlar gasto |
| `/model sonnet` | Cambiar modelo | Alternar según la tarea |
| `/model opus` | Cambiar a Opus | Para razonamiento complejo |
| `/init` | Generar CLAUDE.md inicial | Al empezar un proyecto nuevo |
| `/memory` | Ver o editar memoria | Gestionar `CLAUDE.md` |
| `/permissions` | Ver permisos activos | Verificar configuración |
| `/hooks` | Ver hooks configurados | Verificar hooks |
| `/mcp` | Gestionar servidores MCP | Activar o desactivar MCP |
| `/agents` | Gestionar agentes | Agent Teams |
| `/resume` | Reanudar sesión anterior | Volver a trabajo previo |
| `/rename nombre` | Renombrar sesión | Organizar sesiones |
| `/rewind` | Retroceder al estado anterior | Cuando Claude va mal camino |
| `/doctor` | Diagnóstico de configuración | Resolver problemas |
| `/bug` | Reportar un bug | Reportar problemas a Anthropic |

---

## Atajos de teclado

| Atajo | Acción |
|-------|--------|
| `Ctrl+C` | Parar a Claude a mitad de acción |
| `Esc` + `Esc` | Menú de rewind (deshacer) |
| `Shift+Tab` | Ciclar modos de permiso: Normal → Auto-Accept → Plan |
| `Ctrl+O` | Ver pensamiento de Claude (verbose mode) |
| `Ctrl+G` | Abrir plan en editor de texto |
| `Ctrl+B` | Enviar tarea al background |
| `Alt+T` / `Option+T` | Activar o desactivar extended thinking |
| `Alt+O` / `Option+O` | Activar o desactivar fast mode |
| `Ctrl+T` | Mostrar u ocultar lista de tareas |

---

## Modos de permisos

| Modo | Comportamiento | Atajo |
|------|---------------|-------|
| **Normal** (`default`) | Pregunta antes de ejecutar la mayoría de acciones | Por defecto |
| **Auto-accept** (`acceptEdits`) | Aprueba ediciones automáticamente; pregunta para Bash | `Shift+Tab` x1 |
| **Plan** (`plan`) | Solo propone planes, no ejecuta nada | `Shift+Tab` x2 |

> Modos adicionales (`auto`, `bypassPermissions`) se pueden habilitar con `--permission-mode` (el flag `--enable-auto-mode` fue eliminado en v2.1.111).

---

## Técnicas de ahorro de tokens (Top 5)

1. **`/clear` entre tareas** — El hábito más importante
2. **Prompts específicos** — "valida el email en auth.ts" > "mejora el código"
3. **Subagentes para investigación** — Mantienen su propio contexto
4. **Sonnet por defecto** — Opus solo para arquitectura o debugging complejo
5. **Desactivar MCP no usado** — Cada servidor consume contexto incluso en idle

---

## Modelos y cuándo usarlos

| Modelo | Coste relativo | Usar para |
|--------|---------------|-----------|
| **Haiku 4.5** | $ | Preguntas rápidas, subagentes simples, batch |
| **Sonnet 4.6** | $$ | Desarrollo diario (80% del tiempo) |
| **Opus 4.6** | $$ | Arquitectura, debugging complejo, security review (~1.7x Sonnet) |
| **opusplan** | $$ | Opus para planificar + Sonnet para implementar |

---

## Patrón de trabajo recomendado

```
1. /clear (empezar limpio)
2. Describir la tarea con contexto específico
3. Revisar el plan de Claude (Shift+Tab → Plan mode si es complejo)
4. Aprobar o ajustar el plan
5. Shift+Tab → Auto-accept para implementación
6. Verificar: tests, diff y cambios
7. Commit si todo está bien
8. /clear antes de la siguiente tarea
```

---

## Variables de entorno útiles

| Variable | Valor | Efecto |
|----------|-------|--------|
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `1` | Sin telemetría |
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

## Recursos rápidos

- Docs oficiales: https://code.claude.com/docs
- Reportar bugs: https://github.com/anthropics/claude-code/issues
- MCP: https://modelcontextprotocol.io
- GitHub Action: https://github.com/anthropics/claude-code-action
