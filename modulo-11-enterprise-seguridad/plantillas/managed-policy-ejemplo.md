# Plantilla: Managed Policy para Enterprise

> Los administradores colocan este archivo en la ruta de managed settings del sistema operativo:
> - Linux/WSL: `/etc/claude-code/managed-settings.json`
> - macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
> - Windows: `C:\Program Files\ClaudeCode\managed-settings.json`
>
> Este archivo requiere permisos de administrador y los usuarios NO pueden sobreescribirlo.

## Politica Restrictiva (Produccion/Regulado)

```json
{
  "_comment": "Managed policy - Solo modificable por administradores",

  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(rm -r *)",
      "Bash(sudo *)",
      "Bash(chmod 777 *)",
      "Bash(curl * | bash)",
      "Bash(curl * | sh)",
      "Bash(wget * | bash)",
      "Bash(npm publish*)",
      "Bash(pip install --user*)",
      "Bash(apt install*)",
      "Bash(brew install*)",
      "Write(.env*)",
      "Write(*secret*)",
      "Write(*credential*)",
      "Write(*password*)",
      "Edit(.env*)",
      "Edit(*secret*)"
    ]
  },

  "env": {
    "ANTHROPIC_MODEL": "claude-sonnet-4-6",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

## Politica Moderada (Desarrollo Corporativo)

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf /)",
      "Bash(rm -rf /*)",
      "Bash(sudo *)",
      "Bash(npm publish*)",
      "Bash(curl * | bash)",
      "Write(.env.production)",
      "Write(*secret*)"
    ]
  },

  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

## Como Desplegar

### Opcion 1: Script de aprovisionamiento (Linux/WSL)

```bash
#!/bin/bash
# deploy-managed-policy.sh
MANAGED_DIR="/etc/claude-code"
sudo mkdir -p "$MANAGED_DIR"
sudo curl -s https://internal.company.com/claude-policy.json > /tmp/managed-settings.json
sudo mv /tmp/managed-settings.json "$MANAGED_DIR/managed-settings.json"
sudo chmod 444 "$MANAGED_DIR/managed-settings.json"  # Solo lectura
sudo chown root:root "$MANAGED_DIR/managed-settings.json"
```

### Opcion 2: Ansible/Chef/Puppet

```yaml
# Ansible playbook (Linux/WSL)
- name: Deploy Claude Code managed policy
  copy:
    src: claude-managed-settings.json
    dest: /etc/claude-code/managed-settings.json
    mode: '0444'
    owner: root
    group: root
  become: true

# Para macOS, cambiar dest a:
# /Library/Application Support/ClaudeCode/managed-settings.json
```

### Opcion 3: MDM (macOS)

Distribuir via perfil de configuracion MDM.

## Verificacion

Los desarrolladores pueden ver la politica activa pero no modificarla:

```bash
claude
> /permissions    # Muestra permisos incluyendo managed
> /config         # Muestra configuracion completa
```

Los deny de managed **siempre ganan** sobre cualquier otro nivel.
