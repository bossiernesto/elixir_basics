El modelo de actores nos permite....

- aprovechar el paralelismo a nivel hardware (procesadores de múltiples nucleos)
Falso: el modelo de actores funciona aún sobre un único procesador físico.
De hecho Erlang no introdujo soporte para SMP hasta 2006.

- manejar grandes cantidades de usuarios de forma concurrente
- procesar datos masivamente
Falso: Erlang no es particularmente bueno para procesar grandes volúmenes de datos, dado que no se encuentra particularmente optimizado para realizar operaciones sobre texto o matemáticas.

Al desarrollar bajo el modelo de actores obtenemos código que es automáticamente

- distribuido

Falso: si bien Erlang tiene soporte para distribución nativo, no es un motor de distribución de propósito general. Y aún usándolo, es necesario pensar la arquitectura cuidadosamente

- tolerante a fallos
- libre de deadlocks

Falso: un mal diseño puede introducir fácilmente deadlocks en programas Erlang.

## Pros y Contras

- variables mutables: (las variables del proceso SON mutables)
- estado compartido (las ets y dets permiten compartir memoria)
- condiciones de carrera (además de lo anterior, por ejemplo, register introduce esa noción)
