# Módulo 06: Plan Mode, Opus 4.8 y Workflows

## Descripción general

Este módulo cubre las técnicas avanzadas de planificación con Claude Code: Plan Mode para diseñar antes de implementar, **Opus 4.8** (el nuevo flagship, sucesor de Opus 4.7) con razonamiento adaptativo (incluido el nivel `xhigh`) y workflows probados para maximizar la productividad. También revisa Fast Mode, la selección de modelo entre **Opus 4.8, Sonnet 5 y Fable 5**, la configuración de `fallbackModel` con hasta 3 modelos de respaldo, la evolución de los comandos de revisión de código (de `/simplify` a `/code-review`, y su relación con `/review` y `/ultrareview`) y la gestión de sesiones cross-device.

## Objetivos

1. Dominar Plan Mode para diseñar antes de ejecutar.
2. Entender el razonamiento adaptativo de Opus 4.8 y los niveles de esfuerzo, incluido `xhigh`.
3. Saber cuándo usar Opus 4.8, Sonnet 5, Fable 5 o Haiku, y gestionar cambios de modelo sin perder el prompt cache.
4. Configurar `fallbackModel` con varios modelos de respaldo y entender cuándo `/model` guarda el cambio como nuevo modelo por defecto.
5. Aplicar workflows probados al día a día.
6. Usar `/ultrareview` y `/code-review` para revisiones de código multi-agente en sesión interactiva y en CI/CD, y distinguirlos de la revisión rápida con `/review`.

## Duración

**3 h 05 min** (125 min de teoría + 60 min de ejercicios)

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
│   ├── 06-ultrareview-revision-multiagente.md
│   └── 07-fallback-model-y-comandos-revision.md
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
| `02-opus-razonamiento-adaptativo.md` | Opus 4.8, niveles de esfuerzo, adaptive thinking | Opus 4.8 como flagship, nivel `xhigh`, defaults Pro/Max, advertencia `/model` mid-conversación |
| `03-workflows-eficientes.md` | 5 workflows probados para el día a día | — |
| `04-fast-mode-y-modelos.md` | Fast Mode, tabla de modelos, effort slider | Opus 4.8 en tabla junto a Sonnet 5 y Fable 5, Fast mode a 2x tarifa/2.5x velocidad, slider interactivo `/effort` |
| `05-sesiones-remotas-y-cross-device.md` | Remote, teleport, fallback-model, Remote Control | URL de PR en picker de `/resume`, `--fallback-model` ampliado |
| `06-ultrareview-revision-multiagente.md` | Revisión de código multi-agente en la nube | Nuevo (v2.1.111 + v2.1.120), evolución hacia `/code-review` |
| `07-fallback-model-y-comandos-revision.md` | `fallbackModel` con hasta 3 modelos, comportamiento de `/model`, defaults organizacionales, `/code-review` vs `/review` | Nuevo (refresh v3.9, v2.1.128-v2.1.205) |

---

## Navegación

| Anterior | Siguiente |
|----------|-----------|
| [Módulo 05: Configuración y Permisos](../modulo-05-configuracion-permisos/README.md) | [Módulo 07: MCP (Model Context Protocol)](../modulo-07-mcp/README.md) |
