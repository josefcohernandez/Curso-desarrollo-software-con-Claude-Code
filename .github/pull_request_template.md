<!-- El título del PR es el commit que queda en main: `tipo: descripción en español`
     (feat, fix, docs, refactor, test, chore, ci, perf, build, revert; `!` si rompe algo). -->

## Qué y por qué

Closes #

## Cómo se ha probado

<!-- Comandos ejecutados y su resultado. Si es instalable: probado en dev con el bundle local. -->

## Checklist

- [ ] El diff hace solo lo que pide la issue (≤ ~400 líneas efectivas, o justificado aquí).
- [ ] `scripts/check.sh` pasa en local.
- [ ] CHANGELOG.md: línea añadida en *Unreleased* (si el cambio lo nota quien usa o instala).
- [ ] Migraciones idempotentes y solo hacia delante; variables nuevas en `.env.example`.
- [ ] Sin secretos, sin `:latest`, sin `build:` en `deploy/compose.yml`.
- [ ] Documentación al día (README, CLAUDE.md, spec o ADR si aplica).
