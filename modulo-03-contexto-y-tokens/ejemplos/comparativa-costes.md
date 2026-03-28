# Comparativa de Costes: Modelos y Escenarios

## Precios por Modelo

| Modelo | Input (1M tokens) | Output (1M tokens) | Cache read (90% off) |
|--------|-------------------|--------------------|--------------------|
| **Haiku 4.5** | $1.00 | $5.00 | $0.10 |
| **Sonnet 4.6** | $3.00 | $15.00 | $0.30 |
| **Opus 4.6** | $5.00 | $25.00 | $0.50 |

---

## Escenarios Tipicos por Rol

### Backend Developer - Dia Tipico

| Tarea | Modelo | Tokens in | Tokens out | Coste |
|-------|--------|-----------|-----------|-------|
| Bug fix endpoint | Sonnet | 15K | 3K | $0.09 |
| Implementar 2 endpoints | Sonnet | 40K | 15K | $0.35 |
| Tests unitarios | Sonnet | 20K | 8K | $0.18 |
| Code review (one-shot) | Sonnet | 10K | 2K | $0.06 |
| Commit messages (3x) | Haiku | 3K | 1K | $0.01 |
| **Total dia** | Mix | **88K** | **29K** | **$0.69** |

### Frontend Developer - Dia Tipico

| Tarea | Modelo | Tokens in | Tokens out | Coste |
|-------|--------|-----------|-----------|-------|
| Componente React nuevo | Sonnet | 25K | 10K | $0.23 |
| Estilos + responsive | Sonnet | 15K | 5K | $0.12 |
| Fix bug UI | Sonnet | 10K | 3K | $0.08 |
| Tests componentes | Sonnet | 20K | 8K | $0.18 |
| **Total dia** | Sonnet | **70K** | **26K** | **$0.61** |

### DevOps - Dia Tipico

| Tarea | Modelo | Tokens in | Tokens out | Coste |
|-------|--------|-----------|-----------|-------|
| Dockerfile multi-stage | Sonnet | 15K | 5K | $0.12 |
| GitHub Action CI/CD | Sonnet | 20K | 8K | $0.18 |
| Debug pipeline | Opus | 30K | 5K | $0.83 |
| Scripts automatizacion | Sonnet | 15K | 5K | $0.12 |
| **Total dia** | Mix | **80K** | **23K** | **$1.25** |

### QA Engineer - Dia Tipico

| Tarea | Modelo | Tokens in | Tokens out | Coste |
|-------|--------|-----------|-----------|-------|
| Generar test plan | Sonnet | 20K | 10K | $0.21 |
| Tests automatizados | Sonnet | 30K | 12K | $0.27 |
| Analisis de coverage | Sonnet | 15K | 3K | $0.09 |
| Bug reports | Haiku | 5K | 2K | $0.01 |
| **Total dia** | Mix | **70K** | **27K** | **$0.58** |

---

## Comparativa: Con vs Sin Optimizacion

### Developer promedio, 1 mes

| Escenario | Tokens/dia | Modelo | Coste/dia | Coste/mes (22 dias) |
|-----------|-----------|--------|----------|-------------------|
| Sin optimizar, Opus | 500K | Opus | $45.00 | $990.00 |
| Sin optimizar, Sonnet | 500K | Sonnet | $9.00 | $198.00 |
| Optimizado, Sonnet | 100K | Sonnet | $1.80 | $39.60 |
| Optimizado, Mix + cache | 100K | Mix | $0.70 | $15.40 |
| **Referencia**: Media real Anthropic | - | Sonnet | ~$6.00 | ~$132.00 |

### Equipo de 8 personas, 1 mes

| Escenario | Coste/mes |
|-----------|----------|
| Sin optimizar, Opus | $7,920 |
| Sin optimizar, Sonnet | $1,584 |
| Optimizado, Sonnet | $317 |
| Optimizado, Mix + cache | **$123** |

---

## Impacto del Prompt Caching

El caching reduce el coste de tokens de input repetidos en un 90%:

```
Sesion de 20 mensajes, Sonnet:

Sin cache:
  20 msgs * 5K tokens avg = 100K tokens input
  Coste input: 100K * $3/M = $0.30

Con cache:
  Msg 1: 5K full price = $0.015
  Msgs 2-20: 19 * 5K * 10% = 9.5K equivalente = $0.029
  Coste input: $0.044 (85% ahorro)
```

---

## Cuando Usar Cada Modelo

| Modelo | Usar cuando... | No usar cuando... |
|--------|---------------|-------------------|
| **Haiku** | Commit messages, formateo, tareas simples | Debugging complejo, arquitectura |
| **Sonnet** | Desarrollo diario, tests, features | Decisiones arquitectonicas criticas |
| **Opus** | Planificacion, debug multi-archivo, logica compleja | Tareas rutinarias, ediciones simples |

### Alias opusplan

```bash
claude --model opusplan
# Usa Opus para planificar, Sonnet para ejecutar
# Mejor relacion calidad/precio para tareas grandes
```

---

## Calculadora Rapida

```
Tu coste estimado = (tokens_input * precio_input + tokens_output * precio_output) * (1 - %_cache)

Ejemplo con Sonnet, 80% cache:
  (100K * $3/M + 30K * $15/M) * (1 - 0.8*0.9)
  = ($0.30 + $0.45) * 0.28
  = $0.21 por sesion
```
