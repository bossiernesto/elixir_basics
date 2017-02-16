iex> {:ok, pid} = ListaAnotados.Bucket.start_link
{:ok, #PID<0.66.0>}
iex> Process.monitor(pid)
#Reference<0.0.0.551>
iex> Agent.stop(pid)
:ok
iex> flush()
{:DOWN, #Reference<0.0.0.551>, :process, #PID<0.66.0>, :normal}
