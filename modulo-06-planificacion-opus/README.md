# Módulo 06: Plan Mode, Opus 4.7 y Workflows

## Descripción general

Este módulo cubre las técnicas avanzadas de planificación con Claude Code: Plan Mode para diseñar antes de implementar, Opus 4.7 con razonamiento adaptativo (incluido el nuevo nivel `xhigh`) y workflows probados para maximizar la productividad. También revisa Fast Mode, la revisión multi-agente con `/ultrareview` y la gestión de sesiones cross-device.

## Objetivos

1. Dominar Plan Mode para diseñar antes de ejecutar.
2. Entender el razonamiento adaptativo de Opus 4.7 y los niveles de esfuerzo, incluido `xhigh`.
3. Saber cuándo usar Opus frente a Sonnet o Haiku, y gestionar cambios de modelo sin perder el prompt cache.
4. Aplicar workflows probados al día a día.
5. Usar `/ultrareview` para revisiones de código multi-agente en sesión interactiva y en CI/CD.

## Duración

**2 h 45 min** (105 min de teoría + 60 min de ejercicios)

## Prerrequisitos

Módulos 01-05 completados.

## Estructura

```text
modulo-06-planificacion-opus/
├── README.md
├── teoria/
│   ├── 01-plan-mode.md
│   ├── 02-opus-razonamiento-adaptativo.md
│   ├── 03-workflows-eficientes.md
│   ├── 04-fast-mode-y-modelos.md
│   ├── 05-sesiones-remotas-y-cross-device.md
│   └── 06-ultrareview-revision-multiagente.md
├── ejercicios/
│   ├── 01-plan-mode-practica.md
│   └── 02-workflow-completo.md
└── proyecto-practico/
    └── mini-proyecto-refactoring.md
```

## Contenido de teoría

| Fichero | Tema | Novedades |
|---------|------|-----------|
| `01-plan-mode.md` | Plan Mode: planificar antes de implementar | — |
| `02-opus-razonamiento-adaptativo.md` | Opus 4.7, niveles de esfuerzo, adaptive thinking | Opus 4.7, nivel `xhigh`, defaults Pro/Max, advertencia `/model` mid-conversación |
| `03-workflows-eficientes.md` | 5 workflows probados para el día a día | — |
| `04-fast-mode-y-modelos.md` | Fast Mode, tabla de modelos, effort slider | Opus 4.7 en tabla, slider interactivo `/effort`, nivel `xhigh` |
| `05-sesiones-remotas-y-cross-device.md` | Remote, teleport, fallback-model, Remote Control | URL de PR en picker de `/resume` |
| `06-ultrareview-revision-multiagente.md` | Revisión de código multi-agente en la nube | Nuevo (v2.1.111 + v2.1.120) |
