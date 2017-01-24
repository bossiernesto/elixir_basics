Process.flag :trap_exit, true
p = spawn_link fn -> exit(1) end
#PID<0.62.0>

iex(4)> Process.alive?(p)
false

iex(5)> flush
{:EXIT, #PID<0.63.0>, 1}
