# Ejercicio 03: Agent Teams

## Objetivo

Experimentar con Agent Teams para trabajo paralelo entre múltiples agentes.

---

## Prerrequisitos

- Claude Code v1.0.20+
- Familiaridad con subagentes (Ejercicio 01)

---

## Parte 1: Habilitar Agent Teams (5 min)

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
claude
```

---

## Parte 2: Definir Teammates (10 min)

Crea `.claude/agents/frontend-dev.md`:

```markdown
# Frontend Developer
Especializado en React/TypeScript.
Solo modifica archivos en src/frontend/ y src/components/.
Escribe tests con Vitest.
```

Crea `.claude/agents/backend-dev.md`:

```markdown
# Backend Developer
Especializado en Python/FastAPI.
Solo modifica archivos en src/api/ y src/services/.
Escribe tests con pytest.
```

---

## Parte 3: Tarea Paralela (15 min)

```bash
claude
> "Implementa un dashboard de estadísticas:
>  - Backend: endpoint GET /api/stats con conteo de tareas por estado
>  - Frontend: componente Dashboard.tsx que consuma el endpoint
>  Usa los teammates frontend-dev y backend-dev"
```

Durante la ejecución, presta atención a:
- Cómo se dividen las tareas entre teammates
- Comunicación entre teammates a través del mailbox
- Evolución de la lista de tareas compartida

---

## Parte 4: Análisis de Costes (5 min)

```
/cost
```

Compara con hacer la misma tarea secuencialmente (sin teams).

| Métrica | Con Teams | Sin Teams |
|---------|----------|----------|
| Tokens totales | ? | ? |
| Coste | ? | ? |
| Tiempo | ? | ? |

---

## Parte 5: Reflexión

1. ¿Cuándo vale la pena el coste extra (~7x) de Agent Teams?
2. ¿Qué tipo de tareas se benefician del paralelismo?
3. ¿Hubo problemas de coordinación entre teammates?

---

## Criterios de Completitud

- [ ] Agent Teams habilitado
- [ ] 2 teammates definidos
- [ ] Tarea ejecutada con ambos teammates
- [ ] Costes medidos y comparados
- [ ] Reflexión documentada
