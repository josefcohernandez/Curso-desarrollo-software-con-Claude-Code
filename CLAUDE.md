# Curso-desarrollo-software-con-Claude-Code

<!-- Este fichero se carga en cada sesión: solo lo que Claude no puede deducir del código.
     Menos de 200 líneas. Cada línea pasa la prueba "si la quito, ¿se equivocaría?". -->

Proceso: metodología común (`~/.claude/metodologia/METODOLOGIA.md`). Todo entra por PR desde un
worktree (`flujo abrir <issue>`), con título `tipo: descripción` en español. Un refresco del curso
es `docs(vX.Y): …` (no `refresh(vX.Y): …`, que la CI rechaza).

## Qué es

Curso en español de desarrollo asistido con Claude Code (17 módulos, solo Markdown y ejemplos).
Es un submódulo del monorepo `cursos-libros-ia`, que lo usa para generar el libro.

## Comandos

- Verificación completa (la misma que la CI): `scripts/check.sh`
- Validar un módulo: `python3 test-modules.py --module 08` (número con dos cifras; `--verbose`
  para detalle)

## Gotchas

- `README.md` es la fuente de verdad estructural (módulos, títulos, duraciones). Si cambias un
  módulo, actualiza su `README.md` y el índice; el temario detallado `CURSO_CLAUDE_CODE.md` y el
  libro viven en el monorepo padre (de ahí el enlace `../CURSO_CLAUDE_CODE.md`).
- `test-modules.py` tiene la lista de módulos anterior a la estructura de 17 (llega a M16
  proyecto final) y su pasada completa falla; `scripts/check.sh` solo ejecuta M01-M15.
- Los tags `v1.0` y `v2.0` son antiguos (no siguen `vX.Y.Z`): no se tocan y `release.yml` los
  ignora al calcular la última versión.

## Decisiones vigentes

<!-- Una línea por ADR: - [0001 · Título](docs/adr/0001-titulo.md): resumen en una frase. -->

- **Versiones = edición del curso.** Las releases `vX.Y.Z` (las crea la CI con `flujo publicar`)
  siguen la edición: mayor.menor = edición del README (ahora la 3.9), patch = correcciones sin
  edición nueva. La primera release será `v3.9.0`; una edición nueva sube la menor (o la mayor).
