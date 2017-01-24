iex(1)> :bar + 1
** (ArithmeticError) bad argument in arithmetic expression
    :erlang.+(:bar, 1)

iex(1)> raise "Aca lanzo una runtime"
** (RuntimeError) Aca lanzo una runtime

defmodule FuckedModule do
  defexception message: "exception message"
end

iex(2)> raise FuckedModule
** (FuckedModule) exception message

iex(2)> raise FuckedModule, message: "something happened"
** (FuckedModule) something happened


try do
  raise "some unexpected error"
  IO.puts "Not going to be executed."
rescue
  RuntimeError -> :error
end

iex(1)> try do
...(1)>   raise 'some unexpected error'
...(1)>   IO.puts "Not going to be executed."
...(1)> rescue
...(1)>   RuntimeError -> :error
...(1)> end
** (CaseClauseError) no case clause matching: 'some unexpected error'


iex(1)> File.read "bleh"
{:error, :enoent}
iex(2)> File.write "bleh", "saraza"
:ok
iex(3)> File.read "bleh"
{:ok, "saraza"}


r = File.read("bleh")
case r do
  {:ok, content}   -> IO.puts "Content read: #{content}"
  {:error, reason} -> IO.puts "Error, reason: #{reason}"
end

iex(8)> spawn_link fn -> exit(1) end
** (EXIT from #PID<0.59.0>) 1


try do
  exit(1)
catch
  :exit,_ -> IO.puts "Not exiting from #{inspect self()}"
end

iex(3)> try do
...(3)>   exit(1)
...(3)> catch
...(3)>   :exit,_ -> IO.puts "Not exiting from #{inspect self()}"
...(3)> end
Not exiting from #PID<0.80.0>
:ok



brokenfn = fn -> :timer.sleep(5000); exit(1) end
spawn brokenfn
spawn_link brokenfn

iex(1)> brokenfn = fn -> :timer.sleep(5000); exit("Falle") end
#Function<20.90072148/0 in :erl_eval.expr/5>
iex(2)> spawn_link brokenfn
#PID<0.91.0>
** (EXIT from #PID<0.88.0>) "I Failed"


chain(0) ->
receive
_ -> ok
after 2000 ->
exit("chain dies here")
end;
chain(N) ->
Pid = spawn(fun() -> chain(N-1) end),
link(Pid),
receive
_ -> ok
end.
