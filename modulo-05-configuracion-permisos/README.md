# Módulo 05: Configuración y Permisos

## Descripción general

Este módulo cubre el sistema de configuración multinivel de Claude Code y su modelo de permisos. Aprenderás a controlar qué puede hacer Claude Code, compartir configuraciones con tu equipo y asegurar distintos entornos de trabajo.

## Objetivos de aprendizaje

1. Comprender la jerarquía de cinco niveles de configuración.
2. Configurar permisos `allow` / `ask` / `deny` por herramienta.
3. Dominar los modos de operación.
4. Activar y configurar el sandbox.
5. Diseñar configuraciones por rol para equipos.
6. Activar y gestionar Auto Mode con su sistema de seguridad dual.

## Duración

**2 h 35 min** (110 min de teoría + 45 min de ejercicios)

## Prerrequisitos

Módulos 01-04 completados.

## Contenido de teoría

| Archivo | Tema | Duración |
|---------|------|----------|
| [01-jerarquia-settings.md](teoria/01-jerarquia-settings.md) | Jerarquía de configuración de 5 niveles | 15 min |
| [02-sistema-permisos.md](teoria/02-sistema-permisos.md) | Permisos `allow` / `ask` / `deny` por herramienta, sintaxis `Tool(param:value)`, modo Manual | 25 min |
| [03-sandbox-y-seguridad.md](teoria/03-sandbox-y-seguridad.md) | Sandbox y configuración de seguridad (`sandbox.credentials`, `allowAppleEvents`) | 20 min |
| [04-personalizacion-keybindings.md](teoria/04-personalizacion-keybindings.md) | Personalización y atajos de teclado | 15 min |
| [05-auto-mode.md](teoria/05-auto-mode.md) | Auto Mode: sistema de seguridad dual reforzado (`classifyAllShell`, `hard_deny`, bloqueo de git destructivo) | 25 min |

## Estructura

```text
modulo-05-configuracion-permisos/
├── README.md
├── teoria/
│   ├── 01-jerarquia-settings.md
│   ├── 02-sistema-permisos.md
│   ├── 03-sandbox-y-seguridad.md
│   ├── 04-personalizacion-keybindings.md
│   └── 05-auto-mode.md
├── ejercicios/
│   ├── 01-configurar-proyecto.md
│   └── 02-permisos-equipo.md
└── plantillas/
    ├── settings-restrictivo.json
    └── settings-permisivo.json
```

---

## Navegación

| Anterior | Siguiente |
|----------|-----------|
| [Módulo 04: Memoria y CLAUDE.md](../modulo-04-memoria-claude-md/README.md) | [Módulo 06: Plan Mode, Opus 4.8 y Workflows](../modulo-06-planificacion-opus/README.md) |
