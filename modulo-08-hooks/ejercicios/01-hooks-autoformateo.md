# Ejercicio 01: Hooks de Auto-Formateo y Tests

## Objetivo

Configurar hooks que auto-formateen codigo y ejecuten tests automaticamente.

---

## Preparacion

```bash
mkdir -p ~/hooks-exercise && cd ~/hooks-exercise
npm init -y
npm install --save-dev prettier eslint
mkdir -p src tests .claude
```

Crea `src/example.js`:

```javascript
function    add(a,b){return a+b}
function subtract(a, b) {
return a -b
}
```

---

## Parte 1: Hook de Auto-Formateo (10 min)

Crea `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.{js,ts,json,md})",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $FILEPATH 2>/dev/null || true"
          }
        ]
      },
      {
        "matcher": "Edit(*.{js,ts,json,md})",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $FILEPATH 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

Crea `.prettierrc`:

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
```

### Verificar

```bash
claude
> "Modifica src/example.js: anade una funcion multiply(a, b)"
```

Despues de que Claude edite, verifica que Prettier formateo el archivo.

---

## Parte 2: Hook de Tests Automaticos (10 min)

Crea `tests/example.test.js`:

```javascript
const { add, subtract } = require('../src/example');

test('add', () => {
  expect(add(2, 3)).toBe(5);
});

test('subtract', () => {
  expect(subtract(5, 3)).toBe(2);
});
```

```bash
npm install --save-dev jest
```

Anade al `package.json`: `"scripts": { "test": "jest" }`

Actualiza `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.{js,ts,json,md})",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $FILEPATH 2>/dev/null || true"
          }
        ]
      },
      {
        "matcher": "Edit(src/**/*.js)",
        "hooks": [
          {
            "type": "command",
            "command": "npm test 2>&1 | tail -20"
          }
        ]
      }
    ]
  }
}
```

### Verificar

```bash
claude
> "Anade una funcion divide(a, b) a src/example.js que maneje division por cero"
```

Despues de editar, el hook ejecuta los tests.

---

## Parte 3: Verificar /hooks (5 min)

```bash
claude
> /hooks    # Verificar hooks activos
```

---

## Criterios de Completitud

- [ ] Hook Prettier configurado y funcionando
- [ ] Archivos se auto-formatean despues de Write/Edit
- [ ] Hook de tests configurado
- [ ] Tests se ejecutan despues de editar src/
- [ ] /hooks muestra hooks correctos
