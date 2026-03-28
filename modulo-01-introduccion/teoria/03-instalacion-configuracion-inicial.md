# Instalación y Configuración Inicial de Claude Code

Este apartado cubre la instalación de Claude Code, la configuración de la autenticación y la verificación del entorno en los tres sistemas operativos principales.

---

## 1. Requisitos del sistema

| Requisito | Detalle | Notas |
|-----------|---------|-------|
| **Sistema operativo** | macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+ | Windows funciona nativo (no requiere WSL) |
| **RAM** | 4 GB mínimo | |
| **Shell** | Bash, Zsh, PowerShell o CMD | En Windows se requiere Git for Windows |
| **Git** | Cualquier versión reciente | En Windows: [Git for Windows](https://git-scm.com/downloads/win) |
| **Conexión a internet** | Necesaria | Para la API de Anthropic |
| **Cuenta** | Pro, Max, Teams, Enterprise o Console | El plan gratuito de Claude.ai no incluye Claude Code |

> [!IMPORTANT]
> **Node.js ya no es necesario**. La instalación nativa es el método recomendado. No requiere Node.js, npm ni ninguna dependencia externa. La instalación vía npm sigue siendo válida como alternativa.

---

## 2. Instalación de Claude Code

### Método recomendado: Instalador nativo

El instalador nativo es un binario autocontenido que no requiere dependencias, se actualiza automáticamente en segundo plano y es más rápido que la versión npm.

**macOS, Linux, WSL:**

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

### Métodos alternativos

**Homebrew (macOS/Linux):**

```bash
brew install --cask claude-code
```

> [!NOTE]
> Las instalaciones con Homebrew no se actualizan automáticamente. Ejecuta `brew upgrade claude-code` periódicamente.

**WinGet (Windows):**

```powershell
winget install Anthropic.ClaudeCode
```

### Migración desde npm

Si tenías Claude Code instalado con npm, migra al instalador nativo:

```bash
# Instalar la versión nativa
curl -fsSL https://claude.ai/install.sh | bash

# Eliminar la versión npm antigua
npm uninstall -g @anthropic-ai/claude-code
```

### Verificar la instalación

```bash
claude --version
claude doctor
```

`claude doctor` verifica: autenticación, conectividad API, permisos y git.

---

## 3. Autenticación

### Opción A: Cuenta de claude.ai (recomendado)

```bash
claude
# En el primer uso se abre el navegador para autenticarte
```

No es necesario ejecutar ningún comando de autenticación aparte. Al iniciar `claude` por primera vez, te guía automáticamente por el proceso de login en el navegador.

### Opción B: API Key directa

```bash
export ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxxx"
# Persistente:
echo 'export ANTHROPIC_API_KEY="sk-ant-xxx"' >> ~/.bashrc
```

### Opción C: Amazon Bedrock (enterprise)

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export AWS_PROFILE=mi-perfil-bedrock
```

### Opción D: Google Vertex AI (enterprise)

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=tu-proyecto-gcp
```

| Método | Ideal para | Requiere |
|--------|-----------|----------|
| claude.ai | Uso personal, equipos pequeños | Cuenta Pro/Max/Teams/Enterprise |
| API Key | Automatización, CI/CD | API key de Console |
| Bedrock | Empresas AWS | Cuenta AWS + Bedrock habilitado |
| Vertex AI | Empresas GCP | Proyecto GCP + Vertex habilitado |

---

## 4. Compatibilidad por plataforma

### macOS

Funciona nativo. Mejor soporte. El binario está firmado por "Anthropic PBC" y notarizado por Apple.

### Linux

Funciona nativo. En Alpine Linux u otras distribuciones basadas en musl, se necesitan paquetes adicionales:

```bash
apk add libgcc libstdc++ ripgrep
```

### Windows

Claude Code funciona de forma nativa en Windows con Git for Windows (ya no requiere WSL). Se puede ejecutar desde PowerShell, CMD o Git Bash.

**Requisito:** instalar [Git for Windows](https://git-scm.com/downloads/win) antes de instalar Claude Code.

Si Claude Code no encuentra tu instalación de Git Bash, configura la ruta en `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```

**WSL** también es compatible (WSL 1 y WSL 2). WSL 2 soporta sandboxing para mayor seguridad.

---

## 5. Integración con IDEs

### VS Code / Cursor

```bash
# VS Code
code --install-extension anthropic.claude-code
# Cursor
cursor --install-extension anthropic.claude-code
```

O buscar "Claude Code" en Extensions (`Cmd+Shift+X` / `Ctrl+Shift+X`).

### JetBrains (IntelliJ, PyCharm, WebStorm)

Settings > Plugins > Marketplace > "Claude Code"

### Desktop App

Aplicación independiente para usar Claude Code fuera del terminal o IDE:
- [macOS](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect) (Intel y Apple Silicon)
- [Windows](https://claude.ai/api/desktop/win32/x64/exe/latest/redirect) (x64)

### Terminal independiente

```bash
cd /ruta/a/tu/proyecto && claude
```

---

## 6. Configuración inicial recomendada

```bash
cd /ruta/a/tu/proyecto
claude
# Dentro de la sesión:
/init          # Crear CLAUDE.md
/model         # Ver modelo actual
/doctor        # Verificar estado
```

### Actualizaciones

Las instalaciones nativas se actualizan automáticamente en segundo plano. Puedes configurar el canal de actualización:

- `"latest"` (por defecto): recibe nuevas versiones de inmediato
- `"stable"`: usa versiones con ~1 semana de antigüedad, evitando regresiones recientes

Para forzar una actualización inmediata:

```bash
claude update
```

### Variables de entorno útiles

| Variable | Propósito | Ejemplo |
|----------|----------|---------|
| `ANTHROPIC_API_KEY` | API key | `sk-ant-xxx` |
| `ANTHROPIC_MODEL` | Modelo por defecto | `claude-sonnet-4-6` |
| `HTTP_PROXY` | Proxy corporativo | `http://proxy:8080` |
| `CLAUDE_CODE_USE_BEDROCK` | Usar Bedrock | `1` |
| `DISABLE_AUTOUPDATER` | Desactivar auto-actualización | `1` |

---

## 7. Troubleshooting

| Problema | Solución |
|----------|---------|
| Instalador nativo falla en Alpine | `apk add libgcc libstdc++ ripgrep` |
| Claude Code no encuentra Git Bash (Windows) | Configurar `CLAUDE_CODE_GIT_BASH_PATH` en settings.json |
| ECONNREFUSED/ETIMEDOUT | Configurar `HTTP_PROXY`/`HTTPS_PROXY` |
| git not available | `sudo apt install git` (Linux) o instalar Git for Windows |
| Auth falla | Ejecutar `claude` de nuevo para re-autenticar |
| Tengo la versión npm antigua | Migrar: `curl -fsSL https://claude.ai/install.sh \| bash && npm uninstall -g @anthropic-ai/claude-code` |

---

## Resumen

| Paso | Comando | Verificación |
|------|---------|-------------|
| 1. Instalar | `curl -fsSL https://claude.ai/install.sh \| bash` | `claude --version` |
| 2. Autenticarse | `claude` (primer uso guía el login) | `claude doctor` |
| 3. Probar | `claude -p "hola"` | Respuesta exitosa |
| 4. Iniciar | `cd proyecto && claude` | Sesión interactiva |
