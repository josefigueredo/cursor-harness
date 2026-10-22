# cursor-harness

Objetivo: que Cursor se comporte como nuestro Claude Code, sobre todo en la **iniciativa**: que no solo responda, sino
que traiga propuestas.

## Archivos

| Archivo | Qué es |
|---|---|
| `user-rules.txt` | Texto de la User Rule global de Cursor (texto plano, sin frontmatter): persona, evidencia, contrato de iniciativa y protocolo corto de Engram. En Cursor 2026.10 se crea en **Customize**, no en Settings → Rules. |
| `pruebas.md` | Dos pruebas: qué reglas carga Cursor, y una A/B (Claude Code / Cursor+Claude / Cursor+GPT) con puntaje de 0 a 5 para saber si la iniciativa la da el prompt o el modelo. |
| `fix-claude-noise.sh` | Limpieza ya aplicada en Claude Code el 2026-10-22: un solo output style (Gentleman), el bloque de Engram sin duplicar, superpowers acotado y sin atribución en commits ni PR. Hace backup antes de tocar nada. |

## Lo medido (2026-10-21/22)

- La persona Gentleman viene de `gentle-ai 3.7.0`. En Claude Code entra por `~/.claude/output-styles/gentleman.md`,
  por `~/.claude/CLAUDE.md` y por los hooks de los plugins.
- En Cursor, las User Rules estaban vacías (`aicontext.personalContext` mide 0 en `state.vscdb`).
  `~/.cursor/rules/gentle-ai.mdc` no tiene frontmatter. Según el foro de Cursor, esa carpeta no es global
  ([hilo](https://forum.cursor.com/t/user-rules-are-not-recognized-from-folder-cursor-rules/144739/5)).
  Inferencia: Gentleman nunca estuvo activo en Cursor.
- Engram sí está conectado como MCP en `~/.cursor/mcp.json`, pero sin el protocolo de uso.
- Codex tiene Gentleman en `~/.codex/agents.md` y aun así no muestra iniciativa. Inferencia: el modelo pesa tanto
  como el prompt; la A/B de `pruebas.md` es la que lo confirma o lo descarta.

- La User Rule se creó desde Customize el 2026-10-22. El texto no aparece en disco: ni en `state.vscdb`
  (`aicontext.personalContext` sigue en 0), ni en `~/.cursor`, ni en `~/Library/Application Support/Cursor/User`.
  Inferencia: se guarda en la cuenta, del lado del servidor. Por eso no se puede instalar escribiendo archivos;
  se verifica con la prueba 1 de `pruebas.md`.

## Pendiente

1. ~~Pegar `user-rules.txt` en las User Rules de Cursor.~~ Hecho el 2026-10-22, desde Customize.
2. ~~Correr las dos pruebas de `pruebas.md`.~~ Hecho el 2026-10-22: `resultados/2026-10-22/README.md`. La regla está
   activa, y el contrato de iniciativa hace que propongan tanto Sonnet como Codex. La calidad de la propuesta depende del modelo.
3. Si las User Rules funcionan, borrar `~/.cursor/rules/gentle-ai.mdc`, que es código muerto.
