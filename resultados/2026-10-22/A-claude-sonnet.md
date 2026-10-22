Permission allow rule (../../.claude/settings.json): Write(/Users/josefigueredo/CurrentCode/iris-group/iris-v2/tests/fixtures/curation/**) is not matched by file permission checks — only Edit(path) rules are. Use Edit(/Users/josefigueredo/CurrentCode/iris-group/iris-v2/tests/fixtures/curation/**) instead (Edit rules cover all file-editing tools).
`ric.py hook` es el callback que Cursor llama cuando termina un turno. No lo corrés vos a mano.

Un detalle de dónde está el código, para que no te confundas: `ric.py` son 10 líneas que le pasan el control a `ric.cli.main`. El subcomando está en `ric/cli.py:65` y `ric/cli.py:68-74`, y la lógica de grabación está en `ric/hook.py`.

**Qué hace, paso a paso**

1. Cursor lo ejecuta en los eventos `stop` y `sessionEnd`. Está registrado en `~/.cursor/hooks.json` (`hook.py:14`).
2. Lee de stdin el JSON del evento (`cli.py:70`).
3. Llama a `hook.record(payload, os.environ.get("RUN_IN_CURSOR_LOG"))`.
4. Imprime `{}` y devuelve OK (`cli.py:73-74`).

**La condición clave**

`record` solo escribe si existe la variable `RUN_IN_CURSOR_LOG` (`hook.py:19-20`). Esa variable la define `ric run` cuando lanza la sesión.

- Como el hook es global, Cursor lo ejecuta en todos los proyectos.
- Si la sesión no la lanzó `ric run`, no hace nada.

**Qué guarda**

Agrega una línea JSON al log con estos campos (`hook.py:15,21`):
- el nombre del evento
- `status`
- `model`
- `input_tokens`
- `output_tokens`
- `reason`
- un timestamp `t`

No guarda el prompt ni los archivos, según el docstring y el código: solo se copian esas claves.

**Para qué sirve**

- Es la señal de que el turno terminó. En `cli.py:116-118`, `ric run` se niega a arrancar si el hook no está instalado. Sin él, ningún turno avisaría su fin y `ric` esperaría el timeout completo.
- Es lo que lleva el modelo y los tokens a la telemetría. Eso concuerda con lo que dice `AGENTS.md` sobre `stop`, y por eso nunca se usa `cursor-agent -p`, que no dispara estos hooks (docstring de `cli.py:1`).

**Por qué nunca falla**

Un hook que se rompe aparece en cada turno de Cursor. Por eso se ejecuta dentro de un `try/except Exception` (`cli.py:69-72`), los errores de disco se tragan (`hook.py:27-28`) y siempre responde `{}`.

Lo que no verifiqué es cómo `ric run` consume el log para detectar el fin del turno. Eso está en `ric/session.py`. Si querés el flujo completo, lo leo.
