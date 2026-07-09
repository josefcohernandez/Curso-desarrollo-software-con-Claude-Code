# Módulo 04: Memoria y CLAUDE.md

## Descripción general

Este módulo cubre el sistema de memoria de Claude Code: cómo recuerda contexto entre sesiones, cómo configurar instrucciones persistentes mediante archivos `CLAUDE.md` y cómo organizar reglas modulares para equipos y proyectos complejos. Dominar este sistema es la diferencia entre repetir instrucciones en cada sesión y tener un asistente que ya conoce tu proyecto.

## Tiempo estimado

**2 horas** (75 min de teoría + 45 min de ejercicios)

## Objetivos de aprendizaje

Al completar este módulo serás capaz de:

1. **Explicar** la jerarquía completa de memoria de Claude Code y cómo se resuelven los conflictos entre niveles.
2. **Crear** un archivo `CLAUDE.md` efectivo y conciso para un proyecto real.
3. **Configurar** reglas modulares con `.claude/rules/` para diferentes partes del codebase.
4. **Usar** reglas con filtro de ruta para aplicar instrucciones solo a archivos relevantes.
5. **Distinguir** entre lo que debe ir en `CLAUDE.md` y lo que Claude puede inferir por sí solo.
6. **Aplicar** plantillas de `CLAUDE.md` adaptadas a diferentes tipos de proyecto.
7. **Crear** ficheros de memoria tipados (`user`, `feedback`, `project`, `reference`) con el formato de frontmatter correcto.
8. **Decidir** qué información merece guardarse en memoria y qué mecanismo usar según el caso de uso.

## Contenido

### Teoría

| Archivo | Tema | Tiempo |
|---------|------|--------|
| [01-sistema-memoria.md](teoria/01-sistema-memoria.md) | Sistema de memoria completo | 15 min |
| [02-escribir-claude-md-efectivo.md](teoria/02-escribir-claude-md-efectivo.md) | Escribir un `CLAUDE.md` efectivo | 20 min |
| [03-reglas-modulares.md](teoria/03-reglas-modulares.md) | Reglas modulares con `.claude/rules/` | 10 min |
| [04-memoria-estructurada-con-tipos.md](teoria/04-memoria-estructurada-con-tipos.md) | Memoria estructurada: los 4 tipos de memoria | 30 min |

### Ejercicios

| Archivo | Tema | Tiempo |
|---------|------|--------|
| [01-crear-claude-md.md](ejercicios/01-crear-claude-md.md) | Crear `CLAUDE.md` para tu proyecto | 25 min |
| [02-reglas-modulares.md](ejercicios/02-reglas-modulares.md) | Crear y probar reglas modulares | 20 min |

### Ejemplos

| Archivo | Tema |
|---------|------|
| [MEMORY.md](ejemplos/memoria-tipada/MEMORY.md) | Índice de memoria con punteros a ficheros individuales |
| [usuario-data-scientist.md](ejemplos/memoria-tipada/usuario-data-scientist.md) | Ejemplo de memoria tipo `user` |
| [feedback-no-mockear-bd.md](ejemplos/memoria-tipada/feedback-no-mockear-bd.md) | Ejemplo de memoria tipo `feedback` |
| [proyecto-freeze-marzo.md](ejemplos/memoria-tipada/proyecto-freeze-marzo.md) | Ejemplo de memoria tipo `project` |
| [ref-bugs-linear.md](ejemplos/memoria-tipada/ref-bugs-linear.md) | Ejemplo de memoria tipo `reference` |

### Plantillas

| Archivo | Tipo de proyecto |
|---------|-----------------|
| [claude-md-frontend.md](plantillas/claude-md-frontend.md) | Frontend (React, Vue o Angular) |
| [claude-md-backend.md](plantillas/claude-md-backend.md) | Backend API (Node, Python o Java) |
| [claude-md-fullstack.md](plantillas/claude-md-fullstack.md) | Proyecto full stack |

## Prerrequisitos

- Haber completado los módulos 01 a 03
- Tener Claude Code instalado y funcionando
- Tener acceso a un repositorio de código (propio o de ejemplo)

## Conceptos clave

- **CLAUDE.md**: archivo de instrucciones persistentes que Claude carga al inicio de cada sesión.
- **Auto memory**: notas que Claude escribe automáticamente para sí mismo entre sesiones.
- **Reglas modulares**: archivos `.md` en `.claude/rules/` que se cargan automáticamente.
- **Reglas con filtro de ruta**: reglas que solo aplican a archivos que coinciden con un patrón `glob`.
- **Jerarquía de memoria**: sistema de precedencia donde lo más específico prevalece sobre lo general.
- **Tipos de memoria**: cuatro categorías de memoria estructurada: `user`, `feedback`, `project` y `reference`.
- **MEMORY.md**: índice central de memorias; solo contiene punteros a ficheros individuales, no contenido directo.

---

## Navegación

| Anterior | Siguiente |
|----------|-----------|
| [Módulo 03: Contexto y Tokens](../modulo-03-contexto-y-tokens/README.md) | [Módulo 05: Configuración y Permisos](../modulo-05-configuracion-permisos/README.md) |
