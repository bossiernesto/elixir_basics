# Ejemplo de una aplicación OTP distribuida

La aplicación define un [`PingPongServer`](https://github.com/arquitecturas-concurrentes/iasc-distribution-elixir/tree/master/ping_pong): un actor al cual si le envía el mensaje `ping` responde `pong`. 

Prestar atención a los siguientes elementos: 

* Aplicaciones
* Workers - GenServer en este caso
* Supervisores
* Alias locales y globales

## Levantando una sóla VM

```bash
iex -S mix
```

## Levantando múltiples VMs


```bash
iex --sname foo -S mix
```

Luego se pueden utilizar las siguientes herramientas para hacer comunicación entre VMs:

* `Node.spawn`
* `:rpc.call`

## Levantando múltiples VMs

```bash
iex --sname ke -pa _build/dev/lib/ping_pong/ebin/ --app ping_pong --erl "-config config/ke"
iex --sname me -pa _build/dev/lib/ping_pong/ebin/ --app ping_pong --erl "-config config/me"
iex --sname roon -pa _build/dev/lib/ping_pong/ebin/ --app ping_pong --erl "-config config/roon"
```

Tener en cuenta que por lo definido en cada uno de los [archivos de configuración](https://github.com/arquitecturas-concurrentes/iasc-distribution-elixir/tree/master/ping_pong/config), la consola se va a quedar esperando hasta que las 3 VMs estén levantadas antes de empezar.

Probar matar una vm y ver que después el proceso renace en la siguiente de menor prioridad
