`Harness/run-in-cursor/ric.py hook` es el subcomando que Cursor ejecuta como **hook global** en eventos `stop` y `sessionEnd` para registrar metadatos mínimos de la sesión de `ric`.

Lo verifiqué en código:

- `ric.py` solo deriva al CLI real (`main()`), no implementa lógica propia (`Harness/run-in-cursor/ric.py:8`, `Harness/run-in-cursor/ric.py:10`).
- El CLI define el comando `hook` y lo describe como llamado por Cursor en `stop`/`sessionEnd` (`Harness/run-in-cursor/ric/cli.py:65`).
- Cuando corrés `ric hook`, lee JSON de `stdin`, llama `hook.record(...)` y le pasa `RUN_IN_CURSOR_LOG` del entorno (`Harness/run-in-cursor/ric/cli.py:68`, `Harness/run-in-cursor/ric/cli.py:70`).
- Si algo falla, **no rompe**: captura excepciones, imprime `{}` y sale `0` (`Harness/run-in-cursor/ric/cli.py:68`, `Harness/run-in-cursor/ric/cli.py:73`, `Harness/run-in-cursor/ric/cli.py:74`).
- `hook.record` solo escribe si existe `RUN_IN_CURSOR_LOG`; si no, no hace nada (`Harness/run-in-cursor/ric/hook.py:19`).
- Lo que guarda por línea JSON es: `event`, `status`, `model`, `input_tokens`, `output_tokens`, `reason` y timestamp `t` (`Harness/run-in-cursor/ric/hook.py:14`, `Harness/run-in-cursor/ric/hook.py:15`, `Harness/run-in-cursor/ric/hook.py:21`, `Harness/run-in-cursor/ric/hook.py:25`).
- `ric install-hook` agrega ese comando al `hooks.json` global para ambos eventos (`Harness/run-in-cursor/ric/cli.py:75`, `Harness/run-in-cursor/ric/hook.py:47`, `Harness/run-in-cursor/ric/hook.py:53`, `Harness/run-in-cursor/ric/hook.py:56`).

## Próximos pasos
- **Recomendado:** probar rápido que está instalado con `python3 Harness/run-in-cursor/ric.py install-hook` (te confirma si lo agregó o ya estaba), porque sin eso `ric run` se rechaza (`Harness/run-in-cursor/ric/cli.py:116`).
- Validar qué se persiste realmente mirando `Harness/run-in-cursor/tests/test_hook.py` y `Harness/run-in-cursor/tests/test_cli.py`, así ves casos borde (JSON inválido, no-op sin env, etc.).
