# Revisión de Errores y Alucinaciones

Revisión exhaustiva del contenido del curso. Se clasifican los hallazgos por severidad.

**Estado: CORREGIDO** — Los errores identificados han sido corregidos en el repositorio.

---

## ERRORES CORREGIDOS

### 1. Nombres de modelo inconsistentes ✅ CORREGIDO

El curso mezclaba versiones de modelos (Sonnet 4.5 vs 4.6, Opus 4.5 vs 4.6, Haiku 3.5 vs 4.5).

**Archivos corregidos:**
- `modulo-01/.../01-que-es-claude-code.md` — "Sonnet 4.5" → "Sonnet 4.6", identificador actualizado a `claude-sonnet-4-6`, Haiku actualizado a `claude-haiku-4-5-20251001`
- `modulo-03/.../01-la-ventana-de-contexto.md` — "Claude Sonnet 4" → "Claude Sonnet 4.6", "Claude Haiku 3.5" → "Claude Haiku 4.5"
- `modulo-03/.../04-prompt-caching-y-optimizacion-de-costes.md` — "Opus 4.5" → "Opus 4.6", "Sonnet 4.5" → "Sonnet 4.6"
- `modulo-03/.../ejemplos/comparativa-costes.md` — "Sonnet 4.5" → "Sonnet 4.6"
- `recursos/cheatsheets/cheatsheet-general.md` — "Sonnet 4.5" → "Sonnet 4.6"

### 2. Descripciones incorrectas de flags CLI ✅ CORREGIDO

`modulo-02-cli-primeros-pasos/teoria/01-comandos-cli.md` — Los flags `--agents`, `--tools`, `--chrome`, `--remote` y `--teleport` existían pero tenían descripciones incorrectas. Se alinearon con las descripciones del cheatsheet de referencia (`referencia-cli-flags-arranque.md`).

### 3. Comando `claude sessions list` ✅ CORREGIDO

`modulo-02/.../03-sesiones-y-continuidad.md` — Eliminado. Se usa `claude --resume` o `claude -r`.

### 4. Sección `/context` con output ficticio ✅ CORREGIDO

`modulo-03/.../01-la-ventana-de-contexto.md` — Reemplazada la sección que mostraba un output inventado demasiado detallado. Se redirige a `/cost` y la barra de estado como métodos verificados de monitorización.

### 5. Sintaxis incorrecta de `/model` ✅ CORREGIDO

`modulo-01/.../01-que-es-claude-code.md` — `/model opus 4.6` → `/model opus`

### 6. Módulo 15 (Plugins) ✅ DISCLAIMER AÑADIDO

`modulo-15-plugins-marketplaces/README.md` — Añadido warning sobre el estado experimental del ecosistema de plugins. El flag `--plugin-dir` existe, pero el marketplace público y `/plugin install` pueden no estar disponibles.

### 7. URLs de MCP fabricadas ✅ CORREGIDO

- `modulo-13/.../04-visual-driven-development.md` — `https://mcp.figma.com/mcp` reemplazado por comando real con `figma-developer-mcp`
- `modulo-14/.../03-herramientas-y-patrones-avanzados.md` — `https://api.githubcopilot.com/mcp/` reemplazado por `@modelcontextprotocol/server-github` (servidor MCP real)

### 8. `/install-github-app` ✅ CORREGIDO

- `modulo-10/.../02-github-actions.md` — Reemplazado por instrucciones manuales de setup (instalar GitHub App + configurar secreto + crear workflow)
- `modulo-10/README.md` y `recursos/cheatsheets/github-actions-claude-code.md` — Añadidos caveats sobre disponibilidad

### 9. Claim de npm "deprecado" ✅ CORREGIDO

`modulo-01/.../03-instalacion-configuracion-inicial.md` — "La instalación vía npm está oficialmente deprecada" → "La instalación vía npm sigue siendo válida como alternativa"

### 10. `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` ✅ CAVEAT AÑADIDO

`modulo-11/.../01-seguridad.md` — Añadida nota para verificar disponibilidad en la documentación oficial y alternativa usando hooks PreToolUse.

---

## FEATURES REALES (no requieren corrección)

Estas features fueron inicialmente sospechosas pero son reales:

| Feature | Estado |
|---------|--------|
| Deferred Tools y ToolSearch | ✅ Real |
| Subagent types (Explore, Plan, General-Purpose) | ✅ Real |
| Agent Teams (experimental) | ✅ Real — correctamente marcado como experimental |
| Managed Policies en `/etc/claude-code/settings.json` | ✅ Real — feature enterprise |
| `claude-code-action` GitHub Action | ✅ Real |
| Remote Control | ✅ Real |
| Computer Use | ✅ Real |
| headersHelper para MCP | ✅ Real |
| SessionStart hook | ✅ Real |
| Parámetro `model` en subagentes | ✅ Real |
| claude-agent-sdk (paquete) | ✅ Real |
| Hook field `if` para filtrado | ✅ Real |
| Flags `--chrome`, `--agents`, `--tools`, `--teleport` | ✅ Real (descripciones corregidas) |
| Extended Thinking + `Alt+T` | ✅ Real — `Alt+T` sigue activo para forzar thinking, adaptive thinking es el default |

---

## VERIFICACIÓN CONTRA DOCUMENTACIÓN OFICIAL (code.claude.com/docs)

### Cheatsheet de flags (`referencia-cli-flags-arranque.md`) — 51/55 correctos

| Hallazgo | Corrección aplicada |
|----------|-------------------|
| `--output-config` — flag fabricado | ✅ Eliminado |
| `--output-format` falsamente marcado como deprecated | ✅ Restaurado como activo |
| `--effort` incluía valor `auto` que no existe | ✅ Eliminado `auto` |
| `--bare` descripción incorrecta (mencionaba LSP) | ✅ Corregido |
| Faltaban `--enable-auto-mode`, `--tmux`, `--dangerously-load-development-channels` | ✅ Añadidos |

### Cheatsheet de slash commands (`referencia-cli-slash-commands.md`) — 61/62 correctos

| Hallazgo | Corrección aplicada |
|----------|-------------------|
| `/loop` descrito como toggle de agentic loop; es una skill para prompts recurrentes | ✅ Corregido |
| Faltaban `/schedule` y `/claude-api` | ✅ Añadidos |
| `/context` — ✅ Confirmado real en docs oficiales | No requería corrección |
| `/install-github-app` — ✅ Confirmado real en docs oficiales | No requería corrección |

### Variable `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` — ✅ Confirmada real

Aparece en la documentación oficial de env vars. Restaurada la descripción original.

---

## ITEMS PENDIENTES DE VERIFICACIÓN

1. **Tipos del Agent SDK** (`AssistantMessage`, `ResultMessage`) — Necesitan verificación contra la API real del SDK
2. **Eventos de hooks avanzados** (`TeammateIdle`, `TaskCompleted`, `ConfigChange`, `FileChanged`, etc.) — Algunos pueden existir pero requieren verificación
