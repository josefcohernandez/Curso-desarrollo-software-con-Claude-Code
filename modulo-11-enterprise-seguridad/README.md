# Módulo 11: Enterprise y Seguridad

## Descripción general

Este módulo aborda los aspectos críticos de seguridad y las funcionalidades enterprise de Claude Code. Aprenderemos qué datos se comparten con Anthropic, cómo proteger credenciales, cómo configurar políticas gestionadas a nivel de organización, cómo controlar los modelos disponibles y el proxy Claude Code Gateway, y cuáles son las mejores prácticas para equipos que adoptan Claude Code en entornos profesionales.

El contenido está orientado a equipos mixtos y políglotas que trabajan con múltiples lenguajes y frameworks, y necesitan garantizar que el uso de Claude Code cumple con los estándares de seguridad de su organización.

## Tiempo estimado

**1 hora y 45 minutos** (incluye teoría y ejercicios prácticos)

## Objetivos de aprendizaje

Al finalizar este módulo serás capaz de:

1. Comprender exactamente a qué datos accede y transmite Claude Code.
2. Configurar Claude Code de forma segura para entornos profesionales.
3. Gestionar credenciales y secretos correctamente.
4. Configurar políticas enterprise gestionadas centralmente.
5. Elegir el backend cloud adecuado (API directa, Bedrock, Vertex AI o Claude Code Gateway).
6. Implementar un flujo de trabajo seguro para equipos.
7. Aplicar una checklist de seguridad a tu proyecto actual.
8. Controlar los modelos disponibles a nivel de organización con modelos por defecto y `enforceAvailableModels`.
9. Configurar restricciones de versión y de fusión de settings (`requiredMinimumVersion`, `parentSettingsBehavior`) para toda la organización.

## Contenido

### Teoría

| Archivo | Tema | Tiempo |
|---------|------|--------|
| [01-seguridad.md](teoria/01-seguridad.md) | Seguridad y privacidad de datos | 22 min |
| [02-enterprise.md](teoria/02-enterprise.md) | Funcionalidades enterprise: modelos organizacionales, Gateway y OTEL | 28 min |
| [03-mejores-practicas-equipo.md](teoria/03-mejores-practicas-equipo.md) | Mejores prácticas para equipos | 15 min |
| [04-managed-settings-d.md](teoria/04-managed-settings-d.md) | `managed-settings.d/`: políticas granulares por capa | 20 min |

### Ejercicios prácticos

| Archivo | Ejercicio | Tiempo |
|---------|-----------|--------|
| [01-auditoria-seguridad.md](ejercicios/01-auditoria-seguridad.md) | Auditoría de seguridad de tu configuración | 15 min |
| [02-configuracion-enterprise.md](ejercicios/02-configuracion-enterprise.md) | Configuración tipo enterprise | 15 min |

### Plantillas

| Archivo | Descripción |
|---------|-------------|
| [managed-policy-ejemplo.md](plantillas/managed-policy-ejemplo.md) | Ejemplo base de política gestionada para entornos enterprise |
| [checklist-seguridad.md](plantillas/checklist-seguridad.md) | Checklist de seguridad para equipos |
| [guia-onboarding.md](plantillas/guia-onboarding.md) | Guía de onboarding para nuevos miembros |

## Prerrequisitos

- Haber completado los módulos 1 a 10 (especialmente los módulos 4, 5, 7 y 8)
- Tener Claude Code instalado y configurado
- Acceso a un proyecto con `CLAUDE.md` y `settings.json` ya existentes
- Conocimientos básicos de seguridad en desarrollo de software

## Nota para equipos políglotas

Este módulo es especialmente relevante para equipos que trabajan con múltiples lenguajes. Las políticas de seguridad y las configuraciones enterprise aplican de forma transversal, independientemente del stack tecnológico (Python, TypeScript, Rust, Go, Java, etc.). Los ejemplos incluyen configuraciones aplicables a cualquier ecosistema.

---

## Navegación

| Anterior | Siguiente |
|----------|-----------|
| [Módulo 10: Automatización y CI/CD](../modulo-10-automatizacion-cicd/README.md) | [Módulo 12: Metodologías de Desarrollo con IA](../modulo-12-metodologias-desarrollo-ia/README.md) |
