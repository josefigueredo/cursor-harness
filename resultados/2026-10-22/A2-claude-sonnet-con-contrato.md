`ric.py hook` es el callback que Cursor llama al terminar cada turno (`stop`) y al cerrar la sesión (`sessionEnd`). Anota qué pasó en un log, y solo cuando la sesión la lanzó `ric run`.

## Cómo funciona

1. **Registro.** `ric install-hook` agrega `<python> …/ric.py hook` a `stop` y `sessionEnd` en `~/.cursor/hooks.json` (`ric/hook.py:54-68`, `ric/cli.py:75-77`). Se une a lo que ya hay y no duplica. Lo reconoce por el nombre de archivo `ric.py`, así que `fabric.py hook` no cuenta (`hook.py:39-46`).

2. **Ejecución.** `ric run` arranca `cursor-agent` en tmux con `RUN_IN_CURSOR_LOG=<ruta>` en el entorno (`ric/session.py:131`). Cursor llama al hook con un JSON por stdin, y `cli.py:68-70` lo pasa a `hook.record(...)`.

3. **Qué guarda.** `record` agrega una línea JSONL con `event`, `status`, `model`, `input_tokens`, `output_tokens`, `reason` y `t` (`hook.py:15-22`). No guarda el prompt ni los archivos (`hook.py:3-5`).

4. **Cuándo no hace nada.** Si `RUN_IN_CURSOR_LOG` no está definida, sale sin escribir (`hook.py:20-21`). Como el hook es global y corre en todos los proyectos de Cursor, las sesiones normales no se tocan.

5. **Nunca falla.** Responde `{}` y se traga los `OSError` (`hook.py:28-29`, `cli.py:68`), porque un hook roto se vería en cada turno.

## Quién lee ese log

`ric/session.py` lo lee para saber cuándo terminó un turno. Si aparece una línea `stop` nueva, el turno terminó (`session.py:8`, `_stops` en `:67-68`, `_wait` en `:94-100`). `sessionEnd` confirma que la sesión se cerró (`:198`). El log queda en `<workspace>/.run-in-cursor/runs/<name>.jsonl` (`:51-52`).

Por eso `ric run` se niega a arrancar si el hook no está instalado (`cli.py:116-118`). Sin el hook ningún turno avisaría su fin, y esperarías hasta el timeout.

Esto conecta con la regla del repo: `cursor-agent -p` no dispara estos hooks. Por eso `ric` nunca usa `-p` (`cli.py:1`).

## Próximos pasos

Todo lo anterior sale de leer el código. No corrí `ric install-hook` ni una sesión real. **Recomendado:** medir el contrato con un payload de `stop` verdadero. Corré `echo '{"hook_event_name":"stop","status":"completed","model":"x"}' | RUN_IN_CURSOR_LOG=/tmp/ric-test/t.jsonl python3 Harness/run-in-cursor/ric.py hook` y mirá que `/tmp/ric-test/t.jsonl` tenga una línea. Así verificás que los nombres de campos (`KEEP`) coinciden con lo que manda Cursor. Si Cursor cambia `input_tokens` por otro nombre, el hook lo guardaría como `null` sin avisar.
