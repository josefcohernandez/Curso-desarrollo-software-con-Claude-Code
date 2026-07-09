# 03 - Sandbox y Seguridad

## Qué es el Sandbox

El sandbox aísla los comandos que ejecuta Claude Code del resto del sistema,
limitando el acceso a archivos y red.

---

## Activacion

La forma oficial de activar el sandbox es mediante `settings.json` o el comando interactivo `/sandbox`:

```json
{
  "sandbox": {
    "enabled": true
  }
}
```

O durante una sesion interactiva:

```bash
# Desde el prompt de Claude Code
/sandbox
```

---

## Implementación por Plataforma

### macOS: Apple Seatbelt

Usa `sandbox-exec` nativo de macOS para restringir procesos:
- Acceso limitado al directorio del proyecto
- Red restringida según configuración
- No puede acceder a archivos fuera del proyecto

### Linux: bubblewrap (bwrap) + socat

Usa **bubblewrap** (bwrap) junto con socat para crear un entorno aislado:
- Filesystem aislado (solo directorio del proyecto accesible)
- Red configurable mediante `sandbox.network.allowedDomains`
- Procesos aislados del host sin necesidad de contenedores

```bash
# Verificar que bubblewrap esta instalado
bwrap --version

# En Debian/Ubuntu, instalar si no esta disponible
sudo apt install bubblewrap
```

---

## Qué Previene el Sandbox

| Amenaza | Sin sandbox | Con sandbox |
|---------|------------|-------------|
| Leer ~/.ssh/id_rsa | Posible | Bloqueado |
| Leer /etc/passwd | Posible | Bloqueado |
| Instalar paquetes globales | Posible | Bloqueado |
| Acceder a otros proyectos | Posible | Bloqueado |
| Ejecutar rm -rf / | Posible (si allow) | Bloqueado |
| Enviar datos a internet | Posible | Configurable |

---

## Cuándo Activar el Sandbox

| Escenario | Sandbox recomendado |
|-----------|-------------------|
| Desarrollo local confiable | Opcional |
| Proyecto open source con PRs externos | Sí |
| CI/CD automatizado | Sí |
| Demo o formación | Sí |
| Entorno enterprise regulado | Sí |
| Explorando código desconocido | Sí |

---

## Configuracion de Seguridad

### En settings.json (forma recomendada)

| Clave | Proposito |
|-------|----------|
| `sandbox.enabled: true` | Activar sandbox |
| `sandbox.filesystem.allowRead` | Lista de rutas adicionales de solo lectura accesibles dentro del sandbox (v2.1.77+) |
| `sandbox.network.allowedDomains` | Lista de dominios permitidos para acceso a red dentro del sandbox |
| `sandbox.network.deniedDomains` | Lista de dominios bloqueados aunque `allowedDomains` los permitiría (v2.1.113+) |

```json
{
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "allowRead": [
        "/usr/share/fonts",
        "/opt/shared-configs"
      ]
    },
    "network": {
      "allowedDomains": [
        "registry.npmjs.org",
        "api.github.com"
      ]
    }
  }
}
```

La clave `sandbox.filesystem.allowRead` permite que procesos dentro del sandbox lean rutas adicionales fuera del directorio del proyecto (por ejemplo, fuentes del sistema o configuraciones compartidas). Las rutas listadas se montan como de solo lectura.

### `sandbox.network.deniedDomains`: bloqueo selectivo de dominios (v2.1.113)

`deniedDomains` actúa como una lista de exclusión que se aplica **después** de `allowedDomains`. Esto permite usar un wildcard amplio en `allowedDomains` y luego bloquear dominios específicos de forma explícita, sin tener que enumerar todos los dominios permitidos uno a uno.

El caso de uso más habitual es el acceso abierto a internet salvo dominios internos o sensibles:

```json
{
  "sandbox": {
    "enabled": true,
    "network": {
      "allowedDomains": ["*"],
      "deniedDomains": [
        "internal.company.com",
        "secrets.vault.internal",
        "metadata.google.internal"
      ]
    }
  }
}
```

Con esta configuración, el sandbox puede acceder a cualquier dominio público pero tiene bloqueado el acceso a la red interna corporativa y al endpoint de metadatos de instancias de nube.

**Orden de evaluación**: primero se comprueba `deniedDomains`; si el dominio coincide, se bloquea independientemente de lo que diga `allowedDomains`. La regla de denegación siempre gana, igual que en el sistema de permisos general.

### Variables de entorno adicionales

| Variable | Proposito |
|----------|----------|
| `DISABLE_NONESSENTIAL_TRAFFIC=1` | Bloquear telemetria y trafico no esencial |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` | Eliminar credenciales del entorno de subprocesos |

### `sandbox.credentials`: bloquear lectura de credenciales dentro del sandbox (v2.1.187)

El setting `sandbox.credentials` impide que los comandos ejecutados dentro del sandbox **lean ficheros de credenciales y variables de entorno secretas**, aunque esas rutas o variables sean técnicamente accesibles según el resto de la configuración del sandbox.

```json
{
  "sandbox": {
    "enabled": true,
    "credentials": {
      "blockFiles": [
        "~/.aws/credentials",
        "~/.ssh/id_*",
        "~/.npmrc",
        "~/.docker/config.json"
      ],
      "blockEnvVars": [
        "AWS_SECRET_ACCESS_KEY",
        "NPM_TOKEN",
        "DATABASE_URL"
      ]
    }
  }
}
```

**Por qué es distinto de `sandbox.filesystem.allowRead`:** `allowRead` controla qué rutas *adicionales* puede leer el sandbox; `sandbox.credentials` es una capa de **bloqueo explícito** que se aplica incluso si una ruta de credenciales quedara accesible por error en la configuración del filesystem. Es la forma recomendada de garantizar que un comando sandboxeado nunca puede filtrar secretos, independientemente del resto de reglas.

### `sandbox.allowAppleEvents`: opt-in para automatización en macOS (v2.1.181)

Por defecto, el sandbox de macOS (Apple Seatbelt) bloquea el envío de **Apple Events**, el mecanismo de macOS que permite a un proceso controlar otras aplicaciones (por ejemplo, automatizar Finder, Safari o apps de terceros vía AppleScript/JXA). Con `sandbox.allowAppleEvents` activado explícitamente, los comandos dentro del sandbox pueden enviar Apple Events:

```json
{
  "sandbox": {
    "enabled": true,
    "allowAppleEvents": true
  }
}
```

Este setting solo tiene efecto en macOS y es **opt-in**: debe activarse explícitamente porque los Apple Events son una vía potente de automatización entre aplicaciones que, sin restricción, podría usarse para interactuar con software fuera del ámbito del proyecto (por ejemplo, controlar el navegador para exfiltrar datos). Actívalo únicamente si tu workflow depende de automatización nativa de macOS (scripts que controlan otras apps) y confías en el contenido del repositorio.

---

## Configuración avanzada del Sandbox

### `sandbox.failIfUnavailable`

Por defecto, si el sandbox no esta disponible (bubblewrap no instalado en Linux, o restriccion del sistema en macOS), Claude Code continua sin sandbox y muestra un aviso. Con esta opcion activada, Claude Code **termina con error** si el sandbox no esta disponible, garantizando que nunca se ejecuten comandos sin aislamiento.

```json
{
  "sandbox": {
    "failIfUnavailable": true
  }
}
```

Esto es especialmente útil en entornos enterprise y CI/CD donde el sandbox es un requisito obligatorio de seguridad.

---

## Directorios protegidos en modo acceptEdits (v2.1.90)

El modo `acceptEdits` protege ciertos directorios de escritura automática para evitar modificaciones accidentales a configuraciones críticas. Desde v2.1.90, el directorio `.husky` (hooks de Git gestionados por Husky) se añade a la lista de directorios protegidos, junto con `.git`, `.claude` y otros.

### Confirmación al escribir en ficheros de arranque de shell y configuración global de git (v2.1.160)

Independientemente del modo de permisos activo, Claude Code pide **confirmación explícita** antes de escribir en ficheros que se ejecutan automáticamente al iniciar una shell o que afectan a la configuración global de git:

| Fichero / directorio | Por qué es sensible |
|-----------------------|---------------------|
| `~/.zshenv`, `~/.zlogin` | Se ejecutan en cada shell zsh, incluso no interactiva; un cambio malicioso se ejecuta silenciosamente en cada sesión futura |
| `~/.bash_login` | Equivalente para bash: se ejecuta al iniciar sesiones de login |
| `~/.config/git/` | Configuración global de git (alias, hooks, credenciales); un cambio aquí afecta a todos los repositorios del usuario |

```bash
# Claude Code detecta una escritura en un fichero de arranque de shell:
# "¿Confirmas que quieres modificar ~/.zshenv?
#  Este fichero se ejecuta automáticamente en cada sesión de shell."
# [y/n]
```

Esta protección aplica incluso en modos donde normalmente no se pediría confirmación para `Write`/`Edit` (como `acceptEdits`), porque el riesgo de persistencia — un cambio que se ejecuta en cada shell futura, no solo en la sesión actual — es cualitativamente distinto al de editar un fichero del proyecto.

### Confirmación en `acceptEdits` para ficheros de configuración de build-tools (v2.1.160)

El modo `acceptEdits` auto-acepta ediciones de archivos por defecto, pero desde v2.1.160 hace una excepción para ficheros de configuración de herramientas de build que **otorgan ejecución de código** como efecto secundario de su configuración — por ejemplo, hooks de `package.json` (`postinstall`, `preinstall`), configuración de plugins de Webpack/Vite que cargan módulos arbitrarios, o ficheros de configuración de Gradle/Maven con tareas personalizadas.

```json
// package.json — este cambio pide confirmación incluso en acceptEdits
{
  "scripts": {
    "postinstall": "node scripts/setup.js"
  }
}
```

**Motivo:** un `postinstall` malicioso se ejecuta automáticamente la próxima vez que alguien haga `npm install`, sin que el desarrollador lo note. Auto-aceptar este tipo de cambios sin revisión sería equivalente a auto-aceptar ejecución de código arbitrario diferida. Por eso `acceptEdits` trata estos ficheros como una excepción y pide confirmación manual.

---

## Limitaciones del Sandbox

- **Rendimiento**: Ligero overhead al ejecutar comandos en entorno aislado
- **Compatibilidad**: Algunas herramientas pueden no funcionar en sandbox
- **Configuracion**: Puede requerir ajustes para MCPs que necesitan acceso a red (usar `sandbox.network.allowedDomains`)
- **bubblewrap requerido** en Linux (no aplica en macOS que usa Seatbelt nativo)

---

## Seguridad sin Sandbox

Incluso sin sandbox, puedes mejorar la seguridad con:

1. **Permisos restrictivos**: deny para comandos peligrosos
2. **Hooks de seguridad**: PreToolUse para validar comandos
3. **CLAUDE.md con restricciones**: Instruir a Claude qué no hacer
4. **Revisión manual**: No usar auto-accept para Bash

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(curl * | bash)",
      "Bash(wget *)",
      "Bash(chmod 777 *)",
      "Write(.env*)",
      "Write(*secret*)",
      "Write(*credential*)"
    ]
  }
}
```

---

## Resumen

| Capa de seguridad | Protección | Esfuerzo |
|-------------------|-----------|----------|
| Permisos deny | Comandos específicos | Bajo |
| Hooks PreToolUse | Validación dinámica | Medio |
| Sandbox | Aislamiento completo | Bajo (activar en settings) |
| Managed policies | Control corporativo | Admin |
