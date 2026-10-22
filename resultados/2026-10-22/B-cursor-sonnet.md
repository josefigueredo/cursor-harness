`ric hook` es el hook global que Cursor llama al terminar un turno (`stop`) y al cerrar la sesión (`sessionEnd`). Sirve para que `ric run` se entere de que el turno terminó.

**Qué hace**
1. Lee el JSON del evento desde stdin (`Harness/run-in-cursor/ric/cli.py:70`).
2. Llama a `hook.record(payload, os.environ.get("RUN_IN_CURSOR_LOG"))` (`cli.py:70`).
3. Imprime `{}` y devuelve OK siempre (`cli.py:68-73`). Cualquier excepción se traga, porque un hook roto aparecería en todos los turnos de todos los proyectos.

**Qué registra** (`Harness/run-in-cursor/ric/hook.py:16-28`)
- Escribe solo si existe `RUN_IN_CURSOR_LOG`, que define `ric run`. En cualquier otra sesión no hace nada.
- Agrega una línea JSON al log con `event`, `status`, `model`, `input_tokens`, `output_tokens`, `reason` y `t` (timestamp). No guarda el prompt ni los archivos.
- Si falla la escritura (`OSError`), la ignora.

**Cómo se instala**
- `ric install-hook` agrega `"<python> ric.py hook"` a `stop` y `sessionEnd` en `~/.cursor/hooks.json`, sin pisar lo que ya hubiera (`hook.py:46-61`, `cli.py:75-77`).
- Es idempotente: si ya está, responde "hook already present".
- `ric run` se niega a arrancar si el hook no está instalado, para no esperar el timeout completo (`cli.py:116-118`).

`ric.py` en sí solo agrega su carpeta a `sys.path` y llama a `ric.cli.main` (`ric.py:5-10`). El comportamiento está en `ric/cli.py` y `ric/hook.py`.

**Próximos pasos**
- **Recomendado:** revisar `_ours` (`hook.py:38-39`). Reconoce el hook propio con `"ric.py" in command` y `endswith(" hook")`. Un comando de otra herramienta que cumpla ambas condiciones se confundiría con el nuestro. Es una inferencia, no la probé. Se podría agregar un test en `tests/test_hook.py` con un comando ajeno que termine en ` hook`.
- Si hay un `RUN_IN_CURSOR_LOG` heredado en un shell, el hook escribiría en sesiones que no son de `ric run`. Se puede verificar con `env | rg RUN_IN_CURSOR_LOG`.
