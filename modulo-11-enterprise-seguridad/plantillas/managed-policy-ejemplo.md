# Plantilla: Managed Policy para Enterprise

> Los administradores colocan este archivo en `~/.claude/managed/settings.json`
> de las maquinas de los desarrolladores. Los usuarios NO pueden sobreescribirlo.

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
    "DISABLE_NONESSENTIAL_TRAFFIC": "1"
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
    "DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

## Como Desplegar

### Opcion 1: Script de aprovisionamiento

```bash
#!/bin/bash
# deploy-managed-policy.sh
MANAGED_DIR="$HOME/.claude/managed"
mkdir -p "$MANAGED_DIR"
curl -s https://internal.company.com/claude-policy.json > "$MANAGED_DIR/settings.json"
chmod 444 "$MANAGED_DIR/settings.json"  # Solo lectura
```

### Opcion 2: Ansible/Chef/Puppet

```yaml
# Ansible playbook
- name: Deploy Claude Code managed policy
  copy:
    src: claude-managed-settings.json
    dest: "{{ ansible_env.HOME }}/.claude/managed/settings.json"
    mode: '0444'
    owner: "{{ ansible_user }}"
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
