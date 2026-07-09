# Módulo 14: Claude Agent SDK

## Construir agentes personalizados programáticamente

> **Tiempo estimado:** 2 horas
> **Nivel:** Experto (Bloque 4)
> **Prerrequisitos:** Módulos 01-09 completados

---

## Objetivos de aprendizaje

Al terminar este módulo serás capaz de:

- Distinguir el Agent SDK de otras formas de usar Claude (API directa, subagentes de Claude Code y CLI)
- Instalar y configurar el Agent SDK en Python y TypeScript
- Construir un agente básico con herramientas integradas y bucle agéntico automático
- Aplicar patrones avanzados: orquestación de subagentes, pipelines y evaluadores
- Integrar servidores MCP como fuentes de datos y herramientas del agente
- Gestionar sesiones, hooks y permisos desde código
- Decidir cuándo usar el Agent SDK frente a otras alternativas

---

## Prerrequisitos

| Módulo | Por qué es necesario |
|--------|----------------------|
| [M01](../modulo-01-introduccion/README.md) | Conceptos de agencia y bucle agéntico |
| [M03](../modulo-03-contexto-y-tokens/README.md) | Gestión de contexto y tokens |
| [M05](../modulo-05-configuracion-permisos/README.md) | Sistema de permisos |
| [M07](../modulo-07-mcp/README.md) | Protocolo MCP, servidores y herramientas |
| [M08](../modulo-08-hooks/README.md) | Hooks del ciclo de vida |
| [M09](../modulo-09-agentes-skills-teams/README.md) | Subagentes, skills y orquestación |

---

## Duración estimada

| Sección | Tiempo |
|---------|--------|
| Teoría (4 ficheros) | 80 min |
| Ejercicios prácticos | 40 min |
| **Total** | **2 horas** |

---

## Contenido

### Teoría

| Archivo | Tema | Duración |
|---------|------|----------|
| [01-introduccion-agent-sdk.md](teoria/01-introduccion-agent-sdk.md) | Qué es el Agent SDK, cuándo usarlo y su arquitectura | 20 min |
| [02-construir-agente-basico.md](teoria/02-construir-agente-basico.md) | Estructura mínima, herramientas integradas y bucle agéntico | 20 min |
| [03-herramientas-y-patrones-avanzados.md](teoria/03-herramientas-y-patrones-avanzados.md) | Patrones avanzados, MCP, sesiones, hooks y observabilidad | 25 min |
| [04-integracion-con-claude-code.md](teoria/04-integracion-con-claude-code.md) | Workflow Claude Code + Agent SDK, deploy y comparativa de frameworks | 15 min |

### Ejercicios prácticos

| Archivo | Tema | Duración |
|---------|------|----------|
| [01-primer-agente.md](ejercicios/01-primer-agente.md) | Cinco ejercicios progresivos, desde un agente básico hasta una CLI personalizada | 40 min |

---

## Conceptos clave

| Concepto | Descripción |
|----------|-------------|
| `query()` | Función principal del SDK; devuelve un iterador asíncrono de mensajes |
| Bucle agéntico | Claude decide qué herramientas usar, las ejecuta y observa resultados automáticamente |
| `ClaudeAgentOptions` | Configuración del agente: herramientas, permisos, system prompt, MCP y hooks |
| `allowed_tools` | Lista de herramientas preaprobadas que el agente puede usar sin pedir permiso |
| `permission_mode` | Nivel de supervisión humana: `acceptEdits`, `bypassPermissions`, `manual` (antes `default`) |
| `AgentDefinition` | Definición de un subagente especializado |
| `HookMatcher` | Asocia callbacks a eventos del ciclo de vida dentro del SDK |
| `resume` | Reanuda una sesión existente por su ID para mantener contexto entre ejecuciones |

---

## Flujo de trabajo recomendado

```text
1. DISEÑAR el agente en Claude Code (Plan Mode)
        |
        v
2. PROTOTIPAR con subagentes de Claude Code (M09)
        |
        v
3. IMPLEMENTAR con Agent SDK (Python o TypeScript)
        |
        v
4. TESTEAR localmente con permission_mode="acceptEdits"
        |
        v
5. DESPLEGAR como servicio, CLI o GitHub Action
```

---

## Diferencias clave con los subagentes de Claude Code

| Aspecto | Subagentes (M09) | Agent SDK |
|---------|------------------|-----------|
| Entorno | Dentro de Claude Code CLI | Tu propia aplicación |
| Control | Declarativo (YAML frontmatter) | Programático (Python/TS) |
| Integración | Con tu flujo de desarrollo | Con cualquier sistema |
| Despliegue | No aplica (es interactivo) | Servicio, CLI o CI/CD |
| Casos de uso | Automatizar tareas de desarrollo | Construir productos con agentes |

---

## Navegación

| Anterior | Siguiente |
|----------|-----------|
| [Módulo 13: Multimodalidad y Notebooks](../modulo-13-multimodalidad-notebooks/README.md) | [Módulo 15: Plugins y Marketplaces](../modulo-15-plugins-marketplaces/README.md) |
