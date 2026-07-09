# managed-settings.d/: Políticas Modulares para Despliegues Multi-Equipo

> **Novedad v3.0 (v2.1.83)**

## Qué es managed-settings.d/

El directorio `managed-settings.d/` permite distribuir la configuración enterprise de Claude Code en **múltiples ficheros independientes** que se fusionan automáticamente. En lugar de mantener un único `managed-settings.json` monolítico, cada equipo o departamento puede desplegar su propio fragmento de política.

### El problema que resuelve

En organizaciones grandes, un único fichero de políticas gestionadas tiene limitaciones:

| Problema | Impacto |
|----------|---------|
| Un solo punto de edición | Conflictos entre equipos que necesitan cambiar políticas |
| Todo o nada | No se pueden desplegar políticas por equipo |
| Dificultad de auditoría | Un fichero grande es difícil de revisar |
| Gestión con MDM/GPO | Difícil distribuir un único fichero desde múltiples fuentes |

`managed-settings.d/` resuelve estos problemas permitiendo composición modular.

---

## Ubicación

El directorio se ubica junto al `managed-settings.json` del sistema:

```
# Linux/WSL
/etc/claude-code/managed-settings.d/

# macOS
/Library/Application Support/ClaudeCode/managed-settings.d/
```

---

## Cómo funciona el merge

Los fragmentos se fusionan en **orden alfabético** por nombre de fichero. Esto permite controlar la precedencia usando prefijos numéricos:

```
managed-settings.d/
  00-seguridad-base.json       # Primero: políticas de seguridad fundamentales
  10-devops-tools.json         # Segundo: herramientas de DevOps
  20-equipo-frontend.json      # Tercero: configuración del equipo frontend
  30-equipo-backend.json       # Cuarto: configuración del equipo backend
  99-override-emergencia.json  # Último: overrides de emergencia
```

### Reglas de fusión

- Los fragmentos se procesan en orden alfabético
- Las propiedades de nivel superior se fusionan (merge, no reemplazo)
- Los arrays de `permissions.allow` y `permissions.deny` se **concatenan**
- Si dos fragmentos definen la misma propiedad escalar, el último (alfabéticamente) gana
- El `managed-settings.json` principal se aplica **antes** que los fragmentos de `managed-settings.d/`

---

## Formato de los fragmentos

Cada fichero es un JSON con la misma estructura que `settings.json`:

### Fragmento de seguridad (`00-seguridad-base.json`)

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(curl * | bash)",
      "Bash(wget * | bash)",
      "Write(.env*)",
      "Write(*secret*)"
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_SANDBOX": "1",
    "CLAUDE_CODE_SUBPROCESS_ENV_SCRUB": "1"
  }
}
```

### Fragmento de DevOps (`10-devops-tools.json`)

```json
{
  "permissions": {
    "allow": [
      "Bash(docker *)",
      "Bash(kubectl get *)",
      "Bash(terraform plan *)"
    ]
  },
  "mcpServers": {
    "monitoring": {
      "command": "mcp-server-datadog",
      "env": {
        "DD_API_KEY": "${DD_API_KEY}"
      }
    }
  }
}
```

### Fragmento de equipo frontend (`20-equipo-frontend.json`)

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(npx *)",
      "Bash(yarn *)"
    ]
  },
  "model": "claude-sonnet-4-6"
}
```

---

## Resultado de la fusión

Con los tres fragmentos anteriores, la política resultante sería:

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(curl * | bash)",
      "Bash(wget * | bash)",
      "Write(.env*)",
      "Write(*secret*)"
    ],
    "allow": [
      "Bash(docker *)",
      "Bash(kubectl get *)",
      "Bash(terraform plan *)",
      "Bash(npm run *)",
      "Bash(npx *)",
      "Bash(yarn *)"
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_SANDBOX": "1",
    "CLAUDE_CODE_SUBPROCESS_ENV_SCRUB": "1"
  },
  "mcpServers": {
    "monitoring": {
      "command": "mcp-server-datadog",
      "env": {
        "DD_API_KEY": "${DD_API_KEY}"
      }
    }
  },
  "model": "claude-sonnet-4-6"
}
```

---

## Ventajas para enterprise

| Ventaja | Descripción |
|---------|-------------|
| **Separación de responsabilidades** | Seguridad gestiona sus políticas, DevOps las suyas, cada equipo las suyas |
| **Despliegue con MDM/GPO** | Cada fragmento se distribuye independientemente por el sistema de gestión |
| **Auditoría granular** | Cada fichero tiene un propietario claro y se puede versionar por separado |
| **Rollback selectivo** | Se puede eliminar un fragmento sin afectar a los demás |
| **Onboarding de equipos** | Un nuevo equipo solo necesita desplegar su propio fragmento |

---

## Diferencias con managed-settings.json

| Aspecto | `managed-settings.json` | `managed-settings.d/` |
|---------|------------------------|----------------------|
| Fichero | Uno solo | Múltiples |
| Gestión | Centralizada | Distribuida |
| Conflictos | Todo en un punto | Separación por equipo |
| Precedencia | Se aplica primero | Fragmentos se aplican después, en orden alfabético |
| Caso de uso | Políticas globales simples | Organizaciones multi-equipo |

Ambos mecanismos son complementarios: `managed-settings.json` define la base, y los fragmentos en `managed-settings.d/` añaden o refinan configuración por equipo.

---

## Ejemplo completo: organización con 3 equipos

```
/etc/claude-code/
  managed-settings.json              # Políticas base (modelo, sandbox)
  managed-settings.d/
    00-compliance.json               # Equipo de compliance: deny list
    10-platform.json                 # Equipo de plataforma: MCP servers
    20-team-payments.json            # Equipo de pagos: permisos de BD
    20-team-search.json              # Equipo de búsqueda: permisos de Elasticsearch
    20-team-mobile.json              # Equipo mobile: permisos de React Native
```

Cada equipo gestiona su propio fichero. El equipo de compliance puede actualizar sus reglas de `deny` sin coordinarse con los demás. El equipo de plataforma puede añadir nuevos servidores MCP sin tocar las políticas de seguridad.

---

## Bloqueo de Plugins por Política

> **Novedad v3.2 (v2.1.85) — Ampliado en v2.1.117**

Los plugins bloqueados por la política de la organización (definida en `managed-settings.json` o en fragmentos de `managed-settings.d/`) **no pueden instalarse ni habilitarse**, y se ocultan completamente de las vistas del marketplace. Esto refuerza el control enterprise: si un administrador bloquea un plugin, los usuarios no pueden eludirlo.

Desde v2.1.117, las opciones `blockedMarketplaces` y `strictKnownMarketplaces` se aplican de forma efectiva durante las **operaciones de instalación y gestión de plugins**, no solo al renderizar la vista del marketplace. Esto cierra la brecha por la que un usuario podría intentar instalar un plugin de un marketplace bloqueado por vías alternativas (por ejemplo, mediante la CLI o comandos directos).

```json
{
  "blockedMarketplaces": ["marketplace-no-aprobado.example.com"],
  "strictKnownMarketplaces": true
}
```

| Opción | Efecto |
|--------|--------|
| `blockedMarketplaces` | Lista de marketplaces bloqueados. No se puede instalar ni gestionar plugins de estos orígenes. |
| `strictKnownMarketplaces` | Cuando es `true`, solo se permiten marketplaces explícitamente aprobados/conocidos. Bloquea cualquier marketplace no incluido en la lista oficial. |

> **Antes de v2.1.117**: Las restricciones solo se aplicaban al mostrar la interfaz del marketplace (ocultaban plugins en la vista). Un usuario avanzado podía intentar instalar un plugin de un marketplace bloqueado saltando la UI.
>
> **Desde v2.1.117**: Las restricciones se comprueban también en el momento de la operación de instalación o gestión, de modo que el bloqueo es efectivo independientemente de cómo se intente la instalación.

### Marketplaces sugeridos: `pluginSuggestionMarketplaces` (v2.1.152)

Además de bloquear o restringir marketplaces, los administradores pueden controlar de qué fuentes Claude Code **sugiere proactivamente** plugins al usuario a través de tips contextuales (por ejemplo, cuando detecta un patrón de trabajo que un plugin conocido resolvería). El setting `pluginSuggestionMarketplaces` define la lista de marketplaces cuyos plugins pueden aparecer en estas sugerencias:

```json
{
  "pluginSuggestionMarketplaces": [
    "claude-plugins-official",
    "mi-empresa/plugins-marketplace"
  ]
}
```

| Sin `pluginSuggestionMarketplaces` | Con `pluginSuggestionMarketplaces` |
|-------------------------------------|--------------------------------------|
| Claude Code puede sugerir plugins de cualquier marketplace conocido (público o `extraKnownMarketplaces`) | Las sugerencias proactivas se limitan a los marketplaces listados explícitamente |

**Diferencia con `blockedMarketplaces`/`strictKnownMarketplaces`**: estas dos opciones controlan qué se puede **instalar**; `pluginSuggestionMarketplaces` controla qué se puede **sugerir** de forma proactiva. Un marketplace puede estar permitido para instalación manual pero excluido de las sugerencias automáticas, por ejemplo si contiene plugins experimentales que el equipo de plataforma no quiere promocionar activamente a todos los desarrolladores.

> Para el resto de novedades de plugins de esta versión (auto-carga desde `.claude/skills`, `claude plugin init`, `defaultEnabled`, dependencias entre plugins), consulta el [Módulo 15: Plugins y Marketplaces](../../modulo-15-plugins-marketplaces/README.md).

---

## Requisitos de versión mínima/máxima: `requiredMinimumVersion` y `requiredMaximumVersion` (v2.1.163)

Al igual que `forceRemoteSettingsRefresh` bloquea el arranque si las políticas no están frescas, los managed settings `requiredMinimumVersion` y `requiredMaximumVersion` bloquean el arranque de Claude Code si el binario instalado está **fuera del rango de versión permitido** por la organización:

```json
{
  "requiredMinimumVersion": "2.1.150",
  "requiredMaximumVersion": "2.1.210"
}
```

| Escenario | Comportamiento |
|-----------|----------------|
| Versión instalada por debajo de `requiredMinimumVersion` | Claude Code **rechaza arrancar** con un mensaje indicando la versión mínima requerida |
| Versión instalada por encima de `requiredMaximumVersion` | Claude Code **rechaza arrancar**; útil para congelar una versión validada mientras se completa la evaluación de seguridad de una release nueva |
| Versión dentro del rango | Arranque normal |

**Casos de uso**:

- **Forzar actualización de seguridad**: si se descubre una vulnerabilidad corregida en una versión concreta, `requiredMinimumVersion` garantiza que ningún desarrollador siga usando una versión vulnerable.
- **Congelar una versión validada**: en entornos regulados donde cada versión de Claude Code pasa por un proceso de aprobación de seguridad, `requiredMaximumVersion` impide que los desarrolladores actualicen automáticamente a una versión aún no aprobada, incluso si `claude update` la descarga.
- **Ventana de compatibilidad conocida**: combinar ambos valores para garantizar que toda la organización opera dentro de un rango de versiones probado con la infraestructura interna (Gateway, servidores MCP corporativos, etc.).

Igual que el resto de managed settings, estas claves solo tienen efecto cuando se definen en `managed-settings.json` o en un fragmento de `managed-settings.d/`; no pueden sobrescribirse desde `settings.json` de proyecto o usuario.

---

## Política de fusión entre niveles: `parentSettingsBehavior` (v2.1.133)

Por defecto, la jerarquía de settings de Claude Code fusiona las configuraciones de cada nivel (managed → proyecto → usuario) según las reglas estándar: los arrays de permisos se concatenan, las claves escalares se sobrescriben por el nivel de mayor prioridad. El managed setting `parentSettingsBehavior` permite a los administradores **cambiar esta política de fusión** para toda la organización, endureciendo o relajando cómo interactúan los niveles inferiores con las políticas gestionadas.

```json
{
  "parentSettingsBehavior": "strict"
}
```

| Valor | Efecto |
|-------|--------|
| `merge` (comportamiento por defecto) | Los niveles de proyecto y usuario pueden añadir configuración adicional que se fusiona con la managed, sin contradecir los `deny` |
| `strict` | Los niveles de proyecto y usuario solo pueden **restringir** aún más la configuración managed; cualquier intento de ampliar permisos o cambiar valores protegidos se ignora silenciosamente |

**Cuándo usar `strict`**: organizaciones con requisitos de cumplimiento donde incluso la posibilidad teórica de que un `settings.json` de proyecto amplíe una política gestionada (por ejemplo, añadiendo un `allow` que no contradice ningún `deny` explícito pero sí amplía la superficie de permisos) representa un riesgo inaceptable. Con `parentSettingsBehavior: strict`, la política gestionada se convierte en un techo real, no solo en una base con `deny` prioritarios.

> Esta clave es de nivel **admin-tier**: solo tiene efecto si se define en las managed settings del sistema. Definirla en `settings.json` de proyecto o usuario no tiene ningún efecto.

---

## Política fail-closed: `forceRemoteSettingsRefresh` (v2.1.92)

El setting `forceRemoteSettingsRefresh` es una política de seguridad que **bloquea el arranque** de Claude Code hasta que las managed settings remotas se obtengan frescas del servidor. Si el fetch falla (sin conexión, timeout, error del servidor), Claude Code **sale con error** en lugar de continuar con settings cacheadas o sin políticas.

```json
{
  "forceRemoteSettingsRefresh": true
}
```

**Caso de uso**: Entornos enterprise con políticas de seguridad estrictas donde es preferible que Claude Code no funcione a que funcione sin las políticas actualizadas. Garantiza que ningún desarrollador pueda operar con políticas obsoletas o sin políticas aplicadas.

| Escenario | Sin `forceRemoteSettingsRefresh` | Con `forceRemoteSettingsRefresh` |
|-----------|--------------------------------|----------------------------------|
| Servidor de políticas disponible | Carga políticas frescas | Carga políticas frescas |
| Servidor de políticas caído | Usa cache o arranca sin políticas | **No arranca** (fail-closed) |
| Sin conexión a red | Usa cache o arranca sin políticas | **No arranca** (fail-closed) |

Este setting se define en las managed settings del sistema (no en las del proyecto o usuario) y no puede ser sobreescrito por niveles inferiores de la jerarquía.

---

## Herencia de managed settings de Windows en WSL: `wslInheritsWindowsSettings` (v2.1.118)

En entornos Windows con WSL (Windows Subsystem for Linux), los equipos de IT habitualmente gestionan la configuración de Claude Code a través de las políticas de Windows (Group Policy / MDM). Desde v2.1.118, activar la policy key `wslInheritsWindowsSettings` hace que la instancia de Claude Code que se ejecuta **dentro de WSL** herede automáticamente las managed settings definidas en el lado Windows.

```json
{
  "wslInheritsWindowsSettings": true
}
```

Esta policy key se define en el fichero de managed settings del **lado Windows** (no en WSL):

```
C:\Program Files\ClaudeCode\managed-settings.json
```

### Cómo funciona

Sin `wslInheritsWindowsSettings`, Claude Code en WSL y Claude Code en Windows son instancias independientes con configuraciones separadas:

```
Windows
  C:\Program Files\ClaudeCode\managed-settings.json   →  Claude Code (Windows)
  /etc/claude-code/managed-settings.json              →  Claude Code (WSL)   [independiente]
```

Con `wslInheritsWindowsSettings: true`, la instancia de WSL lee las políticas desde el lado Windows:

```
Windows
  C:\Program Files\ClaudeCode\managed-settings.json   →  Claude Code (Windows)
                                                       →  Claude Code (WSL)   [hereda]
```

### Ventaja operacional

Los administradores IT que ya gestionan las políticas de Claude Code en Windows (via Group Policy u otras herramientas MDM) aplican automáticamente esas mismas políticas a WSL, sin necesidad de gestionar un segundo fichero en la ruta de Linux. Esto es especialmente útil en:

- Organizaciones que distribuyen las políticas via GPO o Intune
- Equipos de desarrollo que usan WSL pero cuyas máquinas están gestionadas por IT desde Windows
- Entornos donde garantizar que las restricciones de seguridad aplican por igual en Windows y WSL

> **Nota**: `wslInheritsWindowsSettings` no afecta a instalaciones de Linux nativas (no WSL). Solo tiene efecto cuando Claude Code se ejecuta dentro de un entorno WSL sobre Windows.

---

## Puntos clave

- `managed-settings.d/` permite distribuir políticas de Claude Code en fragmentos modulares
- Los fragmentos se fusionan en **orden alfabético** por nombre de fichero
- Usar prefijos numéricos (`00-`, `10-`, `20-`) para controlar la precedencia
- Los arrays de permisos (`allow`, `deny`) se concatenan; las propiedades escalares usan el último valor
- `managed-settings.json` se aplica antes que los fragmentos de `managed-settings.d/`
- Ideal para organizaciones multi-equipo donde diferentes departamentos gestionan diferentes aspectos de la configuración
- Desde v2.1.117, `blockedMarketplaces` y `strictKnownMarketplaces` se aplican en las operaciones de instalación de plugins, no solo en la visualización del marketplace
- `wslInheritsWindowsSettings: true` permite que Claude Code en WSL herede las políticas gestionadas desde el lado Windows, simplificando la gestión centralizada en entornos mixtos
- `pluginSuggestionMarketplaces` (v2.1.152) limita de qué marketplaces Claude Code puede sugerir plugins de forma proactiva, independientemente de qué marketplaces estén permitidos para instalación manual
- `requiredMinimumVersion`/`requiredMaximumVersion` (v2.1.163) bloquean el arranque de Claude Code si el binario instalado está fuera del rango de versión aprobado por la organización
- `parentSettingsBehavior: strict` (v2.1.133) convierte la política gestionada en un techo real: los niveles de proyecto y usuario solo pueden restringir, nunca ampliar, la configuración managed
