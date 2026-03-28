# 01 - El sistema de memoria de Claude Code

## Introducción

Cada vez que inicias una sesión de Claude Code, el agente parte de cero: no recuerda lo que
hiciste ayer ni las decisiones que tomaste la semana pasada. Sin embargo, Claude Code tiene
un sistema de memoria que resuelve esto cargando archivos de contexto al inicio de cada sesión.

Existen **dos mecanismos** fundamentales:

1. **Auto memory** -- Claude escribe notas para sí mismo automáticamente.
2. **CLAUDE.md** -- Tú escribes instrucciones que Claude debe seguir.

Ambos se cargan al inicio de la sesión y forman parte del contexto con el que Claude trabaja.

---

## 1. Auto memory: la memoria automática

Cuando trabajas con Claude Code, el agente puede guardar automáticamente notas sobre el
proyecto para futuras sesiones. Estas notas se almacenan en:

```
~/.claude/projects/<hash-del-proyecto>/memory/
```

### Cómo funciona

- Claude detecta patrones, decisiones y hechos relevantes durante la sesión.
- Al final (o durante) la sesión, guarda esta información en archivos de memoria.
- El archivo principal es `MEMORY.md`, del cual se cargan las **primeras 200 líneas** al
  inicio de cada sesión.
- Existen también archivos temáticos (topic files) que se cargan **bajo demanda** cuando
  Claude los necesita.

### Ejemplo de contenido auto-generado

```markdown
# Memoria del proyecto

- El proyecto usa pnpm, no npm ni yarn.
- La base de datos es PostgreSQL 15 con Prisma como ORM.
- Los tests se ejecutan con: pnpm test -- --run
- El usuario prefiere mensajes de commit en español.
- La rama principal es "main", las features van en "feature/<nombre>".
```

### Activar o desactivar auto memory

La memoria automática está habilitada por defecto. Si quieres forzar su activación en un
entorno donde esté deshabilitada:

```bash
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=0
```

Para deshabilitarla completamente:

```bash
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
```

### El comando /memory

Puedes gestionar la memoria manualmente durante una sesión:

```
/memory                  # Ver la memoria actual del proyecto
/memory "nueva nota"     # Añadir una nota a la memoria
```

Esto es útil para forzar que Claude recuerde algo específico sin esperar a que lo detecte
automáticamente.

---

## 2. CLAUDE.md: instrucciones escritas por ti

Los archivos `CLAUDE.md` son el mecanismo principal para dar instrucciones persistentes a
Claude Code. Funcionan como un "briefing" que Claude lee cada vez que inicia una sesión en
tu proyecto.

A diferencia de la auto memory (que Claude escribe para sí mismo), `CLAUDE.md` lo escribes tú
y tu equipo. Es un archivo que **vive en el repositorio** (o en tu home) y que puedes versionar
con Git.

---

## 3. Jerarquía de memoria

Claude Code carga múltiples fuentes de memoria, con un orden de precedencia definido.
Lo más específico tiene prioridad sobre lo más general.

| Tipo | Ubicación | Propósito | Compartido con |
|------|-----------|-----------|----------------|
| **Managed policy** | `/etc/claude-code/CLAUDE.md` | Políticas de la organización | Todos los usuarios de la máquina |
| **Project** | `./CLAUDE.md` o `./.claude/CLAUDE.md` | Instrucciones del equipo | Todo el equipo (via Git) |
| **Project rules** | `./.claude/rules/*.md` | Reglas modulares por tema | Todo el equipo (via Git) |
| **User** | `~/.claude/CLAUDE.md` | Preferencias personales globales | Solo tú |
| **Auto memory** | `~/.claude/projects/<proyecto>/memory/` | Notas automáticas | Solo tú |

### Diagrama de precedencia

```
Más específico (gana en conflictos)
  ^
  |  .claude/rules/*.md       (equipo, reglas modulares)
  |  CLAUDE.md del proyecto   (equipo, instrucciones generales)
  |  ~/.claude/CLAUDE.md      (tú, todos los proyectos)
  |  /etc/claude-code/CLAUDE.md (organización)
  v
Más general
```

Cuando hay un conflicto entre niveles, **el más específico gana**. Por ejemplo:

- Si tu `CLAUDE.md` de proyecto dice "usa tabs" pero una regla en `.claude/rules/` dice
  "usa espacios", Claude usará espacios (porque las reglas modulares son más específicas).
- Si la política de la organización dice "no hagas push directo a main" y tu `CLAUDE.md` no
  dice nada al respecto, la política se aplica.

### Qué va en cada nivel

**Managed policy** (`/etc/claude-code/CLAUDE.md`):
- Restricciones de seguridad corporativas.
- Políticas de compliance obligatorias.
- Lo configura el equipo de IT/plataforma.

**Project** (`./CLAUDE.md`):
- Comandos de build, test, lint.
- Convenciones del equipo.
- Arquitectura del proyecto.
- Se versiona con Git, todo el equipo lo comparte.

**Project rules** (`./.claude/rules/*.md`):
- Reglas específicas por área del código.
- Reglas que aplican solo a ciertos archivos.
- Se versionan con Git. Se cubren en detalle en la lección 03.

**User** (`~/.claude/CLAUDE.md`):
- Tu idioma preferido para respuestas.
- Tu editor de preferencia.
- Estilo personal de commits.
- Aplica a TODOS tus proyectos.

**Preferencias locales personales**:
- Para preferencias locales que no se comparten, usar `.claude/settings.local.json`.
- Para instrucciones personales más extensas, crear un fichero personal e importarlo
  desde CLAUDE.md con `@~/.claude/mis-preferencias.md`.

---

## 4. Qué se carga y cuándo

Al iniciar una sesión, Claude Code:

1. Busca y carga `/etc/claude-code/CLAUDE.md` (si existe).
2. Busca y carga `~/.claude/CLAUDE.md` (si existe).
3. Busca y carga `./CLAUDE.md` o `./.claude/CLAUDE.md` (si existe).
4. Busca y carga todos los archivos en `./.claude/rules/` (si existen).
5. Carga las primeras 200 líneas de la auto memory del proyecto.

Todo esto se incorpora al contexto inicial de la sesión. Las reglas con filtro de ruta
(path-specific) se activan solo cuando Claude trabaja con archivos que coinciden con el
patrón.

---

## 5. Imports: compartir contenido entre archivos

Desde cualquier archivo `CLAUDE.md` o regla, puedes importar contenido de otros archivos:

```markdown
@docs/architecture.md
@../shared-rules/security.md
```

Las rutas pueden ser relativas (al archivo que importa) o absolutas. Esto es útil para:

- No duplicar instrucciones entre proyecto y reglas.
- Importar documentación existente del proyecto.
- Compartir reglas entre múltiples proyectos via symlinks.

---

## 6. Resumen práctico

| Pregunta | Respuesta |
|----------|-----------|
| Quiero que todo el equipo siga las mismas reglas | `./CLAUDE.md` + `.claude/rules/` |
| Quiero mis preferencias personales en todos los proyectos | `~/.claude/CLAUDE.md` |
| Quiero un override local que no se suba a Git | `.claude/settings.local.json` o importar `@~/.claude/mis-preferencias.md` |
| Quiero que Claude recuerde cosas automáticamente | Auto memory (por defecto) |
| Quiero que cierta regla solo aplique a archivos `.tsx` | `.claude/rules/` con frontmatter de paths |
| Quiero políticas de organización obligatorias | `/etc/claude-code/CLAUDE.md` |
