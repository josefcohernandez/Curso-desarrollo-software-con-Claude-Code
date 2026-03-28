# Ejercicio 2: Configuración Tipo Enterprise

## Objetivo

Simular la configuración de Claude Code para un entorno enterprise, creando políticas gestionadas, configuraciones compartidas de equipo, perfiles de permisos y una guía de onboarding para nuevos miembros.

## Tiempo estimado

15 minutos

## Contexto

En este ejercicio actuarás como el administrador o lead técnico responsable de configurar Claude Code para un equipo de 10 desarrolladores que trabajan en un proyecto con datos sensibles. El equipo es políglota: usa Python, TypeScript y Go.

---

## Parte 1: Crear política gestionada (Managed Policy)

### Escenario

Tu organización requiere que:

- Todos los desarrolladores usen Sonnet por defecto (control de costes)
- Ningún desarrollador pueda ejecutar comandos destructivos
- La telemetría esté desactivada
- El sandbox esté activado
- Ciertos comandos de infraestructura estén bloqueados

### Tarea 1.1: Crear el archivo de política gestionada

Crea el archivo `/etc/claude-code/settings.json` (como ejercicio, crea una copia local en tu proyecto).

```bash
# Crear directorio para el ejercicio
# Nota: se usa un directorio temporal dentro del proyecto para simular
# la ruta /etc/claude-code/ sin necesidad de permisos de administrador.
# En un entorno real, este archivo se crearía en /etc/claude-code/settings.json
# con permisos de root para que los usuarios no puedan modificarlo.
mkdir -p ejercicio-enterprise/etc/claude-code
```

Crea un archivo `ejercicio-enterprise/etc/claude-code/settings.json` con las siguientes restricciones:

1. **Modelo por defecto**: `claude-sonnet-4-20250514`
2. **Permisos permitidos**:
   - Operaciones de lectura (Read, Glob, Grep)
   - Tests en los tres lenguajes (`pytest`, `npm test`, `go test`)
   - Linting (`ruff`, `eslint`, `golangci-lint`)
   - Operaciones de Git no destructivas
   - Docker Compose para desarrollo
3. **Permisos denegados**:
   - Cualquier uso de `sudo`
   - Eliminación recursiva (`rm -rf`)
   - Exposición de variables de entorno (`env`, `printenv`, `set`)
   - Acceso a archivos sensibles del sistema
   - Descarga y ejecución de scripts (`curl | bash`, `wget | bash`)
   - Operaciones destructivas de Docker en producción
   - Acceso a credenciales del sistema
4. **Variables de entorno**:
   - Desactivar telemetría
   - Activar sandbox

> **Consejo:** Solución de referencia
>
> ```json
> {
>   "permissions": {
>     "allow": [
>       "Read",
>       "Glob",
>       "Grep",
>       "Bash(pytest *)",
>       "Bash(python -m pytest *)",
>       "Bash(npm test *)",
>       "Bash(npx vitest *)",
>       "Bash(go test *)",
>       "Bash(ruff check *)",
>       "Bash(ruff format *)",
>       "Bash(npx eslint *)",
>       "Bash(npx prettier *)",
>       "Bash(golangci-lint run *)",
>       "Bash(git status)",
>       "Bash(git diff *)",
>       "Bash(git log *)",
>       "Bash(git branch *)",
>       "Bash(git show *)",
>       "Bash(docker compose up *)",
>       "Bash(docker compose down *)",
>       "Bash(docker compose logs *)",
>       "Bash(docker compose ps *)",
>       "Bash(make *)"
>     ],
>     "deny": [
>       "Bash(sudo *)",
>       "Bash(rm -rf *)",
>       "Bash(rm -r /)",
>       "Bash(env)",
>       "Bash(printenv)",
>       "Bash(set)",
>       "Bash(cat /etc/shadow)",
>       "Bash(cat /etc/passwd)",
>       "Bash(cat ~/.ssh/*)",
>       "Bash(cat ~/.aws/*)",
>       "Bash(cat ~/.config/gcloud/*)",
>       "Bash(curl * | bash)",
>       "Bash(curl * | sh)",
>       "Bash(wget * | bash)",
>       "Bash(wget * | sh)",
>       "Bash(docker system prune *)",
>       "Bash(docker rm -f *)",
>       "Bash(docker rmi -f *)",
>       "Bash(chmod 777 *)",
>       "Bash(chown *)",
>       "Bash(kubectl delete *)",
>       "Bash(terraform destroy *)"
>     ]
>   },
>   "env": {
>     "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
>   },
>   "sandbox": {
>     "enabled": true
>   },
>   "model": "claude-sonnet-4-20250514"
> }
> ```

### Tarea 1.2: Validar la política

Verifica que tu política es un JSON válido y cubre los requisitos:

```bash
# Validar JSON
python3 -c "import json; json.load(open('ejercicio-enterprise/etc/claude-code/managed-settings.json')); print('JSON válido')"

# Verificar que tiene las secciones necesarias
python3 -c "
import json
with open('ejercicio-enterprise/etc/claude-code/managed-settings.json') as f:
    data = json.load(f)

checks = {
    'Tiene permissions.allow': 'allow' in data.get('permissions', {}),
    'Tiene permissions.deny': 'deny' in data.get('permissions', {}),
    'Tiene env': 'env' in data,
    'Tiene model': 'model' in data,
    'Telemetría desactivada': data.get('env', {}).get('CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC') == '1',
    'Sandbox activado': data.get('sandbox', {}).get('enabled') is True,
    'Modelo es Sonnet': 'sonnet' in data.get('model', '').lower(),
}

for check, result in checks.items():
    status = 'PASS' if result else 'FAIL'
    print(f'  [{status}] {check}')
"
```

---

## Parte 2: Configurar settings compartido del equipo

### Escenario

El equipo necesita una configuración a nivel de proyecto (`.claude/settings.json`) que complemente la política gestionada con permisos específicos del proyecto.

### Tarea 2.1: Crear la configuración del proyecto

Crea `ejercicio-enterprise/proyecto/.claude/settings.json` con:

1. Permisos adicionales específicos del proyecto (comandos de build, migraciones, etc.)
2. Configuración de servidores MCP que usa el equipo
3. Hooks para automatizar linting post-edición

```bash
mkdir -p ejercicio-enterprise/proyecto/.claude/commands
```

> **Consejo:** Solución de referencia
>
> ```json
> {
>   "permissions": {
>     "allow": [
>       "Bash(python manage.py migrate *)",
>       "Bash(python manage.py makemigrations *)",
>       "Bash(python manage.py test *)",
>       "Bash(npm run build)",
>       "Bash(npm run dev)",
>       "Bash(go build ./...)",
>       "Bash(go vet ./...)"
>     ]
>   },
>   "mcpServers": {
>     "postgres-dev": {
>       "command": "mcp-server-postgres",
>       "args": ["--read-only"],
>       "env": {
>         "DATABASE_URL": "${DEV_DATABASE_URL}"
>       }
>     }
>   },
>   "hooks": {
>     "postToolUse": [
>       {
>         "matcher": "Write|Edit",
>         "command": "echo 'Archivo modificado: revisar cambios con git diff'"
>       }
>     ]
>   }
> }
> ```

### Tarea 2.2: Crear el CLAUDE.md del proyecto

Crea `ejercicio-enterprise/proyecto/CLAUDE.md` con las instrucciones para el equipo políglota:

El CLAUDE.md debe incluir:
- Descripción de la arquitectura (Python + TypeScript + Go)
- Convenciones de código para cada lenguaje
- Comandos esenciales
- Estructura de directorios
- Reglas de negocio del proyecto
- Instrucciones de seguridad (qué NO hacer)

> **Consejo:** Solución de referencia
>
> El CLAUDE.md del proyecto debe incluir:
>
> - **Arquitectura**: API principal (Python 3.12 / FastAPI en /api), Frontend (TypeScript / React 18 en /web), Microservicios (Go 1.22 en /services), PostgreSQL 16, RabbitMQ, Redis 7
> - **Convenciones Python** (/api): Black (88 chars), Ruff, type hints obligatorios, docstrings Google, pytest con fixtures en conftest.py
> - **Convenciones TypeScript** (/web): ESLint + Prettier, strict mode, componentes funcionales, Vitest + Testing Library, nunca usar `any`
> - **Convenciones Go** (/services): go fmt + golangci-lint, manejo de errores explícito, interfaces pequeñas
> - **Comandos esenciales**: `make dev`, `make test`, `make lint`, `make build`, `make migrate`
> - **Estructura de directorios**: /api/routes/, /api/services/, /api/models/, /web/src/pages/, /web/src/components/, /services/worker/, /services/notifier/
> - **Reglas de negocio**: autenticación JWT, roles (admin, manager, employee), PII, formato de respuesta {data, meta, errors}
> - **Seguridad**: no credenciales en código, no queries directas fuera de /api/services/, no exponer env vars, no instalar dependencias sin justificación

---

## Parte 3: Crear perfiles de permisos por rol

### Escenario

El equipo tiene diferentes roles con diferentes necesidades de acceso. Crea perfiles de permisos para cada rol.

### Tarea 3.1: Definir perfiles

Crea un archivo `ejercicio-enterprise/perfiles-permisos.json` que contenga perfiles para:

1. **Junior**: Solo lectura y tests. Sin escritura automática.
2. **Mid**: Lectura, tests, y escritura con aprobación.
3. **Senior**: Todo lo anterior más operaciones de infraestructura local.
4. **Lead**: Todo lo anterior más capacidad de usar Opus.

> **Consejo:** Solución de referencia
>
> ```json
> {
>   "perfiles": {
>     "junior": {
>       "descripcion": "Desarrollador junior - Solo lectura y tests",
>       "modo_recomendado": "plan",
>       "permissions": {
>         "allow": [
>           "Read", "Glob", "Grep",
>           "Bash(npm test *)", "Bash(pytest *)", "Bash(go test *)",
>           "Bash(git status)", "Bash(git diff *)", "Bash(git log *)"
>         ],
>         "deny": [
>           "Write", "Edit", "Bash(rm *)", "Bash(sudo *)",
>           "Bash(git push *)", "Bash(git commit *)", "Bash(docker *)"
>         ]
>       },
>       "notas": "Usar Plan mode exclusivamente."
>     },
>     "mid": {
>       "descripcion": "Desarrollador mid-level - Lectura, tests y escritura con aprobación",
>       "modo_recomendado": "normal",
>       "permissions": {
>         "allow": [
>           "Read", "Glob", "Grep", "Write", "Edit",
>           "Bash(npm test *)", "Bash(npm run lint *)", "Bash(npm run build)",
>           "Bash(pytest *)", "Bash(ruff *)", "Bash(go test *)",
>           "Bash(golangci-lint *)", "Bash(git *)", "Bash(make *)"
>         ],
>         "deny": [
>           "Bash(sudo *)", "Bash(rm -rf *)",
>           "Bash(docker system *)", "Bash(env)", "Bash(printenv)"
>         ]
>       },
>       "notas": "Modo normal con aprobación de cada acción."
>     },
>     "senior": {
>       "descripcion": "Desarrollador senior - Acceso ampliado",
>       "modo_recomendado": "normal con auto-accept selectivo",
>       "permissions": {
>         "allow": [
>           "Read", "Glob", "Grep", "Write", "Edit",
>           "Bash(npm *)", "Bash(pytest *)", "Bash(python *)", "Bash(go *)",
>           "Bash(git *)", "Bash(make *)",
>           "Bash(docker compose *)", "Bash(docker build *)", "Bash(docker run *)"
>         ],
>         "deny": [
>           "Bash(sudo *)", "Bash(rm -rf /)",
>           "Bash(docker system prune -a)",
>           "Bash(kubectl delete namespace *)", "Bash(terraform destroy *)"
>         ]
>       }
>     },
>     "lead": {
>       "descripcion": "Lead técnico - Acceso completo con Opus",
>       "modo_recomendado": "normal con auto-accept selectivo",
>       "model_override": "claude-opus-4-20250514",
>       "permissions": {
>         "allow": [
>           "Read", "Glob", "Grep", "Write", "Edit",
>           "Bash(npm *)", "Bash(pytest *)", "Bash(python *)", "Bash(go *)",
>           "Bash(git *)", "Bash(make *)", "Bash(docker *)",
>           "Bash(kubectl get *)", "Bash(kubectl describe *)", "Bash(kubectl logs *)"
>         ],
>         "deny": [
>           "Bash(sudo *)", "Bash(rm -rf /)",
>           "Bash(kubectl delete namespace prod*)", "Bash(terraform destroy *)"
>         ]
>       },
>       "budget_mensual_usd": 500
>     }
>   }
> }
> ```

### Tarea 3.2: Documentar cómo aplicar cada perfil

Para cada perfil, escribe el comando o configuración que un desarrollador usaría para aplicarlo. Por ejemplo:

```bash
# Perfil Junior: Siempre usar Plan mode
claude --plan

# Perfil Mid: Modo normal (por defecto)
claude

# Perfil Senior: Auto-accept para lectura y tests
claude --allowedTools "Read,Glob,Grep,Bash(npm test *),Bash(pytest *),Bash(go test *)"

# Perfil Lead: Auto-accept ampliado con Opus disponible
claude --allowedTools "Read,Glob,Grep,Bash(npm test *),Bash(pytest *),Bash(go test *),Bash(make *)"
# Y cambiar a Opus cuando sea necesario: /model claude-opus-4-20250514
```

---

## Parte 4: Crear guía de onboarding para un nuevo miembro

### Escenario

Un nuevo desarrollador mid-level se incorpora al equipo mañana. Necesitas una guía paso a paso que pueda seguir para estar operativo con Claude Code en su primer día.

### Tarea 4.1: Crear la guía de onboarding

Crea el archivo `ejercicio-enterprise/guia-onboarding-equipo.md` con:

1. **Prerrequisitos** (qué necesita tener instalado)
2. **Instalación y autenticación** (paso a paso)
3. **Configuración del proyecto** (clonar, variables de entorno)
4. **Primera sesión con Claude Code** (en Plan mode)
5. **Ejercicios de práctica** (3 tareas sencillas para practicar)
6. **Reglas del equipo** (qué hacer y qué no hacer)
7. **Recursos y soporte** (dónde pedir ayuda)

> **Consejo:** Solución de referencia
>
> La guía de onboarding debe incluir:
>
> - **Prerrequisitos**: Git con email corporativo, acceso al repo, cuenta Anthropic (Pro/Max/Teams/Enterprise), Docker Desktop
> - **Paso 1 - Instalación**: `curl -fsSL https://claude.ai/install.sh | bash` y verificar con `claude --version`
> - **Paso 2 - Autenticación**: ejecutar `claude` (primer uso guía el login en navegador)
> - **Paso 3 - Configurar proyecto**: clonar, copiar `.env.example`, rellenar secretos desde 1Password, `make dev`
> - **Paso 4 - Primera sesión**: arrancar en Plan mode (`/plan`), probar prompts exploratorios
> - **Paso 5 - Ejercicios**: explorar un módulo, planificar un cambio, ejecutar tests
> - **Reglas del equipo**: primera semana solo Plan mode, revisar `git diff`, Co-Authored-By, no credenciales en código
> - **Soporte**: canal Slack #claude-code-ayuda, lead técnico, documentación interna

---

## Entregable

Al finalizar este ejercicio deberás tener:

```
ejercicio-enterprise/
  etc/
    claude-code/
      settings.json           # Política gestionada
  proyecto/
    .claude/
      settings.json           # Configuración del proyecto
      commands/               # Directorio para skills
    CLAUDE.md                 # Instrucciones del equipo
  perfiles-permisos.json      # Perfiles por rol
  guia-onboarding-equipo.md   # Guía de onboarding
```

## Criterios de éxito

- [ ] La política gestionada es un JSON válido con permisos restrictivos
- [ ] La configuración del proyecto complementa (no duplica) la política gestionada
- [ ] El CLAUDE.md cubre arquitectura, convenciones y reglas de seguridad
- [ ] Los perfiles de permisos son apropiados para cada nivel de experiencia
- [ ] La guía de onboarding es clara y seguible por alguien sin experiencia previa
- [ ] Ninguno de los archivos contiene credenciales reales
