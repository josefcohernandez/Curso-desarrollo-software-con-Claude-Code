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
| `sandbox.network.allowedDomains` | Lista de dominios permitidos para acceso a red dentro del sandbox |

```json
{
  "sandbox": {
    "enabled": true,
    "network": {
      "allowedDomains": [
        "registry.npmjs.org",
        "api.github.com"
      ]
    }
  }
}
```

### Variables de entorno adicionales

| Variable | Proposito |
|----------|----------|
| `DISABLE_NONESSENTIAL_TRAFFIC=1` | Bloquear telemetria y trafico no esencial |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` | Eliminar credenciales del entorno de subprocesos |

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
