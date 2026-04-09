# Marketplaces y Gestión Enterprise de Plugins

El marketplace público de Claude Code centraliza la distribución de plugins verificados. Para organizaciones enterprise, la plataforma ofrece además la posibilidad de alojar marketplaces privados, distribuir plugins a todo el equipo y aplicar políticas que restringen qué fuentes y qué plugins están permitidos. Este capítulo cubre ambas dimensiones: el uso del marketplace público y la administración en entornos empresariales.

---

## El Marketplace Público

El marketplace público de Claude Code es el repositorio centralizado de plugins verificados por Anthropic y contribuidos por la comunidad. Se accede a él exclusivamente a través del comando interactivo `/plugin`.

### Explorar el marketplace

```bash
# Abrir la interfaz interactiva de plugins (desde una sesión de Claude Code)
/plugin
```

El comando `/plugin` abre una interfaz interactiva con pestañas:

- **Discover**: explorar plugins disponibles, navegar por categorías y ver detalles
- **Installed**: ver los plugins instalados actualmente
- **Marketplaces**: gestionar las fuentes de plugins configuradas
- **Errors**: diagnosticar problemas con plugins instalados

> **Nota:** No existen los comandos `/plugin search`, `/plugin info` ni `/plugin featured` como subcomandos separados. Toda la exploración se realiza navegando las pestañas de la interfaz interactiva `/plugin`.

**Antes de instalar cualquier plugin del marketplace**, revisa especialmente la sección de permisos en la pestaña Discover. Un plugin que solicita acceso a `Bash` sin restricciones tiene capacidad de ejecutar comandos arbitrarios en tu sistema.

### Instalar desde el marketplace

```bash
# Instalación desde el marketplace oficial de Anthropic
claude plugin install github@claude-plugins-official

# Instalación desde un marketplace de terceros
claude plugin install deploy-safe@mi-org-marketplace
```

> **Nota:** No existen los flags `--scope user` ni `--scope project`. Los plugins se instalan a nivel de usuario por defecto.

---

## Marketplaces Privados para Organizaciones

Las organizaciones enterprise pueden configurar un marketplace privado para distribuir plugins internos al equipo sin publicarlos en el marketplace público.

### Configurar un marketplace privado

Un marketplace privado es un repositorio de GitHub que contiene plugins de la organización. No se usa un fichero `registry.json`; los marketplaces privados son repositorios Git.

### Registrar el marketplace privado en Claude Code

Existen dos formas de añadir marketplaces privados:

**Forma interactiva (desde una sesión de Claude Code):**

```bash
# Añadir un marketplace privado
/plugin marketplace add mi-empresa/plugins-marketplace
```

**Forma persistente (en configuración):**

En `.claude/settings.json` (a nivel de usuario o proyecto):

```json
{
  "extraKnownMarketplaces": [
    "mi-empresa/plugins-marketplace"
  ]
}
```

Desde v2.1.80, los plugins también pueden provenir de la fuente `source: 'settings'`, que indica que el plugin fue configurado directamente en el fichero de settings del usuario o del proyecto (en lugar de instalarse desde un marketplace). Esto aparece en la pestaña **Installed** de `/plugin` para distinguir plugins instalados manualmente vía configuración de los instalados desde un marketplace.

Con esta configuración, los desarrolladores de la organización pueden explorar e instalar plugins internos con el mismo flujo que el marketplace público:

```bash
# Ver plugins del marketplace privado junto con el público
/plugin

# Instalar un plugin desde el marketplace privado
claude plugin install deploy-safe@mi-empresa/plugins-marketplace
```

### Distribuir plugins a todo el equipo (ámbito managed)

Para distribuir plugins a todos los usuarios de la organización, los administradores los configuran a través de las managed settings de Claude for Enterprise. Los plugins managed no pueden ser desinstalados por los usuarios y sus hooks y skills están siempre activos.

---

## Políticas de Plugins en Enterprise

### Restringir a marketplaces aprobados

Existen dos mecanismos principales para controlar las fuentes de plugins en entornos enterprise:

**`blockedMarketplaces`** bloquea fuentes de plugins específicas:

```json
{
  "blockedMarketplaces": [
    "usuario-no-confiable/marketplace-no-aprobado"
  ]
}
```

**`strictKnownMarketplaces`** controla qué marketplaces pueden añadir los usuarios:

```json
{
  "strictKnownMarketplaces": true
}
```

Con `strictKnownMarketplaces` activo:

- Los usuarios solo pueden instalar plugins del marketplace oficial de Anthropic (`claude-plugins-official`) y de los marketplaces configurados en `extraKnownMarketplaces`
- Los administradores controlan qué fuentes de plugins están permitidas en la organización
- Intentar añadir un marketplace no autorizado produce un error de política

Estas configuraciones se establecen en las managed settings de Claude for Enterprise.

> **Nota:** No existen comandos `/plugin audit`, `/plugin audit --org` ni `/plugin audit --user`. La gestión de auditoría se realiza a través de la consola de administración enterprise.

---

## Seguridad: Evaluar Plugins de Terceros

Antes de instalar un plugin del marketplace público en un entorno enterprise, realiza esta evaluación:

### Lista de verificación de seguridad

**Origen y mantenimiento:**

- El autor es una empresa o persona con trayectoria verificable, no una cuenta recién creada
- El repositorio del plugin tiene actividad reciente (último commit en los últimos 6 meses)
- El plugin tiene más de 100 instalaciones y puntuación positiva de la comunidad

**Permisos que solicita:**

- Revisa cada permiso en la pestaña Discover de `/plugin` y evalúa si es necesario para la funcionalidad descrita
- Un plugin de formateo de código no necesita acceso a `Bash`; si lo solicita, investiga por qué
- Un plugin de acceso a bases de datos necesita `Read` y posiblemente `Bash` para ejecutar queries; es esperado

**Revisión del código:**

```bash
# Descarga el plugin sin instalarlo para inspeccionarlo
git clone https://github.com/autor/nombre-plugin /tmp/plugin-auditoria

# Revisa el manifest
cat /tmp/plugin-auditoria/.claude-plugin/plugin.json

# Revisa los scripts de hooks
cat /tmp/plugin-auditoria/hooks/*.sh

# Busca patrones sospechosos: llamadas a red, acceso a credenciales, exfiltración de datos
grep -r "curl\|wget\|nc \|netcat" /tmp/plugin-auditoria/hooks/
grep -r "ANTHROPIC_API_KEY\|AWS_SECRET\|DATABASE_URL" /tmp/plugin-auditoria/hooks/
```

**Aislamiento como medida de seguridad:**

Para plugins de alto riesgo que necesitas usar, puedes probarlos primero en local sin instalarlos:

```bash
# Cargar el plugin localmente para evaluarlo sin instalarlo de forma permanente
claude --plugin-dir /tmp/plugin-auditoria
```

De esta forma puedes evaluar el comportamiento del plugin en un entorno controlado antes de instalarlo de forma definitiva.

---

## Setting `disableSkillShellExecution` (v2.1.91)

El setting `disableSkillShellExecution` permite desactivar la ejecución inline de shell en skills, slash commands personalizados y comandos de plugins. Cuando está activo, los bloques de código shell dentro de skills y commands se muestran como referencia pero **no pueden ejecutarse** directamente.

```json
{
  "disableSkillShellExecution": true
}
```

**Caso de uso enterprise:** En organizaciones donde los plugins provienen de fuentes externas, este setting añade una capa de seguridad al impedir que un plugin malicioso ejecute comandos shell arbitrarios a través de skills o commands. Los administradores pueden activarlo en las managed settings para aplicarlo a toda la organización.

> **Nota:** Este setting afecta a skills, slash commands personalizados y comandos de plugins. No afecta a la herramienta Bash integrada de Claude Code, que se controla por separado con el sistema de permisos.

---

## Variable `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` (v2.1.90)

Cuando Claude Code actualiza los plugins del marketplace (vía `git pull`), si la operación falla (por ejemplo, sin conexión a internet), por defecto descarta la cache local del marketplace. La variable de entorno `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` mantiene la cache existente cuando el fetch falla:

```bash
export CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1
```

Útil en entornos con conectividad intermitente o en máquinas que operan offline frecuentemente.

---

## Errores Comunes

**Confundir `strictKnownMarketplaces` con una lista de permisos.** Esta política solo controla de dónde se pueden instalar plugins, no qué permisos tienen. Un plugin del marketplace aprobado sigue teniendo los permisos que declara en su manifest.

**No auditar periódicamente los plugins managed.** Los plugins con ámbito `managed` que se distribuyen a todo el equipo deben revisarse con cada actualización. Una actualización del autor original puede añadir nuevos permisos o cambiar el comportamiento de los hooks.

**Usar un fichero `registry.json` como formato de marketplace.** No existe este formato. Los marketplaces privados son repositorios de GitHub que se añaden con `/plugin marketplace add owner/repo` o con `extraKnownMarketplaces` en settings.

**Instalar el plugin de base de datos con credenciales de producción en el entorno de desarrollo.** Configura el plugin con credenciales de solo lectura o apuntando a una base de datos de desarrollo. Las credenciales de producción deben estar solo en entornos CI/CD controlados.

---

## Resumen

- El marketplace público se explora con `/plugin` (interfaz interactiva con pestañas: Discover, Installed, Marketplaces, Errors)
- Los plugins se instalan con `claude plugin install <nombre>@<marketplace>`. El marketplace oficial es `claude-plugins-official`
- Los marketplaces privados se añaden con `/plugin marketplace add owner/repo` o con `extraKnownMarketplaces` en `.claude/settings.json`
- Los plugins `managed` se distribuyen a todos los usuarios de la organización y no pueden desinstalarse individualmente
- `blockedMarketplaces` bloquea fuentes de plugins específicas; `strictKnownMarketplaces` controla qué marketplaces pueden añadirse
- Antes de instalar un plugin de terceros, revisa el origen, los permisos solicitados y el código de los hooks
