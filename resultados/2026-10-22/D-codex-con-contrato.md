`Harness/run-in-cursor/ric.py hook` es el punto de entrada que Cursor ejecuta al terminar un turno (`stop`) o cerrar una sesión (`sessionEnd`). Lee el evento JSON de stdin y, si existe `RUN_IN_CURSOR_LOG`, agrega una línea JSONL con el evento, estado, modelo, tokens de entrada/salida, motivo y hora. **No guarda el prompt ni los archivos**; en sesiones que no inició `ric`, no registra nada. En todos los casos responde `{}` y evita propagar errores para no interrumpir Cursor. 【`ric/hook.py:1-5,19-29`; `ric/cli.py:68-73`】

Se instala en `~/.cursor/hooks.json` para `stop` y `sessionEnd`, junto con los hooks que ya haya. (`ric/cli.py:63-77`)

## Próximos pasos

- Si querés, puedo seguir el flujo completo desde `ric run` hasta el archivo `.jsonl` para mostrarte dónde queda y cómo se usa.