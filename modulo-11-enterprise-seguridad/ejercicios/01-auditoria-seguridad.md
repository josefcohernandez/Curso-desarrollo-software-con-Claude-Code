# Ejercicio 1: Auditoría de Seguridad de tu Configuración de Claude Code

## Objetivo

Realizar una auditoría completa de seguridad de tu configuración actual de Claude Code, identificar vulnerabilidades y crear un plan de remediación.

## Tiempo estimado

15 minutos

## Contexto

Incluso los equipos más experimentados pueden tener configuraciones de seguridad subóptimas. Este ejercicio te guía a través de una revisión sistemática de todos los puntos críticos de seguridad en tu entorno de Claude Code.

---

## Parte 1: Auditar CLAUDE.md en busca de credenciales filtradas

### Paso 1.1: Revisar todos los archivos CLAUDE.md del proyecto

```bash
# Buscar todos los archivos CLAUDE.md en tu proyecto
find . -name "CLAUDE.md" -o -name "CLAUDE.local.md" | head -20

# Para cada archivo encontrado, buscar patrones de credenciales:
grep -rn -E "(password|passwd|secret|api_key|apikey|token|credential|private_key)" \
  --include="CLAUDE.md" --include="CLAUDE.local.md" .

# Buscar patrones de URLs con credenciales embebidas:
grep -rn -E "(https?://[^:]+:[^@]+@)" \
  --include="CLAUDE.md" --include="CLAUDE.local.md" .

# Buscar patrones de claves típicas:
grep -rn -E "(sk-|AKIA|ghp_|gho_|glpat-|xox[bporas]-)" \
  --include="CLAUDE.md" --include="CLAUDE.local.md" .
```

### Paso 1.2: Verificar que CLAUDE.local.md está en .gitignore

```bash
# Verificar que .gitignore incluye CLAUDE.local.md
grep "CLAUDE.local.md" .gitignore

# Si no aparece, añadirlo:
echo "CLAUDE.local.md" >> .gitignore
```

### Paso 1.3: Registrar hallazgos

Completa esta tabla con los resultados:

| Archivo | Línea | Hallazgo | Severidad | Acción |
|---------|-------|----------|-----------|--------|
| | | | | |
| | | | | |

---

## Parte 2: Revisar settings.json y permisos

### Paso 2.1: Localizar todos los archivos de configuración

```bash
# Configuración a nivel de proyecto
cat .claude/settings.json 2>/dev/null || echo "No existe configuración de proyecto"

# Configuración a nivel de usuario
cat ~/.claude/settings.json 2>/dev/null || echo "No existe configuración de usuario"

# Política gestionada (enterprise)
cat /etc/claude-code/settings.json 2>/dev/null || echo "No existe política gestionada"
```

### Paso 2.2: Evaluar los permisos configurados

Responde estas preguntas para cada archivo de settings.json encontrado:

**Lista de verificación de permisos:**

- [ ] ¿Hay una sección `deny` configurada?
- [ ] ¿Se bloquean comandos destructivos? (`rm -rf`, `sudo`, etc.)
- [ ] ¿Se bloquea la exposición de variables de entorno? (`env`, `printenv`)
- [ ] ¿Se bloquea el acceso a archivos sensibles del sistema? (`/etc/shadow`, `~/.ssh/`)
- [ ] ¿Los permisos `allow` son los mínimos necesarios?
- [ ] ¿Se usa auto-accept? Si es así, ¿está limitado a operaciones seguras?

### Paso 2.3: Crear o mejorar la configuración de permisos

Si tu configuración actual es insuficiente, crea una versión mejorada:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(npm test *)",
      "Bash(npm run lint *)",
      "Bash(npm run build)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(env)",
      "Bash(printenv)",
      "Bash(set)",
      "Bash(cat /etc/*)",
      "Bash(cat ~/.ssh/*)",
      "Bash(cat ~/.aws/*)",
      "Bash(curl * | bash)",
      "Bash(wget * | bash)",
      "Bash(chmod 777 *)",
      "Bash(chown *)"
    ]
  }
}
```

---

## Parte 3: Verificar configuración de sandbox

### Paso 3.1: Comprobar el estado del sandbox

```bash
# Verificar el sandbox desde una sesión de Claude Code:
# Ejecuta /sandbox para ver el estado actual

# Verificar la plataforma
uname -s
```

El sandbox se configura en `settings.json` con `"sandbox": { "enabled": true }` o mediante el comando `/sandbox` dentro de una sesión.

### Paso 3.2: Evaluar la necesidad del sandbox

Responde:

| Pregunta | Respuesta (Sí/No) |
|----------|--------------------|
| ¿Trabajas con datos sensibles de clientes? | |
| ¿Tu proyecto accede a servicios de producción? | |
| ¿Tienes credenciales de producción en tu máquina? | |
| ¿Otros desarrolladores pueden modificar archivos del proyecto? | |
| ¿Usas dependencias de terceros sin auditar? | |

> Si respondiste "Sí" a alguna de estas preguntas, el sandbox es **recomendado**.

### Paso 3.3: Activar el sandbox si es necesario

Hay dos formas de activar el sandbox:

**Opción 1: En settings.json (persistente)**

```json
// En .claude/settings.json (proyecto) o ~/.claude/settings.json (usuario)
{
  "sandbox": {
    "enabled": true
  }
}
```

**Opción 2: Desde una sesión de Claude Code**

```bash
# Dentro de Claude Code:
/sandbox
```

---

## Parte 4: Auditar la seguridad de servidores MCP

### Paso 4.1: Listar servidores MCP configurados

```bash
# Configuración MCP del proyecto
cat .claude/settings.json 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    servers = data.get('mcpServers', {})
    if servers:
        for name, config in servers.items():
            print(f'Servidor: {name}')
            print(f'  Comando: {config.get(\"command\", \"N/A\")}')
            print(f'  Args: {config.get(\"args\", [])}')
            has_env = bool(config.get('env', {}))
            print(f'  Tiene variables de entorno: {has_env}')
            print()
    else:
        print('No hay servidores MCP configurados')
except:
    print('No se pudo parsear settings.json')
"

# Configuración MCP del usuario
cat ~/.claude/settings.json 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    servers = data.get('mcpServers', {})
    if servers:
        for name, config in servers.items():
            print(f'Servidor: {name}')
            print(f'  Comando: {config.get(\"command\", \"N/A\")}')
    else:
        print('No hay servidores MCP de usuario')
except:
    print('No se pudo parsear settings.json de usuario')
"
```

### Paso 4.2: Evaluar cada servidor MCP

Para cada servidor MCP encontrado, responde:

| Servidor | ¿Fuente confiable? | ¿Código auditado? | ¿Permisos mínimos? | ¿Credenciales seguras? |
|----------|-------------------|-------------------|--------------------|-----------------------|
| | | | | |
| | | | | |

### Paso 4.3: Verificar que las credenciales de MCP no están expuestas

```bash
# Buscar credenciales hardcodeadas en configuración MCP
grep -rn -E "(password|secret|token|key)" \
  .claude/settings.json ~/.claude/settings.json 2>/dev/null

# Las credenciales deben estar en variables de entorno, no hardcodeadas:
# BIEN:  "env": { "API_KEY": "${MI_API_KEY}" }
# MAL:   "env": { "API_KEY": "sk-1234567890abcdef" }
```

---

## Parte 5: Revisión de archivos .env y .gitignore

### Paso 5.1: Verificar que los archivos .env están ignorados

```bash
# Verificar .gitignore
grep -n "\.env" .gitignore 2>/dev/null || echo "ALERTA: No hay reglas para .env en .gitignore"

# Verificar que ningún .env está trackeado por Git
git ls-files | grep -i "\.env" && echo "ALERTA: Archivos .env trackeados por Git!" || echo "OK: Ningún .env trackeado"

# Verificar que no hay .env en el historial de Git
git log --all --diff-filter=A --name-only --pretty=format: | grep -i "\.env" | sort -u
```

### Paso 5.2: Verificar contenido de .gitignore

Tu .gitignore debería incluir al menos estos patrones de seguridad:

```bash
# Verificar si estos patrones existen en .gitignore
for pattern in ".env" ".env.local" ".env.*.local" "CLAUDE.local.md" "*.pem" "*.key" "credentials.json" ".secret*"; do
  if grep -q "$pattern" .gitignore 2>/dev/null; then
    echo "OK: $pattern está en .gitignore"
  else
    echo "FALTA: $pattern NO está en .gitignore"
  fi
done
```

---

## Parte 6: Crear tu checklist de seguridad

Basándote en los hallazgos de las partes anteriores, completa esta checklist de seguridad personalizada para tu proyecto:

### Resumen de auditoría

| Área | Estado | Hallazgos | Acción requerida |
|------|--------|-----------|------------------|
| CLAUDE.md (credenciales) | OK / ALERTA | | |
| Settings.json (permisos) | OK / ALERTA | | |
| Sandbox | Activado / Desactivado | | |
| Servidores MCP | OK / ALERTA | | |
| .env / .gitignore | OK / ALERTA | | |
| Telemetría | Desactivada / Activa | | |

### Plan de remediación

Prioriza las acciones por severidad:

**Críticas (resolver hoy):**
1. ...
2. ...

**Altas (resolver esta semana):**
1. ...
2. ...

**Medias (resolver este mes):**
1. ...
2. ...

---

## Entregable

Al finalizar este ejercicio deberás tener:

1. Un informe de auditoría con hallazgos documentados
2. Un archivo `settings.json` actualizado con permisos seguros
3. Un `.gitignore` revisado que protege archivos sensibles
4. Sandbox activado (si aplica)
5. Un plan de remediación priorizado para los problemas encontrados

## Criterios de éxito

- [ ] No hay credenciales expuestas en ningún CLAUDE.md
- [ ] Los permisos en settings.json incluyen reglas `deny` para comandos peligrosos
- [ ] El sandbox está evaluado y activado si es necesario
- [ ] Los servidores MCP han sido revisados
- [ ] Los archivos .env están correctamente ignorados por Git
- [ ] Existe un plan de remediación para cualquier hallazgo
