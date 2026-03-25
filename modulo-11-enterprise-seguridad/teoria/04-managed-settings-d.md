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

## Puntos clave

- `managed-settings.d/` permite distribuir políticas de Claude Code en fragmentos modulares
- Los fragmentos se fusionan en **orden alfabético** por nombre de fichero
- Usar prefijos numéricos (`00-`, `10-`, `20-`) para controlar la precedencia
- Los arrays de permisos (`allow`, `deny`) se concatenan; las propiedades escalares usan el último valor
- `managed-settings.json` se aplica antes que los fragmentos de `managed-settings.d/`
- Ideal para organizaciones multi-equipo donde diferentes departamentos gestionan diferentes aspectos de la configuración
