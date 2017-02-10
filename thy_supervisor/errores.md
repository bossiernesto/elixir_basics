# Manejo de Errores e Introducción a la Supervisión

Tres patrones de comunicación de errores:

- call & return: enviar un mensaje y que este devuelva algo que represente al error, ya sea un código o un objeto más rico
- continuaciones
- excepciones: el método que falla lanza la excepción, abortando el envío del mensaje, y propagandola hasta quien lo inició (que en última instancia, es el main, si ninguna porción de código en el medio captura la excepción)

## Call and return

call and return es usado frecuentemente para señalizar ausencias de valores o errores que deben ser manejados de forma cercana a quien lo propagó, usando algunos de los siguientes formatos:

{ok, Value} / error
{value, Value} / error
Value / error

Es bastante evidente que todos estos tipos algebraicos describen functores. Sin embago, mas por convención de la comunidad que por limitaciones propias del lenguaje, se estila manejar esto con pattern matching, en lugar de con combinadores como el fmap. Y ademas de ello, el lenguaje no posee una sintaxis especial como la do-syntax de Haskell o las for-comprhensions de Scala, lo que aún con combinadores su uso no es transparente. Por ello entonces es que decimos que son usados para manejar errores que deben ser tratados en un lugar cercano a su causa, dado que propogar estos errores es engorroso.


## Continuations

Teoricamente no hay limitaciones sobre su uso, pero el API estándar no presenta muchos ejemplos de estas para el manejo de errores.

## Excepciones

son la base del fail-fast y let-it-crash de Erlang. En Erlang y derivados se diferencian al menos dos tipos de excepciones

- las excepciones utilizadas para indicar errores (error) y terminaciones de procesos (exit). Lo que indican es que hubo un error y el proceso debe ser detenido.
- los retornos no locales. La diferencia semántica es sutil, y se ve en lo que ocurre al no capturar un retorno no local (throw): el error que se produce por no capturar una excepcion de tipo error es justamente ese error. Pero el error de no capturar un throw es.... {nocatch,Value}. Es decir, throw no está indicando que el proceso deba ser detenido, sino que alguien debe manejar ese throw; y el error está en no haberlo manejado (en contraposicion con error, donde el error es el lanzamiento propiamente dicho).
Mientras que error tiene una semántica de "lanzo esto sin esperar que alguien lo capture", throw tiene una semántica de "lanzo esto porque SE que alguien lo va a manejar".  


Mas alla de la discusión throw/error, que es un poco anecdótica (podriamos haber vivido sin conocer a throw, y sin usar retornos no locales), lo que vale la pena analizar son las diferencias entre la excepciones de actores y de objetos, o mejor dicho, analizar que son idénticas pero que el modelo de procesos independientes modifica algunas cosencuencias.

Volvamos a la idea original: las excepciones cortan el flujo de ejecución del envio del mensaje, hasta llegar a quien lo inició (el main), es decir, se propagan a traves del stack.


- No hay un main, hay N "mains", uno por cada actor.
- El envio de mensajes de un actor a otro actor no ocurre a traves del stack, y es asincrónico (y aun los mensajes sincronicos se conforman a traves de mensajes asincronicos).
- El actor es un proceso ejecutable, en contraposición con objetos, donde el método es el código ejecutable.
- A diferencia del código de un método de un objeto que es ejecutado por el proceso (hilo, fibra, etc) en el que el envio de mensajes ocurre, el código de un recieve es ejecutado por el proceso asociado al actor receptor.


## Consecuencias

- una excepción dentro del actor no "destruye" a la cadena de envio de mensajes, sino que destruye al actor mismo.
- en el paso de mensajes entre actores, las excepciones que ocurran como parte de un envío de mensajes NO serán reportadas al actor que envió el mensajes (en contraposición a "en el paso de mensajes entre objetos, las excepciones que ocurran como parte de un envío de mensajes serán reportadas al (método del) objeto que envió el mensaje")
- Qué signfiica esto, que el manejador de la excepción ya no es el cliente que inició el pedido (como en objetos). Lema: si yo envio un mensaje y ese mensaje provoca la muerte del actor, yo no soy reponsable de manejar esa situación.

### Como maneja un proceso las excepciones?

- Por defecto, nadie. El actor muere. Y esa funcionalidad del sistema queda deshabilitada (ups, eso es malo, pero al menos no muere el programa completo, como lo sería en un ambiente de objetos secuencial)
- Pero podemos designar a otro actor para que se encargue de la misma, y tome una acción. Por una cuestión de separación de responsabilidades, este actor responsable de manejar la falla de otro actor se dedicará sólo a eso: será su supervisor. Y la acciones que puede tomar son:

- reiniciarlo
- dejarlo morir
- morir también junto con el proceso supervisado (y si alguien lo supervisa, podrá tomar las mismas decisiones)


## Supervisores


### Estrategias

#### one_for_one

If a child process terminates, only that process is restarted.

#### one_for_all

If a child process terminates, all other child processes are terminated, and then all child processes, including the terminated one, are restarted.

#### rest_for_one

If a child process terminates, the rest of the child processes (that is, the child processes after the terminated process in start order) are terminated. Then the terminated child process and the rest of the child processes are restarted.

#### simple_one_for_one

A supervisor with restart strategy simple_one_for_one is a simplified one_for_one supervisor, where all child processes are dynamically added instances of the same process.

The following is an example of a callback module for a simple_one_for_one supervisor:


```erlang
-module(simple_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link(simple_sup, []).

init(_Args) ->
    SupFlags = #{strategy => simple_one_for_one,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [#{id => call,
                    start => {call, start_link, []},
                    shutdown => brutal_kill}],
    {ok, {SupFlags, ChildSpecs}}.
```

When started, the supervisor does not start any child processes. Instead, all child processes are added dynamically by calling:

```erlang
supervisor:start_child(Sup, List)
```

Sup is the pid, or name, of the supervisor. List is an arbitrary list of terms, which are added to the list of arguments specified in the child specification. If the start function is specified as {M, F, A}, the child process is started by calling apply(M, F, A++List).

For example, adding a child to simple_sup above:

```
supervisor:start_child(Pid, [id1])
```

The result is that the child process is started by calling apply(call, start_link, []++[id1]), or actually:
```
call:start_link(id1)
```
A child under a simple_one_for_one supervisor can be terminated with the following:

```
supervisor:terminate_child(Sup, Pid)
```

Sup is the pid, or name, of the supervisor and Pid is the pid of the child.
Because a simple_one_for_one supervisor can have many children, it shuts them all down asynchronously. This means that the children will do their cleanup in parallel and therefore the order in which they are stopped is not defined.
