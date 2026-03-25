# Modulo 11: Enterprise y Seguridad

## Descripcion general

Este modulo aborda los aspectos criticos de seguridad y las funcionalidades enterprise de Claude Code. Aprenderemos que datos se comparten con Anthropic, como proteger credenciales, como configurar politicas gestionadas a nivel organizacion y cuales son las mejores practicas para equipos que adoptan Claude Code en entornos profesionales.

El contenido esta orientado a equipos mixtos poliglotas que trabajan con multiples lenguajes y frameworks, y necesitan garantizar que el uso de Claude Code cumple con los estandares de seguridad de su organizacion.

## Tiempo estimado

**1 hora 15 minutos** (incluye teoria y ejercicios practicos)

## Objetivos de aprendizaje

Al finalizar este modulo seras capaz de:

1. Comprender exactamente que datos accede y transmite Claude Code
2. Configurar Claude Code de forma segura para entornos profesionales
3. Gestionar credenciales y secretos correctamente
4. Configurar politicas enterprise gestionadas centralmente
5. Elegir el backend cloud adecuado (API directa, Bedrock, Vertex AI)
6. Implementar un flujo de trabajo seguro para equipos
7. Aplicar una checklist de seguridad a tu proyecto actual

## Contenido

### Teoria

| Archivo | Tema | Tiempo |
|---------|------|--------|
| [01-seguridad.md](teoria/01-seguridad.md) | Seguridad y privacidad de datos | 20 min |
| [02-enterprise.md](teoria/02-enterprise.md) | Funcionalidades enterprise | 15 min |
| [03-mejores-practicas-equipo.md](teoria/03-mejores-practicas-equipo.md) | Mejores practicas para equipos | 15 min |
| [04-managed-settings-d.md](teoria/04-managed-settings-d.md) | managed-settings.d/: politicas granulares por capa | 15 min |

### Ejercicios practicos

| Archivo | Ejercicio | Tiempo |
|---------|-----------|--------|
| [01-auditoria-seguridad.md](ejercicios/01-auditoria-seguridad.md) | Auditoria de seguridad de tu configuracion | 15 min |
| [02-configuracion-enterprise.md](ejercicios/02-configuracion-enterprise.md) | Configuracion tipo enterprise | 15 min |

### Plantillas

| Archivo | Descripcion |
|---------|-------------|
| [checklist-seguridad.md](plantillas/checklist-seguridad.md) | Checklist de seguridad para equipos |
| [guia-onboarding.md](plantillas/guia-onboarding.md) | Guia de onboarding para nuevos miembros |

## Prerequisitos

- Haber completado los modulos 1 a 10 (especialmente modulos 4, 5, 7 y 8)
- Tener Claude Code instalado y configurado
- Acceso a un proyecto con CLAUDE.md y settings.json existentes
- Conocimientos basicos de seguridad en desarrollo de software

## Nota para equipos poliglotas

Este modulo es especialmente relevante para equipos que trabajan con multiples lenguajes. Las politicas de seguridad y configuraciones enterprise aplican de forma transversal independientemente del stack tecnologico (Python, TypeScript, Rust, Go, Java, etc.). Los ejemplos incluyen configuraciones aplicables a cualquier ecosistema.
