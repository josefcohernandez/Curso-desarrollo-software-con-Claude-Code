# Módulo 12: Metodologías de Desarrollo con IA

## Descripción general

Este módulo presenta metodologías estructuradas para desarrollar software con Claude Code como copiloto. No se trata de "pedirle cosas a la IA", sino de aplicar procesos disciplinados que producen resultados predecibles y de calidad profesional. Cubrimos Spec-Driven Development, historias de usuario en formato Gherkin como entrada para Claude, TDD asistido por IA y patrones avanzados de trabajo en paralelo.

**Tiempo estimado:** 2 horas

---

## Objetivos de aprendizaje

Al completar este módulo, serás capaz de:

1. **Aplicar Spec-Driven Development** completo: entrevista → spec → implementación → verificación.
2. **Escribir historias de usuario en Gherkin** y usarlas como entrada directa para Claude.
3. **Practicar TDD asistido por IA**: Claude escribe tests primero y luego implementa.
4. **Usar el patrón Writer/Reviewer** con sesiones separadas.
5. **Aplicar fan-out** para migraciones y cambios a escala.
6. **Usar git worktrees** para sesiones paralelas aisladas.
7. **Elegir la metodología correcta** según el tipo de tarea.

---

## Estructura del módulo

### Teoría

| Archivo | Tema | Duración |
|---------|------|----------|
| [01-spec-driven-development.md](teoria/01-spec-driven-development.md) | Spec-Driven Development: de la entrevista al código | 30 min |
| [02-historias-usuario-gherkin.md](teoria/02-historias-usuario-gherkin.md) | Historias de usuario en Gherkin como entrada para Claude | 25 min |
| [03-tdd-con-ia.md](teoria/03-tdd-con-ia.md) | Test-Driven Development asistido por IA | 25 min |
| [04-patrones-avanzados.md](teoria/04-patrones-avanzados.md) | Writer/Reviewer, visual-driven, fan-out y worktrees | 20 min |

### Ejercicios prácticos

| Archivo | Ejercicio | Duración |
|---------|-----------|----------|
| [01-spec-desde-cero.md](ejercicios/01-spec-desde-cero.md) | Crear una spec completa vía entrevista con Claude | 20 min |
| [02-implementar-user-stories.md](ejercicios/02-implementar-user-stories.md) | De historias Gherkin a código funcionando | 20 min |
| [03-tdd-completo.md](ejercicios/03-tdd-completo.md) | Ciclo TDD completo con Claude | 20 min |

### Plantillas

| Archivo | Descripción |
|---------|-------------|
| [plantilla-spec.md](plantillas/plantilla-spec.md) | Template de especificación técnica |
| [plantilla-user-story-gherkin.md](plantillas/plantilla-user-story-gherkin.md) | Template de historia de usuario en Gherkin |
| [plantilla-plan-implementacion.md](plantillas/plantilla-plan-implementacion.md) | Template de plan de implementación |

---

## Prerrequisitos

- Haber completado los módulos 1 a 6 (especialmente M01, metodología, y M06, Plan Mode)
- Módulo 9 (skills y agentes) recomendado para patrones avanzados
- Familiaridad con conceptos de testing

---

## Conceptos clave

| Concepto | Descripción |
|----------|-------------|
| **Spec-Driven Development** | Metodología donde primero se crea una spec completa y después se implementa |
| **Entrevista con Claude** | Claude hace preguntas usando `AskUserQuestion` antes de implementar |
| **Gherkin** | Formato `Given / When / Then` para describir comportamiento esperado |
| **TDD con IA** | Claude escribe tests primero (`red`), luego implementa (`green`) y después refactoriza |
| **Writer/Reviewer** | Dos sesiones separadas: una implementa y otra revisa con contexto limpio |
| **Fan-out** | Distribuir trabajo en paralelo con `claude -p` sobre múltiples archivos |
| **Git worktrees** | Directorios de trabajo aislados del mismo repo para sesiones paralelas |

---

## Flujo de trabajo recomendado

```text
1. Teoría: Spec-Driven + Gherkin + TDD (80 min)
   |
2. Ejercicio 01: crear spec vía entrevista (20 min)
   |
3. Ejercicio 02: implementar user stories Gherkin (20 min)
   |
4. Ejercicio 03: ciclo TDD completo (20 min)
   |
5. Aplicar en el Módulo 17 (Proyecto Final)
```

---

## Por qué un módulo de metodologías

Las herramientas cambian. Claude Code evolucionará y aparecerán otros asistentes de IA. Pero las **metodologías** perduran. Un desarrollador que domine estas técnicas sacará partido de cualquier herramienta de IA, hoy y en el futuro.

La diferencia entre un desarrollador que "usa IA" y uno que **desarrolla con IA** está exactamente aquí: en tener un proceso disciplinado en lugar de improvisar cada interacción.

---

## Recursos adicionales

- [Best Practices - Documentación oficial](https://code.claude.com/docs/en/best-practices)
- [Common Workflows - Documentación oficial](https://code.claude.com/docs/en/common-workflows)
- [Cucumber - Referencia Gherkin](https://cucumber.io/docs/gherkin/reference/)

---

## Navegación

| Anterior | Siguiente |
|----------|-----------|
| [Módulo 11: Enterprise y Seguridad](../modulo-11-enterprise-seguridad/README.md) | [Módulo 13: Multimodalidad y Notebooks](../modulo-13-multimodalidad-notebooks/README.md) |
