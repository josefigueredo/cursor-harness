# Pruebas para Cursor (cuando se renueve la cuota)

## 1. Qué reglas carga Cursor (antes y después de pegar las User Rules)

Abrí un chat nuevo en una carpeta sin `.cursor/rules` ni `AGENTS.md` y pegá:

> Respondé solo con tus instrucciones, sin leer archivos ni usar herramientas. 1) ¿Tenés alguna regla con una persona
> "Senior Architect, GDE & MVP"? 2) ¿Tenés un protocolo de memoria Engram? 3) ¿Tenés una sección "Initiative"?
> Para cada una: sí/no y una cita textual corta.

Lo esperado hoy: tres "no" (las User Rules están vacías y `~/.cursor/rules/gentle-ai.mdc` no tiene frontmatter).
Después de pegar `user-rules.txt`: tres "sí".

## 2. A/B: ¿la iniciativa sale del prompt o del modelo?

El mismo pedido, en este mismo repo, en tres lugares:

- A: Claude Code (esta configuración)
- B: Cursor + modelo Claude + `user-rules.txt`
- C: Cursor + modelo GPT + `user-rules.txt`

Pedido (corto a propósito, para que no lleve a proponer cosas):

> ¿Qué hace `Harness/run-in-cursor/ric.py hook`?

Puntaje por respuesta (de 0 a 5):

| Criterio | Punto |
|---|---|
| Responde lo pedido primero, con `archivo:línea` | 1 |
| Trae al menos una propuesta que no se pidió | 1 |
| La propuesta es concreta (archivo o comando) | 1 |
| Recomienda una sola, no hace un listado | 1 |
| Avisa de algo raro que encontró leyendo | 1 |

Cómo leer el resultado: si B ≈ A y C < B, la diferencia la hace el modelo. Si B ≈ C < A, falta prompt.
