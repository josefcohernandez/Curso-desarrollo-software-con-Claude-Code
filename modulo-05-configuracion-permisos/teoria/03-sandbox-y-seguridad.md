# 03 - Sandbox y Seguridad

## Qué es el Sandbox

El sandbox aísla los comandos que ejecuta Claude Code del resto del sistema,
limitando el acceso a archivos y red.

---

## Activación

```bash
export CLAUDE_CODE_ENABLE_SANDBOX=1
claude
```

O de forma persistente:

```bash
echo 'export CLAUDE_CODE_ENABLE_SANDBOX=1' >> ~/.bashrc
```

---

## Implementación por Plataforma

### macOS: Apple Seatbelt

Usa `sandbox-exec` nativo de macOS para restringir procesos:
- Acceso limitado al directorio del proyecto
- Red restringida según configuración
- No puede acceder a archivos fuera del proyecto

### Linux: Docker Sandbox

Ejecuta comandos dentro de un contenedor Docker:
- Filesystem aislado (solo directorio del proyecto montado)
- Red configurable
- Procesos aislados del host

```bash
# Requiere Docker instalado
docker --version  # Verificar
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

## Variables de Seguridad

| Variable | Propósito |
|----------|----------|
| `CLAUDE_CODE_ENABLE_SANDBOX=1` | Activar sandbox |
| `DISABLE_NONESSENTIAL_TRAFFIC=1` | Bloquear telemetría y tráfico no esencial |
| `CLAUDE_CODE_DISABLE_NETWORK=1` | Sin acceso a red (sandbox estricto) |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` | Eliminar credenciales del entorno de subprocesos |

---

## Configuración avanzada del Sandbox

### `sandbox.failIfUnavailable`

Por defecto, si el sandbox no está disponible (Docker no instalado en Linux, o restricción del sistema en macOS), Claude Code continúa sin sandbox y muestra un aviso. Con esta opción activada, Claude Code **termina con error** si el sandbox no está disponible, garantizando que nunca se ejecuten comandos sin aislamiento.

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

- **Rendimiento**: Ligero overhead al ejecutar comandos en contenedor
- **Compatibilidad**: Algunas herramientas pueden no funcionar en sandbox
- **Configuración**: Puede requerir ajustes para MCPs que necesitan acceso a red
- **Docker requerido** en Linux (no aplica en macOS)

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
| Sandbox | Aislamiento completo | Bajo (activar variable) |
| Managed policies | Control corporativo | Admin |
