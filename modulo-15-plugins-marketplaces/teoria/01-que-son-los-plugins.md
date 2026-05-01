# Qué son los Plugins de Claude Code

Un **plugin** es un bundle que empaqueta una o más capacidades de Claude Code — skills, hooks, subagentes y/o servidores MCP — en una unidad distribuible con identidad propia. Comprender cómo funcionan los plugins, su estructura interna y los ámbitos de instalación disponibles es el punto de partida para aprovechar el ecosistema de extensiones de Claude Code.

---

## Conceptos Clave

### Definición

La diferencia fundamental con los componentes individuales es que un plugin:

- Los **agrupa** bajo un manifest con nombre, versión y autor
- Los **distribuye** como una unidad indivisible: instalar el plugin instala todos sus componentes
- Los **descubre automáticamente** por la estructura de directorios: skills, hooks, agentes y servidores MCP no se declaran en el manifest

Dicho de otro modo: un skill resuelve una tarea, un hook intercepta un evento, un subagente delega trabajo. Un plugin organiza todos esos elementos en un paquete listo para usar sin configuración manual.

### Diferencia entre un skill y un plugin

Un skill (`SKILL.md`) define una capacidad invocable por nombre. Un plugin puede contener ese skill, más el hook que lo activa antes de cada commit, más el subagente que lo orquesta, todo empaquetado junto con instrucciones de configuración e integración. El plugin es la unidad de distribución; el skill es uno de sus posibles contenidos.

---

## Estructura de un Plugin

Un plugin reside en una carpeta con la siguiente estructura:

```
mi-plugin/
├── .claude-plugin/
│   └── plugin.json      # Manifest obligatorio
├── skills/
│   └── mi-skill/
│       └── SKILL.md     # Uno o más skills (descubiertos automáticamente)
├── agents/
│   └── revisor.md       # Uno o más subagentes (.md con frontmatter)
├── hooks/
│   └── hooks.json       # Configuración de hooks del plugin
├── commands/             # Comandos personalizados (opcional)
└── README.md            # Documentación del plugin (recomendado)
```

No todos los directorios son obligatorios. Un plugin mínimo puede contener solo `.claude-plugin/plugin.json` y un subdirectorio con un componente. Los componentes (skills, agents, hooks, MCP servers) se descubren automáticamente por la estructura de directorios, no se declaran en el manifest.

### El manifest `.claude-plugin/plugin.json`

El manifest es el único fichero obligatorio. Reside dentro del directorio `.claude-plugin/` y define únicamente la identidad del plugin con un formato muy simple:

```json
{
  "name": "deploy-safe",
  "description": "Flujo de deploy seguro con validaciones pre-deploy y skill de rollback",
  "version": "1.2.0",
  "author": "equipo-plataforma@empresa.com"
}
```

El manifest solo contiene estos cuatro campos: `name`, `description`, `version` y `author`. Los componentes del plugin (skills, hooks, agentes, servidores MCP) se descubren automáticamente por la estructura de directorios; no se declaran en el manifest.

---

## Ámbitos de Instalación

Los plugins se instalan a nivel de usuario por defecto. Para plugins de proyecto, se incluyen como parte del repositorio (commiteando la carpeta del plugin).

| Ámbito | Descripción |
|--------|-------------|
| Usuario | Instalado con `claude plugin install`. Disponible para tu usuario en todos los proyectos |
| Proyecto | El plugin reside dentro del repositorio. Todos los miembros del equipo lo usan al clonar |
| Managed (enterprise) | Gestionado por el administrador enterprise. Los usuarios no pueden desinstalarlo |

**Para plugins de usuario**, usa `claude plugin install <nombre>@<marketplace>`. Útil para plugins de productividad personal.

**Para plugins de proyecto**, incluye la carpeta del plugin en el repositorio y commitéala. Todos los que clonen el repo tendrán el plugin disponible.

**El ámbito managed** solo es gestionable por administradores enterprise. Los usuarios no pueden instalar ni desinstalar plugins managed; solo pueden usarlos.

---

## Ciclo de Vida de un Plugin

```
instalar  -->  usar  -->  actualizar  -->  desinstalar
    |             |             |                |
claude         Invocar       claude plugin    claude plugin
plugin         skills con    install (nueva   remove <nombre>
install        /plugin-name  versión)
<nombre>@      :skill-name,
<marketplace>  hooks se
               activan
               automáticamente
```

### Instalar

```bash
# Desde el marketplace oficial de Anthropic
claude plugin install deploy-safe@claude-plugins-official

# Desde un marketplace de terceros
claude plugin install deploy-safe@mi-org-marketplace

# Para desarrollo local (cargar plugin sin instalar)
claude --plugin-dir ./mi-plugin
```

> **Nota:** No existen los flags `--scope user` ni `--scope project`. Los plugins se instalan a nivel de usuario por defecto. Para plugins de proyecto, se incluyen como parte del repositorio.

### Usar

Una vez instalado, los componentes del plugin están disponibles de forma inmediata:

- Los **skills** se pueden invocar por nombre: `/deploy-safe:deploy`
- Los **hooks** se activan automáticamente según el evento configurado
- Los **subagentes** aparecen disponibles en el contexto de la sesión

### Variables de Entorno para Plugins

Los plugins tienen acceso a variables de entorno especiales que Claude Code inyecta automáticamente:

| Variable | Descripción |
|----------|-------------|
| `${CLAUDE_PLUGIN_DATA}` | Directorio persistente para almacenar estado del plugin entre sesiones. Cada plugin recibe su propio directorio aislado (v2.1.78+) |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Directorio(s) adicionales donde buscar plugins locales. Soporta múltiples directorios separados por `:` en Linux/macOS o `;` en Windows (v2.1.79+) |

La variable `${CLAUDE_PLUGIN_DATA}` es útil para plugins que necesitan mantener configuración, caché o estado entre ejecuciones. Se puede usar dentro de scripts de hooks o skills del plugin:

```bash
# Ejemplo en un hook del plugin: guardar timestamp del último deploy
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "${CLAUDE_PLUGIN_DATA}/last-deploy.txt"
```

### Gestionar plugins

```bash
# Ver plugins instalados
claude plugin list

# Explorar marketplace y plugins (interfaz interactiva con pestañas)
/plugin

# Eliminar dependencias auto-instaladas que ya no son necesarias (v2.1.121)
claude plugin prune

# Desinstalar
claude plugin remove deploy-safe
```

La interfaz interactiva `/plugin` ofrece pestañas para navegar: **Discover** (explorar plugins disponibles), **Installed** (ver los instalados), **Marketplaces** (gestionar fuentes) y **Errors** (diagnosticar problemas).

#### `claude plugin prune`: limpiar dependencias huérfanas

Al instalar plugins, Claude Code puede auto-instalar dependencias que el plugin requiere. Si posteriormente desinstallas el plugin, esas dependencias pueden quedar huérfanas (instaladas pero sin ningún plugin que las use). El comando `claude plugin prune` las elimina automáticamente:

```bash
# Elimina todas las dependencias auto-instaladas sin plugin que las requiera
claude plugin prune
```

El comportamiento es análogo al `npm prune` del ecosistema Node.js: recorre las dependencias instaladas y elimina las que ya no tienen ningún plugin activo que las declare como requisito. Útil tras desinstalar varios plugins o después de una limpieza periódica del entorno.

> **Nota:** Este comando solo elimina dependencias auto-instaladas. Los plugins instalados explícitamente con `claude plugin install` no se ven afectados.

---

## Errores Comunes

**Confundir la instalación de usuario con plugins de proyecto.** Un plugin instalado con `claude plugin install` es de usuario y no aparece en el repositorio. Si quieres que tu equipo use el mismo plugin sin instalar manualmente, incluye la carpeta del plugin en el repositorio y commitéala.

**Usar comandos inexistentes.** No existen `/plugin install`, `/plugin search`, `/plugin info` ni `/plugin configure` como comandos individuales. El CLI oficial usa `claude plugin install <nombre>@<marketplace>`, `claude plugin list` y `claude plugin remove <nombre>`. Para explorar el marketplace, usa `/plugin` (interfaz interactiva con pestañas).

**Asumir que los hooks del plugin tienen permisos ilimitados.** Los hooks de un plugin siguen las mismas restricciones de permisos que cualquier hook. Si el hook necesita ejecutar comandos que no están en la lista permitida, Claude Code pedirá confirmación o bloqueará la ejecución.

---

## Resumen

- Un plugin es un bundle que agrupa skills, hooks, subagentes y servidores MCP en una unidad distribuible con manifest
- La diferencia con los componentes individuales es que el plugin los empaqueta y versiona juntos
- La estructura mínima es `.claude-plugin/plugin.json` (manifest con 4 campos: name, description, version, author) más al menos un componente
- Los componentes se descubren automáticamente por la estructura de directorios; no se declaran en el manifest
- Los plugins se instalan a nivel de usuario con `claude plugin install`. Para plugins de proyecto, se incluyen en el repositorio
- El ciclo de vida es: instalar → usar → actualizar → desinstalar
- `claude plugin prune` elimina dependencias auto-instaladas que ya no tienen ningún plugin que las requiera
- Para desarrollo local se usa `claude --plugin-dir ./ruta`
