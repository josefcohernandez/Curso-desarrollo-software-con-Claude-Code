# Ejercicio 01: Instalacion y Primer Uso

## Objetivo

Instalar Claude Code, verificar su funcionamiento y ejecutar tu primera sesion interactiva.

---

## Parte 1: Instalacion (5 min)

### Paso 1: Verificar prerequisitos

```bash
git --version     # Necesario en todas las plataformas
```

En Windows, asegurate de tener [Git for Windows](https://git-scm.com/downloads/win) instalado.

> [!NOTE]
> Node.js ya no es necesario. El instalador nativo de Claude Code es autocontenido.

### Paso 2: Instalar Claude Code (instalador nativo)

**macOS / Linux / WSL:**

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows PowerShell:**

```powershell
irm https://claude.ai/install.ps1 | iex
```

**Windows CMD:**

```batch
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

**Alternativa con Homebrew (macOS/Linux):**

```bash
brew install --cask claude-code
```

### Paso 3: Verificar

```bash
claude --version
claude doctor
```

**Checkpoint**: `claude --version` muestra la version instalada y `claude doctor` no reporta errores criticos.

---

## Parte 2: Autenticacion (5 min)

```bash
claude
```

En el primer uso, Claude Code abre automaticamente el navegador para que te autentiques con tu cuenta de Anthropic (Pro, Max, Teams o Enterprise). Sigue las instrucciones en pantalla.

Una vez autenticado, veras el prompt interactivo de Claude Code.

> [!IMPORTANT]
> El plan gratuito de Claude.ai no incluye acceso a Claude Code. Necesitas una suscripcion de pago o una cuenta Console.

---

## Parte 3: Primer Uso - Modo One-Shot (10 min)

Sal de la sesion interactiva (`/exit`) y ejecuta estos comandos:

```bash
# Pregunta simple
claude -p "Que es una API REST? Responde en 2 frases."

# Generar codigo
claude -p "Genera una funcion Python que calcule el factorial de un numero"

# Analizar un archivo (si tienes uno)
claude -p "Explica que hace este archivo" < algun-archivo.py
```

**Observa**:
- Tiempo de respuesta
- Formato de la salida
- El modelo usado (por defecto Sonnet)

---

## Parte 4: Primera Sesion Interactiva (15 min)

```bash
# Crear proyecto de prueba
mkdir -p ~/mi-primer-proyecto && cd ~/mi-primer-proyecto
git init
echo "# Mi Primer Proyecto" > README.md

# Iniciar Claude Code
claude
```

Dentro de la sesion interactiva, prueba:

1. **Inicializar el proyecto**: `/init`
2. **Ver ayuda**: `/help`
3. **Preguntar sobre el proyecto**: "Que archivos hay en este proyecto?"
4. **Crear un archivo**: "Crea un archivo `hello.py` con un hola mundo"
5. **Ver costes**: `/cost`
6. **Limpiar**: `/clear`
7. **Salir**: `/exit`

---

## Parte 5: Explorar Slash Commands (10 min)

En una sesion interactiva, prueba estos comandos:

| Comando | Que hace |
|---------|---------|
| `/help` | Lista de comandos disponibles |
| `/model` | Ver/cambiar modelo |
| `/cost` | Ver consumo de tokens |
| `/clear` | Limpiar contexto |
| `/compact` | Compactar conversacion |
| `/doctor` | Diagnostico |
| `/permissions` | Ver permisos actuales |
| `/init` | Crear CLAUDE.md |

---

## Criterios de Completitud

- [ ] Claude Code instalado con el instalador nativo y version verificada
- [ ] Autenticacion configurada (primer login en navegador completado)
- [ ] `claude doctor` sin errores
- [ ] Ejecutada al menos una consulta one-shot
- [ ] Sesion interactiva completada
- [ ] Al menos 5 slash commands probados
- [ ] `/cost` revisado para entender el consumo

---

## Reflexion

Responde mentalmente:
1. Cuanto tardo la instalacion completa?
2. Que diferencia hay entre modo one-shot y sesion interactiva?
3. Cuantos tokens consumiste en esta sesion de prueba?
