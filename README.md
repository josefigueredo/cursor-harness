# cursor-harness

Objetivo: que Cursor se comporte como nuestro Claude Code, sobre todo en la **iniciativa**: que no solo responda, sino
que traiga propuestas.

## Archivos

| Archivo | Qué es |
|---|---|
| `user-rules.txt` | Texto para Cursor → Settings → Rules → User Rules (la única entrada global; va en texto plano, sin frontmatter). Persona, evidencia, contrato de iniciativa y protocolo corto de Engram. |
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

## Pendiente

1. Pegar `user-rules.txt` en las User Rules de Cursor.
2. Cuando se renueve la cuota de Cursor (el 2026-10-22 dio *monthly usage limit*), correr las dos pruebas de `pruebas.md`.
3. Si las User Rules funcionan, borrar `~/.cursor/rules/gentle-ai.mdc`, que es código muerto.
