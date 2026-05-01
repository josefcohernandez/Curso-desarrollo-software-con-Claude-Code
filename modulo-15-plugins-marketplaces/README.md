# Módulo 15: Plugins y Marketplaces

## Empaquetar, distribuir y gestionar capacidades en Claude Code

> **Tiempo estimado:** 1,5 horas
> **Nivel:** Experto (Bloque 4)
> **Prerrequisitos:** Módulos 07 (MCP), 08 (Hooks) y 09 (Subagentes y Skills)

> [!WARNING]
> **Estado del ecosistema de plugins:** El sistema de plugins de Claude Code está en una fase temprana de desarrollo. Algunas funcionalidades descritas en este módulo, como el marketplace público, el comando `claude plugin install` o la estructura exacta de `.claude-plugin/plugin.json`, pueden no estar disponibles en tu versión o funcionar de forma diferente a lo documentado aquí. El flag `--plugin-dir` para cargar plugins locales sí está disponible. Consulta la documentación oficial de tu versión para confirmar la disponibilidad de cada feature.

---

## Objetivos de aprendizaje

Al terminar este módulo serás capaz de:

- Explicar qué es un plugin de Claude Code y cómo se diferencia de un skill, un hook o un servidor MCP individual
- Identificar los plugins y extensiones más comunes del ecosistema (VS Code, JetBrains, GitHub, bases de datos, etc.)
- Crear un plugin propio que empaquete skills, hooks y subagentes en una unidad distribuible
- Explorar el marketplace con el comando `/plugin` y gestionar instalaciones a nivel de proyecto y usuario
- Configurar marketplaces privados y políticas de plugins para entornos enterprise

---

## Prerrequisitos

| Módulo | Por qué es necesario |
|--------|----------------------|
| [M07](../modulo-07-mcp/README.md) | MCP servers: base técnica de muchos plugins de integración |
| [M08](../modulo-08-hooks/README.md) | Hooks del ciclo de vida: componente fundamental de los plugins |
| [M09](../modulo-09-agentes-skills-teams/README.md) | Skills y subagentes: el otro componente principal de un plugin |

---

## Duración estimada

| Sección | Tiempo |
|---------|--------|
| Teoría (4 ficheros) | 60 min |
| Ejercicios prácticos | 30 min |
| **Total** | **1,5 horas** |

---

## Contenido

### Teoría

| Archivo | Tema | Duración |
|---------|------|----------|
| [01-que-son-los-plugins.md](teoria/01-que-son-los-plugins.md) | Definición, estructura, scopes y ciclo de vida de un plugin | 15 min |
| [02-plugins-integrados.md](teoria/02-plugins-integrados.md) | Ecosistema de plugins: IDE, integraciones de servicios y productividad | 20 min |
| [03-crear-plugin-propio.md](teoria/03-crear-plugin-propio.md) | Manifest, estructura de carpetas, empaquetado y publicación | 15 min |
| [04-marketplaces-y-gestion-enterprise.md](teoria/04-marketplaces-y-gestion-enterprise.md) | Marketplace público, marketplaces privados y políticas enterprise | 10 min |

### Ejercicios prácticos

| Archivo | Tema | Duración |
|---------|------|----------|
| [01-explorar-y-crear-plugins.md](ejercicios/01-explorar-y-crear-plugins.md) | Cinco ejercicios: desde explorar el marketplace hasta publicar un plugin de equipo | 30 min |

---

## Conceptos clave

| Concepto | Descripción |
|----------|-------------|
| Plugin | Bundle que agrupa skills, hooks, subagentes y/o servidores MCP en una unidad distribuible con manifest |
| `.claude-plugin/plugin.json` | Manifest del plugin: nombre, versión, autor y descripción. Los componentes se descubren automáticamente por estructura de directorios |
| `/plugin` | Comando interactivo con pestañas (`Discover`, `Installed`, `Marketplaces`, `Errors`) para explorar y gestionar plugins |
| `claude plugin install` | Comando CLI para instalar plugins: `claude plugin install <nombre>@<marketplace>` |
| `claude plugin prune` | Elimina dependencias auto-instaladas que ya no tienen ningún plugin que las requiera (v2.1.121) |
| `claude plugin tag` | Crea un git tag de release del plugin con validación de versión semántica: `claude plugin tag v1.2.0` (v2.1.118) |
| `claude --plugin-dir` | Flag para cargar un plugin local durante desarrollo o testing |
| `themes/` | Directorio dentro de un plugin para distribuir temas de interfaz JSON; el usuario los activa con `/theme` (v2.1.118) |
| Marketplace privado | Repositorio de plugins de una organización, configurable con `extraKnownMarketplaces` en settings |
| `strictKnownMarketplaces` | Configuración enterprise que limita las instalaciones a marketplaces aprobados |
| `blockedMarketplaces` | Configuración enterprise para bloquear fuentes de plugins específicas |
| Ciclo de vida | Secuencia: instalar → usar → actualizar → desinstalar |

---

## Flujo de trabajo recomendado

```text
1. IDENTIFICAR necesidad
   ¿Qué capacidad falta en tu flujo de trabajo?
        |
        v
2. EXPLORAR el marketplace
   /plugin → navegar pestañas (Discover, Installed) → evaluar permisos y reputación
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

## Relación con otros módulos

Este módulo es la capa de empaquetado y distribución por encima de los componentes individuales:

| Componente | Módulo donde se aprende | Cómo encaja en un plugin |
|------------|--------------------------|--------------------------|
| Skills | [M09](../modulo-09-agentes-skills-teams/README.md) | Se incluyen en `skills/` del plugin |
| Hooks | [M08](../modulo-08-hooks/README.md) | Se incluyen en `hooks/` del plugin |
| Subagentes | [M09](../modulo-09-agentes-skills-teams/README.md) | Se incluyen en `agents/` del plugin |
| MCP servers | [M07](../modulo-07-mcp/README.md) | Se descubren automáticamente en la estructura del plugin |

---

## Navegación

| Anterior | Siguiente |
|----------|-----------|
| [Módulo 14: Claude Agent SDK](../modulo-14-agent-sdk/README.md) | [Módulo 16: Proyecto Final](../modulo-16-proyecto-final/enunciado/README.md) |
