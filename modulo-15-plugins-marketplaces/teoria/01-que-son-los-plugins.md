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

El manifest contiene cuatro campos de identidad obligatorios (`name`, `description`, `version`, `author`) y, opcionalmente, la clave `defaultEnabled` (v2.1.154, ver [03-crear-plugin-propio.md](03-crear-plugin-propio.md)) para controlar si el plugin se activa automáticamente al instalarse. Los componentes del plugin (skills, hooks, agentes, servidores MCP) se descubren automáticamente por la estructura de directorios; no se declaran en el manifest.

---

## Ámbitos de Instalación

Los plugins se instalan a nivel de usuario por defecto. Para plugins de proyecto, se incluyen como parte del repositorio (commiteando la carpeta del plugin).

| Ámbito | Descripción |
|--------|-------------|
| Usuario | Instalado con `claude plugin install`. Disponible para tu usuario en todos los proyectos |
| Proyecto | El plugin reside dentro del repositorio. Todos los miembros del equipo lo usan al clonar |
| Auto-carga desde `.claude/skills` | El plugin vive en `.claude/skills/` del repositorio y se carga automáticamente al iniciar sesión, sin marketplace ni instalación explícita (v2.1.157) |
| Managed (enterprise) | Gestionado por el administrador enterprise. Los usuarios no pueden desinstalarlo |

**Para plugins de usuario**, usa `claude plugin install <nombre>@<marketplace>`. Útil para plugins de productividad personal.

**Para plugins de proyecto**, incluye la carpeta del plugin en el repositorio y commitéala. Todos los que clonen el repo tendrán el plugin disponible.

**El ámbito managed** solo es gestionable por administradores enterprise. Los usuarios no pueden instalar ni desinstalar plugins managed; solo pueden usarlos.

---

## Carga Automática desde `.claude/skills` (v2.1.157)

Hasta v2.1.156, distribuir un plugin de proyecto requería registrarlo en un marketplace (aunque fuera privado) o cargarlo explícitamente con `--plugin-dir`. Desde v2.1.157, Claude Code **carga automáticamente** cualquier plugin bien formado que encuentre en el directorio `.claude/skills/` del proyecto al iniciar una sesión nueva: sin marketplace, sin flag `--plugin-dir`, sin instalación manual.

```
mi-proyecto/
├── .claude/
│   └── skills/
│       └── revision-seguridad/
│           └── SKILL.md      # Se detecta y carga automáticamente al iniciar sesión
├── src/
└── README.md
```

Basta con colocar una carpeta con un `SKILL.md` dentro de `.claude/skills/`, iniciar una sesión nueva, y Claude lo detecta sin pasos adicionales. Esto simplifica de forma significativa la distribución de capacidades específicas de proyecto: el propio repositorio es la fuente de verdad, igual que ocurre con `CLAUDE.md` o `.claude/settings.json`, y el componente queda versionado y reproducible sin fricción de publicación.

**Búsqueda hacia arriba en el árbol de directorios**: si inicias Claude Code desde un subdirectorio del proyecto, la búsqueda de `.claude/skills/` sube por los directorios padre hasta encontrar la raíz del repositorio. Esto garantiza que los skills definidos a nivel de proyecto se detectan independientemente de desde qué subcarpeta se lance la sesión.

> **Nota**: Esta carga automática es distinta de instalar un plugin con `claude plugin install`, que sigue siendo la vía recomendada para plugins reutilizables entre proyectos distintos o publicados en un marketplace. La auto-carga desde `.claude/skills` está pensada específicamente para capacidades acopladas a un proyecto concreto.

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

### Crear el esqueleto con `claude plugin init` (v2.1.157)

Antes de escribir la estructura de un plugin a mano, `claude plugin init <nombre>` genera el esqueleto inicial directamente en `.claude/skills/`, listo para que la auto-carga descrita arriba lo detecte:

```bash
# Crea el esqueleto de un plugin nuevo en .claude/skills/<nombre>
claude plugin init deploy-safe

# Scaffolding selectivo de componentes concretos
claude plugin init deploy-safe --with skills,hooks
```

El flag `--with` acepta una lista separada por comas entre `skills`, `agents`, `hooks` y `mcp`, y genera solo los directorios y ficheros de plantilla correspondientes a esos componentes. Sin `--with`, el comando crea la estructura mínima (`.claude-plugin/plugin.json` más un directorio `skills/` de ejemplo).

### Instalar

```bash
# Desde el marketplace oficial de Anthropic
claude plugin install deploy-safe@claude-plugins-official

# Desde un marketplace de terceros
claude plugin install deploy-safe@mi-org-marketplace

# Para desarrollo local (cargar plugin sin instalar)
claude --plugin-dir ./mi-plugin

# --plugin-dir también acepta un archivo .zip directamente (v2.1.128)
claude --plugin-dir ./plugins/mi-plugin-1.4.0.zip

# Descargar y cargar un plugin .zip desde una URL, solo para la sesión actual (v2.1.129)
claude --plugin-url https://artefactos.empresa.com/plugins/deploy-safe-1.4.0.zip
```

> **Nota:** No existen los flags `--scope user` ni `--scope project`. Los plugins se instalan a nivel de usuario por defecto. Para plugins de proyecto, se incluyen como parte del repositorio.

`--plugin-url` es especialmente útil para probar un plugin antes de publicarlo en un marketplace, o para distribuir plugins internos directamente desde un artifact store sin pasar por Git. La carga es válida solo para la sesión en curso: para persistirla, instala el plugin formalmente o cópialo a `.claude/skills/`.

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

# Ver el inventario completo de componentes de un plugin (v2.1.139)
claude plugin details deploy-safe

# Eliminar dependencias auto-instaladas que ya no son necesarias (v2.1.121)
claude plugin prune

# Desinstalar
claude plugin remove deploy-safe
```

La interfaz interactiva `/plugin` ofrece pestañas para navegar: **Discover** (explorar plugins disponibles), **Installed** (ver los instalados), **Marketplaces** (gestionar fuentes) y **Errors** (diagnosticar problemas).

#### `claude plugin details`: inventario completo de un plugin (v2.1.139)

Antes de instalar (o para auditar un plugin ya instalado), `claude plugin details <nombre>` muestra el inventario completo de componentes que trae el plugin: skills, subagentes, hooks y servidores MCP, con una breve descripción de cada uno.

```bash
claude plugin details deploy-safe@claude-plugins-official
```

```text
deploy-safe@claude-plugins-official (v1.2.0)
Flujo de deploy seguro con validaciones pre-deploy y skill de rollback

Skills:
  /deploy-safe:deploy       Despliega el entorno actual tras validar tests y config
  /deploy-safe:rollback     Revierte al último deploy conocido como estable

Hooks:
  PreToolUse (Bash)         Bloquea comandos de deploy si los tests fallan

MCP servers:
  (ninguno)
```

Este comando es la vía recomendada para decidir si instalar un plugin sin tener que clonar el repositorio y leer manualmente la estructura de carpetas.

#### `claude plugin prune`: limpiar dependencias huérfanas

Al instalar plugins, Claude Code puede auto-instalar dependencias que el plugin requiere. Si posteriormente desinstallas el plugin, esas dependencias pueden quedar huérfanas (instaladas pero sin ningún plugin que las use). El comando `claude plugin prune` las elimina automáticamente:

```bash
# Elimina todas las dependencias auto-instaladas sin plugin que las requiera
claude plugin prune
```

El comportamiento es análogo al `npm prune` del ecosistema Node.js: recorre las dependencias instaladas y elimina las que ya no tienen ningún plugin activo que las declare como requisito. Útil tras desinstalar varios plugins o después de una limpieza periódica del entorno.

> **Nota:** Este comando solo elimina dependencias auto-instaladas. Los plugins instalados explícitamente con `claude plugin install` no se ven afectados.

#### Enforcement de dependencias entre plugins (v2.1.143)

Cuando un plugin declara que depende de otro, Claude Code aplica esa dependencia de forma activa en dos comandos:

```bash
# Habilitar un plugin fuerza-habilita también sus dependencias transitivas
claude plugin enable deploy-safe

# Deshabilitar un plugin del que otro depende: la operación se RECHAZA
claude plugin disable notificaciones-slack
# Error: "notificaciones-slack" es una dependencia de "deploy-safe" (habilitado).
# Para deshabilitarlo, ejecuta primero:
#   claude plugin disable deploy-safe
#   claude plugin disable notificaciones-slack
```

| Operación | Comportamiento con dependencias |
|-----------|----------------------------------|
| `claude plugin enable <plugin>` | Habilita automáticamente (fuerza) todas las dependencias transitivas del plugin |
| `claude plugin disable <plugin>` | Se **rechaza** si otro plugin habilitado todavía depende de él; el mensaje de error incluye la cadena de comandos exacta para deshabilitar en el orden correcto |

Este enforcement evita el estado inconsistente de tener un plugin activo cuya dependencia ha sido deshabilitada manualmente, algo que antes de v2.1.143 podía provocar fallos silenciosos en tiempo de ejecución.

---

## Errores Comunes

**Confundir la instalación de usuario con plugins de proyecto.** Un plugin instalado con `claude plugin install` es de usuario y no aparece en el repositorio. Si quieres que tu equipo use el mismo plugin sin instalar manualmente, incluye la carpeta del plugin en el repositorio y commitéala.

**Usar comandos inexistentes.** No existen `/plugin install`, `/plugin search`, `/plugin info` ni `/plugin configure` como comandos individuales. El CLI oficial usa `claude plugin install <nombre>@<marketplace>`, `claude plugin list` y `claude plugin remove <nombre>`. Para explorar el marketplace, usa `/plugin` (interfaz interactiva con pestañas).

**Asumir que los hooks del plugin tienen permisos ilimitados.** Los hooks de un plugin siguen las mismas restricciones de permisos que cualquier hook. Si el hook necesita ejecutar comandos que no están en la lista permitida, Claude Code pedirá confirmación o bloqueará la ejecución.

**Esperar que un plugin en `.claude/skills` se recargue en caliente.** La auto-carga desde `.claude/skills` (v2.1.157) se evalúa al **iniciar sesión**. Si añades o modificas un `SKILL.md` con una sesión ya en marcha, necesitas iniciar una sesión nueva para que Claude Code lo detecte.

**Deshabilitar un plugin sin comprobar sus dependientes.** Desde v2.1.143, `claude plugin disable` rechaza la operación si otro plugin habilitado depende del que intentas deshabilitar. Usa el mensaje de error para deshabilitar en el orden correcto en lugar de forzar la operación.

---

## Resumen

- Un plugin es un bundle que agrupa skills, hooks, subagentes y servidores MCP en una unidad distribuible con manifest
- La diferencia con los componentes individuales es que el plugin los empaqueta y versiona juntos
- La estructura mínima es `.claude-plugin/plugin.json` (manifest con 4 campos obligatorios: name, description, version, author, más el campo opcional `defaultEnabled`) más al menos un componente
- Los componentes se descubren automáticamente por la estructura de directorios; no se declaran en el manifest
- Los plugins se instalan a nivel de usuario con `claude plugin install`. Para plugins de proyecto, se incluyen en el repositorio o se colocan en `.claude/skills/` para carga automática (v2.1.157)
- `claude plugin init <nombre>` (v2.1.157) genera el esqueleto de un plugin nuevo directamente en `.claude/skills/`
- El ciclo de vida es: instalar → usar → actualizar → desinstalar
- `claude plugin details <nombre>` (v2.1.139) muestra el inventario completo de componentes de un plugin antes de instalarlo
- `claude plugin prune` elimina dependencias auto-instaladas que ya no tienen ningún plugin que las requiera; desde v2.1.143, `claude plugin disable` rechaza deshabilitar un plugin del que otro depende
- Para desarrollo local se usa `claude --plugin-dir ./ruta` (también acepta `.zip` desde v2.1.128) o `claude --plugin-url <url>` para cargar un `.zip` remoto solo en la sesión actual (v2.1.129)
