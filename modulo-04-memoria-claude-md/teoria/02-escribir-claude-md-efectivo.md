# 02 - Escribir un CLAUDE.md Efectivo

## Por qué CLAUDE.md es Crítico

CLAUDE.md se carga al inicio de **cada sesión**. Es tu forma de "programar" el comportamiento
de Claude Code para tu proyecto. Un buen CLAUDE.md ahorra tokens, mejora la calidad y
asegura consistencia en el equipo.

---

## Estructura Recomendada

```markdown
# Proyecto: [Nombre]

## Descripción
[1-2 frases sobre qué hace el proyecto]

## Stack Tecnológico
- Backend: [lenguaje/framework]
- Frontend: [framework]
- BD: [base de datos]
- Tests: [framework de testing]

## Convenciones
- [Convenciones de código, naming, estructura]

## Comandos Frecuentes
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`
- Dev: `npm run dev`

## Estructura del Proyecto
[Descripción breve de directorios principales]

## Reglas para Claude
- [Instrucciones específicas de comportamiento]
```

---

## Principios de un Buen CLAUDE.md

### 1. Conciso (< 200 líneas idealmente)

CLAUDE.md se carga en CADA mensaje. Cada línea cuesta tokens repetidamente.

| Líneas CLAUDE.md | Tokens aprox | Coste extra por sesión (20 msgs, Sonnet) |
|-----------------|-------------|----------------------------------------|
| 50 líneas | ~500 tokens | ~$0.003 |
| 200 líneas | ~2,000 tokens | ~$0.012 |
| 500 líneas | ~5,000 tokens | ~$0.030 |
| 1,000 líneas | ~10,000 tokens | ~$0.060 |

### 2. Accionable, no informativo

```markdown
# Mal: informativo
Este proyecto fue creado en 2023 por el equipo de plataforma.
Usa React porque decidimos migrarlo desde Angular en Q2 2024.

# Bien: accionable
## Convenciones
- Componentes React en PascalCase, hooks con prefix use
- Tests colocados junto al archivo: Component.test.tsx
- No usar class components, solo funcionales con hooks
```

### 3. Específico para Claude, no documentación general

```markdown
# Mal: documentación general
React es una librería de JavaScript para construir interfaces de usuario.
Se basa en componentes reutilizables.

# Bien: instrucciones para Claude
## Reglas de código
- Usar TypeScript estricto (no `any`)
- Imports absolutos con @/ prefix
- Error handling con Result type, no try/catch
```

---

## Secciones Clave

### Comandos (ahorra muchas preguntas)

```markdown
## Comandos
- `npm test` - Tests unitarios (jest)
- `npm run test:e2e` - Tests E2E (playwright)
- `npm run lint` - ESLint + Prettier
- `npm run build` - Build producción
- `npm run db:migrate` - Migraciones
- `npm run db:seed` - Datos de prueba
```

### Reglas de Estilo

```markdown
## Estilo de Código
- Funciones: camelCase
- Clases: PascalCase
- Constantes: UPPER_SNAKE_CASE
- Archivos: kebab-case.ts
- Commits: conventional commits (feat:, fix:, chore:)
```

### Restricciones

```markdown
## Restricciones
- NO modificar archivos en /config/production/
- NO usar console.log (usar logger del proyecto)
- NO instalar dependencias sin confirmar
- NO hacer cambios en la BD de producción
- Siempre ejecutar tests antes de dar por terminada una tarea
```

### Respuestas de Claude

```markdown
## Cómo Responder
- Respuestas concisas, sin explicaciones innecesarias
- No repetir código que no cambió
- Preferir editar archivos existentes sobre crear nuevos
- Mostrar solo los cambios relevantes
```

---

## CLAUDE.md por Nivel

### Proyecto (.claude/CLAUDE.md o CLAUDE.md en raíz)

Compartido con todo el equipo via git. Contiene convenciones del proyecto.

### Preferencias locales personales

Para preferencias que no se comparten con el equipo, hay dos opciones:

1. **`.claude/settings.local.json`** para configuraciones locales simples (no se commitea).
2. **Fichero personal importado** desde CLAUDE.md: añadir `@~/.claude/mis-preferencias.md`
   en el CLAUDE.md del proyecto para cargar tus preferencias personales. El fichero
   `~/.claude/mis-preferencias.md` vive en tu home y no afecta al equipo.

```markdown
# Ejemplo de ~/.claude/mis-preferencias.md
- Yo trabajo principalmente en el módulo de pagos
- Prefiero explicaciones detalladas
- Ejecutar siempre lint después de editar
```

### User (~/.claude/CLAUDE.md)

Preferencias globales que aplican a TODOS tus proyectos:

```markdown
# Global
- Responde siempre en español
- Usa Sonnet por defecto
- No generes comentarios obvios en el código
```

---

## Errores Comunes

| Error | Por qué es malo | Corrección |
|-------|----------------|-----------|
| CLAUDE.md de 500+ líneas | Consume tokens en cada mensaje | Reducir a <200, mover detalles a rules/ |
| Documentación general | No ayuda a Claude a actuar | Solo instrucciones accionables |
| Sin comandos de build/test | Claude pregunta cada vez | Documentar comandos principales |
| Sin convenciones de código | Código inconsistente | Definir naming, imports, estructura |
| Instrucciones contradictorias | Comportamiento impredecible | Revisar y eliminar duplicados |

---

## Checklist de Calidad

- [ ] ¿Tiene descripción del proyecto en 1-2 frases?
- [ ] ¿Lista el stack tecnológico?
- [ ] ¿Incluye comandos de build, test, lint?
- [ ] ¿Define convenciones de código?
- [ ] ¿Tiene restricciones claras (qué NO hacer)?
- [ ] ¿Pide respuestas concisas?
- [ ] ¿Es menor a 200 líneas?
- [ ] ¿Cada línea es accionable (no informativa)?
