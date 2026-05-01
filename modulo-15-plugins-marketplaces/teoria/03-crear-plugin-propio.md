# Crear un Plugin Propio

Empaquetar tus propias capacidades en un plugin te permite distribuirlas de forma reproducible, versionarlas con semántica clara y compartirlas con el equipo o la comunidad sin que nadie tenga que configurar los componentes manualmente. Este capítulo cubre el proceso completo: desde la estructura de carpetas hasta la publicación en el marketplace.

---

## Conceptos Clave

### Cuándo crear un plugin propio

Crea un plugin cuando tengas un conjunto de capacidades que:

- Se usan juntas de forma consistente en múltiples proyectos
- Requieren configuración específica que no quieres repetir en cada proyecto
- Quieres compartir con tu equipo o con la comunidad de forma reproducible
- Son lo suficientemente complejas como para merecer versionado propio

Si solo necesitas una capacidad en un proyecto concreto, un skill o hook en `.claude/` es suficiente.

---

## Estructura de un Plugin Personalizado

```
mi-plugin/
├── .claude-plugin/
│   └── plugin.json      # Manifest (obligatorio)
├── skills/
│   └── deploy/
│       └── SKILL.md     # Skill invocable por nombre
├── agents/
│   └── revisor.md       # Subagente especializado
├── hooks/
│   └── hooks.json       # Configuración de hooks del plugin
├── commands/             # Comandos personalizados (opcional)
├── themes/
│   └── mi-tema.json     # Tema de interfaz (opcional, v2.1.118+)
└── README.md            # Documentación para usuarios del plugin
```

Cada subdirectorio es opcional; incluye solo los componentes que necesitas. Los componentes se descubren automáticamente por la estructura de directorios.

---

## El Manifest `.claude-plugin/plugin.json`

El manifest define únicamente la identidad del plugin. Reside dentro del directorio `.claude-plugin/` y tiene un formato muy simple:

```json
{
  "name": "deploy-safe",
  "description": "Flujo de deploy seguro con validaciones, rollback y notificación a Slack",
  "version": "1.0.0",
  "author": "equipo-plataforma@empresa.com"
}
```

El manifest solo contiene estos cuatro campos: `name`, `description`, `version` y `author`.

Los componentes del plugin (skills, hooks, agentes, servidores MCP) **no se declaran en el manifest**. Se descubren automáticamente por la estructura de directorios:

- `skills/` - Cada subcarpeta con un `SKILL.md` se registra como skill
- `agents/` - Los archivos `.md` se registran como subagentes
- `hooks/` - El archivo `hooks.json` define los hooks del plugin
- `commands/` - Comandos personalizados del plugin

> **Importante:** No uses campos como `dependencies`, `configuration`, `components`, `engines` o `license` en el manifest. El formato oficial solo reconoce los cuatro campos indicados.

---

## Monitors en Plugins (v2.1.105)

Los plugins pueden incluir **monitors**: procesos background que arrancan automáticamente al iniciar sesión o al invocar un skill del plugin. Se declaran con la clave `monitors` en el directorio del plugin.

Los monitors permiten que un plugin observe eventos continuamente (logs, cambios en ficheros, métricas) sin que el usuario tenga que activarlos manualmente. Combinan bien con hooks para reaccionar a eventos del entorno.

```
mi-plugin/
├── .claude-plugin/
│   └── plugin.json
├── monitors/
│   └── log-watcher.sh    # Monitor que arranca al cargar el plugin
├── hooks/
│   └── hooks.json
└── skills/
    └── deploy/
        └── SKILL.md
```

Ejemplo de monitor que observa el log de errores de la aplicación (`monitors/log-watcher.sh`):

```bash
#!/bin/bash
# Monitor: observa el log de errores y emite alertas estructuradas

LOG_FILE="${PLUGIN_LOG_PATH:-/var/log/app/error.log}"

if [ ! -f "$LOG_FILE" ]; then
    echo "Monitor: fichero de log no encontrado en $LOG_FILE. Saliendo." >&2
    exit 0
fi

# tail --follow arranca en background y sigue el fichero indefinidamente
tail --follow=name --retry "$LOG_FILE" | while read -r LINE; do
    if echo "$LINE" | grep -qiE "(error|exception|fatal)"; then
        # Emite un evento estructurado que los hooks del plugin pueden procesar
        echo "{\"event\": \"log_error\", \"line\": $(echo "$LINE" | python3 -c "import sys, json; print(json.dumps(sys.stdin.read().strip()))")}"
    fi
done
```

Puntos clave sobre los monitors:

- Arrancan automáticamente al iniciar sesión con el plugin cargado o al invocar un skill del plugin.
- Se declaran en el subdirectorio `monitors/` del plugin; Claude Code los descubre por estructura de directorios.
- Deben ser procesos robustos: manejar correctamente la ausencia de recursos (ficheros, servicios) sin bloquearse.
- Combinan bien con hooks `PostToolUse` o `Notification` para reaccionar a los eventos que detectan.
- Los ejecutables en `monitors/` deben tener permisos de ejecución (`chmod +x`) igual que los hooks.

> **Nota:** Esta funcionalidad requiere Claude Code v2.1.105 o superior. En versiones anteriores, el directorio `monitors/` se ignora silenciosamente.

---

## Empaquetar Skills Existentes

Si ya tienes skills en `.claude/skills/` de tu proyecto, puedes empaquetarlos en un plugin. Crea una subcarpeta dentro de `skills/` con el nombre del skill y coloca el archivo `SKILL.md` dentro. El plugin descubrirá automáticamente todos los skills por la estructura de directorios; no es necesario declararlos en el manifest.

Los campos disponibles en el frontmatter YAML de un `SKILL.md` son:

- `name` — Nombre del skill. Desde v2.1.94, cuando el plugin declara skills con `"skills": ["./"]`, este campo se usa como **nombre de invocación estable**: los usuarios pueden llamar al skill con este nombre independientemente de la ruta del fichero.
- `description` — Descripción del propósito del skill, visible al listar skills disponibles.
- `keep-coding-instructions` — Instrucciones de estilo de output que se mantienen activas mientras el plugin está cargado. Útil para plugins que necesitan que Claude siga un formato específico de respuesta (por ejemplo, reportes estructurados, salida JSON, etc.). Disponible desde v2.1.94.

Ejemplo de skill de deploy (`skills/deploy/SKILL.md`):

```markdown
---
name: deploy
description: Despliega la versión actual a un entorno específico tras validar tests y configuración
keep-coding-instructions: |
  Reporta cada paso con formato "[ ok ]" o "[error]" seguido del nombre del paso.
  Usa bloques de código para mostrar comandos ejecutados y su salida.
---

# Skill: Deploy Seguro

Antes de cualquier deploy:
1. Verifica que los tests de la suite principal pasan (`npm test` o equivalente)
2. Confirma que no hay cambios sin commitear en git
3. Valida que las variables de entorno requeridas están definidas
4. Construye el artefacto de despliegue
5. Despliega al entorno configurado
6. Verifica el health check post-deploy
7. Si falla el health check, ejecuta el rollback automático

Reporta cada paso con su resultado (ok/error) antes de continuar al siguiente.
```

El skill anterior es descubierto automáticamente por el plugin al detectar la estructura `skills/deploy/SKILL.md`.

---

## Empaquetar Hooks con el Plugin

Los hooks del plugin se definen en el directorio `hooks/`. Se configuran en un archivo `hooks.json` dentro de ese directorio (no en el manifest `plugin.json`).

Ejemplo de hook de validación pre-deploy (`hooks/pre-deploy.sh`):

```bash
#!/bin/bash
# Hook PreToolUse: bloquea comandos de deploy si los tests fallan

# Leer el comando que Claude intenta ejecutar desde stdin
TOOL_INPUT=$(cat)
COMMAND=$(echo "$TOOL_INPUT" | python3 -c "import sys, json; print(json.load(sys.stdin).get('command', ''))")

# Solo actuar en comandos que parecen deploys
if echo "$COMMAND" | grep -qE "(kubectl apply|docker push|helm upgrade|deploy\.sh)"; then
    echo "Pre-deploy check: ejecutando tests..." >&2

    # Detectar el gestor de tests disponible
    if [ -f "package.json" ]; then
        npm test --silent
        EXIT_CODE=$?
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        python -m pytest -q
        EXIT_CODE=$?
    else
        echo "No se detectó suite de tests. Continuando sin validación." >&2
        EXIT_CODE=0
    fi

    if [ $EXIT_CODE -ne 0 ]; then
        # Salida con código 2 bloquea el comando y muestra el mensaje a Claude
        echo '{"decision": "block", "reason": "Los tests no pasan. Corrige los errores antes de hacer deploy."}'
        exit 2
    fi

    echo "Tests OK. Continuando con el deploy." >&2
fi

# Salida con código 0: el comando se ejecuta normalmente
exit 0
```

Ejemplo de hook de notificación post-deploy (`hooks/post-deploy.sh`):

```bash
#!/bin/bash
# Hook PostToolUse: notifica a Slack cuando un deploy se completa

# PLUGIN_SLACK_WEBHOOK viene de la configuración del plugin
if [ -z "$PLUGIN_SLACK_WEBHOOK" ]; then
    exit 0
fi

TOOL_OUTPUT=$(cat)
COMMAND=$(echo "$TOOL_OUTPUT" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('tool_input', {}).get('command', ''))" 2>/dev/null)

# Solo notificar en comandos de deploy
if echo "$COMMAND" | grep -qE "(kubectl apply|helm upgrade|deploy\.sh)"; then
    ENTORNO="${PLUGIN_ENVIRONMENT:-staging}"
    curl -s -X POST "$PLUGIN_SLACK_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"text\": \"Deploy completado en *${ENTORNO}* por ${USER}. Comando: \`${COMMAND}\`\"}" \
        > /dev/null
fi

exit 0
```

---

## Incluir un Servidor MCP en el Plugin

Si tu plugin requiere un servidor MCP, inclúyelo dentro de la estructura de directorios del plugin. Claude Code descubrirá automáticamente los servidores MCP disponibles al cargar el plugin.

Recuerda que el manifest `.claude-plugin/plugin.json` solo contiene los cuatro campos de identidad (`name`, `description`, `version`, `author`). Los servidores MCP no se declaran en el manifest; se descubren por la estructura de directorios.

---

## Temas Personalizados en Plugins (v2.1.118)

Los plugins pueden distribuir **temas de interfaz** junto con sus otros componentes. Un tema define la paleta de colores de la interfaz de Claude Code y se activa con el comando `/theme`.

### Estructura

Para incluir un tema en un plugin, añade un directorio `themes/` en la raíz del plugin con uno o más ficheros JSON, uno por tema:

```
mi-plugin/
├── .claude-plugin/
│   └── plugin.json
├── themes/
│   └── mi-tema-oscuro.json   # Definición del tema
├── skills/
│   └── ...
└── README.md
```

### Formato del fichero de tema

Cada fichero JSON dentro de `themes/` define los colores de los elementos de la interfaz. Claude Code instala automáticamente los temas del plugin en `~/.claude/themes/` al cargar el plugin.

```json
{
  "name": "mi-tema-oscuro",
  "colors": {
    "background": "#1a1b26",
    "foreground": "#c0caf5",
    "primary": "#7aa2f7",
    "secondary": "#bb9af7",
    "success": "#9ece6a",
    "warning": "#e0af68",
    "error": "#f7768e",
    "border": "#3b4261"
  }
}
```

El campo `name` dentro del JSON debe coincidir con el nombre del fichero (sin extensión). Este nombre es el que el usuario verá al ejecutar `/theme`.

### Activar el tema

Una vez instalado el plugin, el usuario activa el tema desde el comando interactivo `/theme`:

```bash
# Dentro de una sesión de Claude Code
/theme
```

El comando `/theme` lista todos los temas disponibles (incluidos los distribuidos por plugins instalados) y permite seleccionar el activo. El tema queda guardado como preferencia del usuario.

### Cuándo distribuir un tema con un plugin

Los temas son especialmente útiles en plugins de equipo o enterprise que quieren unificar la experiencia visual entre todos los miembros. Por ejemplo, un plugin de deploy puede incluir un tema con colores que refuercen el contexto del entorno (colores más cálidos para producción, más fríos para desarrollo).

> **Nota:** Esta funcionalidad requiere Claude Code v2.1.118 o superior. En versiones anteriores, el directorio `themes/` se ignora silenciosamente.

---

## Ejecutables en `bin/` (v2.1.91)

Los plugins pueden distribuir **ejecutables** bajo un directorio `bin/` en la raíz del plugin. Los ejecutables incluidos en `bin/` se registran automáticamente y pueden invocarse como comandos bare desde la herramienta Bash, sin necesidad de especificar la ruta completa.

```
mi-plugin/
├── .claude-plugin/
│   └── plugin.json
├── bin/
│   ├── mi-linter         # Ejecutable personalizado
│   └── mi-formatter      # Otro ejecutable
├── skills/
│   └── ...
└── README.md
```

Con esta estructura, Claude Code puede ejecutar `mi-linter` directamente en Bash como si fuera un comando del sistema:

```bash
mi-linter --check src/
```

**Casos de uso:**

- Herramientas de linting o formateo personalizadas del equipo
- Scripts de deploy empaquetados con el plugin
- CLIs internas que complementan las capacidades del plugin

> **Importante:** Los ejecutables deben tener permisos de ejecución (`chmod +x`). Verifica los permisos antes de publicar el plugin.

---

## Probar el Plugin Localmente

Antes de publicar, carga el plugin desde la ruta local para verificar que funciona correctamente:

```bash
# Cargar el plugin local para desarrollo/testing
claude --plugin-dir ./ruta/a/mi-plugin
```

Este flag inicia Claude Code con el plugin cargado desde la ruta especificada, sin necesidad de instalarlo formalmente.

Lista los plugins cargados para confirmar que se registró correctamente:

```bash
claude plugin list
```

Verifica que los skills son invocables:

```bash
# Dentro de una sesión de Claude Code
/deploy-safe:deploy
```

Verifica que los hooks se activan en el evento correcto ejecutando el comando que debería disparar el hook y observando los mensajes de stderr del hook en el log de Claude Code.

Para desinstalar un plugin instalado:

```bash
claude plugin remove deploy-safe
```

---

## Publicar en el Marketplace

Cuando el plugin está listo para compartirse:

1. Crea un repositorio público en GitHub con la estructura del plugin en la raíz (incluyendo `.claude-plugin/plugin.json`)
2. Publica el plugin a través del **formulario web en platform.claude.com**

> **Importante:** No existe un comando CLI `/plugin publish` para publicar plugins. La publicación se realiza exclusivamente a través del formulario web en la plataforma de Anthropic (platform.claude.com).

3. Anthropic valida el manifest, verifica la estructura de carpetas y registra el plugin con el nombre declarado en `.claude-plugin/plugin.json`

Una vez publicado, los usuarios pueden instalarlo con:

```bash
claude plugin install deploy-safe@claude-plugins-official
```

---

## Versionado y Actualizaciones

El versionado sigue semántica SemVer (`MAYOR.MENOR.PARCHE`):

| Tipo de cambio | Versión |
|----------------|---------|
| Nuevo skill o hook añadido | MENOR |
| Nuevo tema distribuido con el plugin | MENOR |
| Cambio incompatible en la interfaz de un skill | MAYOR |
| Corrección de un hook que fallaba | PARCHE |
| Cambio en el comportamiento de un hook (no es bug) | MENOR o MAYOR |

### `claude plugin tag`: crear tags de release (v2.1.118)

El comando `claude plugin tag` crea un git tag de release para el plugin con validación de versión semántica integrada. Valida que la versión sigue el formato SemVer correcto antes de crear el tag, evitando publicar versiones con formatos inválidos:

```bash
# Crear un tag de release para la versión 1.2.0
claude plugin tag v1.2.0
```

El comando realiza estas operaciones:

1. Valida que `v1.2.0` es una versión semántica válida (formato `vMAYOR.MENOR.PARCHE`)
2. Verifica que `version` en `.claude-plugin/plugin.json` coincide con la versión indicada
3. Crea el git tag `v1.2.0` en el repositorio
4. Muestra confirmación con los pasos siguientes para publicar la versión

Ejemplo de flujo de publicación de una nueva versión:

```bash
# 1. Actualizar la versión en el manifest
# Editar .claude-plugin/plugin.json: "version": "1.2.0"

# 2. Commitear los cambios
git add .claude-plugin/plugin.json
git commit -m "chore: bump version to 1.2.0"

# 3. Crear el tag con validación de versión semántica
claude plugin tag v1.2.0

# 4. Subir el tag al repositorio remoto
git push origin v1.2.0

# 5. Publicar la nueva versión a través del formulario web en platform.claude.com
```

> **Nota:** Este comando requiere Claude Code v2.1.118 o superior. En versiones anteriores, usa `git tag v1.2.0` directamente, sin la validación de versión semántica.

Para publicar la nueva versión una vez creado el tag, accede al formulario web en platform.claude.com.

Los usuarios pueden reinstalar para obtener la última versión:

```bash
claude plugin install deploy-safe@claude-plugins-official
```

---

## Errores Comunes

**No marcar los scripts de hooks como ejecutables.** Si `hooks/pre-deploy.sh` no tiene permisos de ejecución (`chmod +x`), el hook fallará silenciosamente en algunos sistemas. Verifica los permisos antes de publicar.

**Hardcodear URLs o credenciales en los archivos del plugin.** Usa variables de entorno para valores que varían entre instalaciones.

**No probar el plugin en un proyecto limpio.** El plugin puede funcionar en el proyecto donde lo desarrollaste pero fallar en otros si depende de archivos o variables de entorno que no están presentes universalmente. Prueba siempre en un repositorio diferente al de desarrollo.

**Publicar sin documentación.** Un `README.md` claro que explique qué hace el plugin, qué configuración requiere y cómo se usa multiplica la adopción. Incluye al menos un ejemplo de uso.

---

## Resumen

- La estructura mínima de un plugin es `.claude-plugin/plugin.json` (con 4 campos: name, description, version, author) más al menos un subdirectorio con un componente
- El manifest solo declara la identidad del plugin; los componentes se descubren automáticamente por estructura de directorios
- Los skills se colocan en `skills/<nombre-skill>/SKILL.md`, los hooks en `hooks/hooks.json`, los agentes en `agents/`
- Los servidores MCP se descubren automáticamente, no se declaran en el manifest
- Los plugins pueden distribuir temas de interfaz en el directorio `themes/` (ficheros JSON); el usuario los activa con `/theme` (v2.1.118+)
- `claude plugin tag v1.2.0` crea un git tag de release con validación de versión semántica integrada (v2.1.118+)
- El ciclo de desarrollo local es: crear estructura -> probar con `claude --plugin-dir ./mi-plugin` -> iterar
- La publicación se hace a través del formulario web en platform.claude.com (no existe comando CLI para publicar)
