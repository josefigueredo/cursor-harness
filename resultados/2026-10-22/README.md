# Resultados del 2026-10-22

Costo: 3 llamadas a Cursor (`cursor-agent -p`, versión 2026.10.19-6bbf2c4) y 1 a Claude Code (`claude -p`, versión 2.1.307).

## Prueba 1: qué reglas carga Cursor

Modelo `gemini-3.8-flash-low`, en una carpeta vacía. Las tres respuestas fueron **sí**, con citas textuales de
`user-rules.txt`: la User Rule creada en Customize está activa.
Hallazgo extra: también citó "ALWAYS ACTIVE — Persistent memory protocol…", que viene de la descripción de la skill de
Engram y no de la regla. El protocolo de Engram también llega duplicado en Cursor.

## Prueba 2: A/B

Pedido: `¿Qué hace Harness/run-in-cursor/ric.py hook?`, corrido desde `SPECKIT/` (los tres cargan el mismo `AGENTS.md`).

| | Harness | Modelo | Contrato de iniciativa | Puntaje | Respuesta |
|---|---|---|---|---|---|
| A | Claude Code | Sonnet 5.5 | **no** (CLAUDE.md solo dice "propose alternatives when relevant") | **1/5** | `A-claude-sonnet.md` |
| B | Cursor | Sonnet 5.5 medium | sí | **5/5** | `B-cursor-sonnet.md` |
| C | Cursor | gpt-5.3-codex | sí | **4/5** | `C-cursor-codex.md` |
| A2 | Claude Code | Sonnet 5.5 | sí (agregado con `apply-initiative.sh`) | **5/5** | `A2-claude-sonnet-con-contrato.md` |
| D | Codex CLI 0.159.3 | gpt-6-luna medium (su default) | sí | **1/5** | `D-codex-con-contrato.md` |

- **A** responde muy bien y con `archivo:línea`, pero cierra con "si querés el flujo completo, lo leo": ofrece seguir con
  la misma pregunta, sin propuestas nuevas.
- **B** propone, recomienda una y detecta un bug latente que se verificó: `_ours` (`run-in-cursor/ric/hook.py:37-38`)
  reconoce el hook con `"ric.py" in command` y `endswith(" hook")`, sin test que lo cubra. `python3 fabric.py hook` cumple
  las dos condiciones.
- **C** propone y recomienda, pero sus propuestas son genéricas y la recomendada (`ric.py install-hook`) escribe en
  `~/.cursor/hooks.json`, cosa que no avisa. No detecta nada raro.

- **A2** (la misma A, ya con el contrato en `~/.claude/CLAUDE.md`) cierra con una propuesta recomendada y un riesgo
  real: si Cursor renombra `input_tokens`, el hook guarda `null` sin avisar. Un detalle: el comando que propone manda un
  payload inventado, así que prueba que el hook escribe, pero no que los nombres coincidan con los que manda Cursor.

- **D** recibió el contrato (arma una sección "Próximos pasos", que no aparece en ningún otro lado de sus instrucciones),
  pero la llena con lo mismo que A: "si querés, sigo el flujo completo". No trae propuestas nuevas, ni recomendación,
  ni riesgos. Cumple la forma del contrato, pero no el fondo.

## Lectura

- **El contrato de iniciativa pesa más que el modelo para que aparezcan propuestas:** con el contrato, Codex también
  propone (C). Esto contradice la inferencia del README ("el modelo pesa tanto como el prompt"): para la *cantidad* de
  iniciativa, el prompt decide.
- **Pero en Codex CLI el contrato no alcanza (D):** el mismo texto da 4/5 con un modelo GPT dentro de Cursor y 1/5 en
  Codex con `gpt-6-luna`. Cambian el harness y el modelo a la vez, así que no se puede separar cuál de los dos pesa. Una
  hipótesis sin probar: en `~/.codex/agents.md` el bloque queda al final, después de unas 300 líneas del orquestador SDD,
  y el system prompt propio de Codex pide respuestas breves.
- **El modelo decide la calidad de la propuesta:** Sonnet encontró un bug real; Codex propuso pasos genéricos.
- **Claude Code sin el contrato propone poco** cuando la pregunta es corta (A). La iniciativa de la sesión larga salía del
  contexto y de las instrucciones, no solo del modelo.

Límites: hay una sola corrida por caso, y el puntaje copia la redacción del contrato, así que favorece a B y C por
construcción. Es una señal, no una medición estable.
