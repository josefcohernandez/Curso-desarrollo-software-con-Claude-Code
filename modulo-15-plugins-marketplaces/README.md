# Modulo 15: Plugins y Marketplaces

## Empaquetar, Distribuir y Gestionar Capacidades en Claude Code

> **Tiempo estimado:** 1.5 horas
> **Nivel:** Experto (Bloque 4)
> **Prerequisitos:** Modulos 07 (MCP), 08 (Hooks), 09 (Subagentes y Skills)

> [!WARNING]
> **Estado del ecosistema de plugins:** El sistema de plugins de Claude Code está en fase temprana de desarrollo. Algunas funcionalidades descritas en este módulo (como el marketplace público, el comando `claude plugin install` o la estructura exacta de `.claude-plugin/plugin.json`) pueden no estar disponibles en tu versión o funcionar de forma diferente a lo documentado aquí. El flag `--plugin-dir` para cargar plugins locales sí está disponible. Consulta la documentación oficial de tu versión para confirmar la disponibilidad de cada feature.

---

## Objetivos de Aprendizaje

Al terminar este modulo seras capaz de:

- Explicar que es un plugin de Claude Code y como se diferencia de un skill, hook o servidor MCP individual
- Identificar los plugins y extensiones mas comunes del ecosistema (VS Code, JetBrains, GitHub, bases de datos, etc.)
- Crear un plugin propio que empaquete skills, hooks y subagentes en una unidad distribuible
- Explorar el marketplace con el comando `/plugin` y gestionar instalaciones a nivel de proyecto y usuario
- Configurar marketplaces privados y politicas de plugins para entornos enterprise

---

## Prerequisitos

| Modulo | Por que es necesario |
|--------|----------------------|
| [M07](../modulo-07-mcp/README.md) | MCP servers: base tecnica de muchos plugins de integracion |
| [M08](../modulo-08-hooks/README.md) | Hooks del ciclo de vida: componente fundamental de los plugins |
| [M09](../modulo-09-agentes-skills-teams/README.md) | Skills y subagentes: el otro componente principal de un plugin |

---

## Duracion Estimada

| Seccion | Tiempo |
|---------|--------|
| Teoria (4 ficheros) | 60 min |
| Ejercicios practicos | 30 min |
| **Total** | **1.5 horas** |

---

## Contenido

### Teoria

| Archivo | Tema | Duracion |
|---------|------|----------|
| [01-que-son-los-plugins.md](teoria/01-que-son-los-plugins.md) | Definicion, estructura, scopes y ciclo de vida de un plugin | 15 min |
| [02-plugins-integrados.md](teoria/02-plugins-integrados.md) | Ecosistema de plugins: IDE, integraciones de servicios y productividad | 20 min |
| [03-crear-plugin-propio.md](teoria/03-crear-plugin-propio.md) | Manifest, estructura de carpetas, empaquetar y publicar | 15 min |
| [04-marketplaces-y-gestion-enterprise.md](teoria/04-marketplaces-y-gestion-enterprise.md) | Marketplace publico, marketplaces privados y politicas enterprise | 10 min |

### Ejercicios Practicos

| Archivo | Tema | Duracion |
|---------|------|----------|
| [01-explorar-y-crear-plugins.md](ejercicios/01-explorar-y-crear-plugins.md) | Cinco ejercicios: desde explorar el marketplace hasta publicar un plugin de equipo | 30 min |

---

## Conceptos Clave

| Concepto | Descripcion |
|----------|-------------|
| Plugin | Bundle que agrupa skills, hooks, subagentes y/o servidores MCP en una unidad distribuible con manifest |
| `.claude-plugin/plugin.json` | Manifest del plugin: nombre, version, autor y descripcion. Los componentes se descubren automaticamente por estructura de directorios |
| `/plugin` | Comando interactivo con pestanas (Discover, Installed, Marketplaces, Errors) para explorar y gestionar plugins |
| `claude plugin install` | Comando CLI para instalar plugins: `claude plugin install <nombre>@<marketplace>` |
| `claude --plugin-dir` | Flag para cargar un plugin local durante desarrollo/testing |
| Marketplace privado | Repositorio de plugins de una organizacion, configurable con `extraKnownMarketplaces` en settings |
| `strictKnownMarketplaces` | Configuracion enterprise que limita las instalaciones a marketplaces aprobados |
| `blockedMarketplaces` | Configuracion enterprise para bloquear fuentes de plugins especificas |
| Ciclo de vida | Secuencia: instalar -> usar -> actualizar -> desinstalar |

---

## Flujo de Trabajo Recomendado

```
1. IDENTIFICAR necesidad
   ¿Que capacidad falta en tu flujo de trabajo?
        |
        v
2. EXPLORAR el marketplace
   /plugin → navegar pestanas (Discover, Installed) → evaluar permisos y reputacion
        |
        v
3. INSTALAR y PROBAR
   claude plugin install <nombre>@<marketplace>
        |
        v
4. Si no existe lo que necesitas:
   CREAR plugin propio (teoria/03)
   Probar localmente con: claude --plugin-dir ./mi-plugin
        |
        v
5. PUBLICAR (opcional)
   Formulario web en platform.claude.com
        |
        v
6. En contexto enterprise:
   PUBLICAR en marketplace privado → DISTRIBUIR al equipo
```

---

## Relacion con Otros Modulos

Este modulo es la capa de empaquetado y distribucion por encima de los componentes individuales:

| Componente | Modulo donde se aprende | Como encaja en un plugin |
|------------|------------------------|--------------------------|
| Skills | [M09](../modulo-09-agentes-skills-teams/README.md) | Se incluyen en `skills/` del plugin |
| Hooks | [M08](../modulo-08-hooks/README.md) | Se incluyen en `hooks/` del plugin |
| Subagentes | [M09](../modulo-09-agentes-skills-teams/README.md) | Se incluyen en `agents/` del plugin |
| MCP servers | [M07](../modulo-07-mcp/README.md) | Se descubren automaticamente en la estructura del plugin |

---

## Navegacion

| Anterior | Siguiente |
|----------|-----------|
| [Modulo 14: Claude Agent SDK](../modulo-14-agent-sdk/README.md) | [Modulo 16: Proyecto Final](../modulo-16-proyecto-final/enunciado/README.md) |
