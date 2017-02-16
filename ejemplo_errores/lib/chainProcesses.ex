defmodule ChainProcesses do
  def chain(0) do
    IO.puts "Pid: #{inspect self}"
    receive do
      {:msg,contents} -> :ok
    after 2000 ->
      exit "Chain dies here"
    end

  end

  def chain(n) do
    spawn_link(fn ->
      IO.puts "Pid: #{inspect self}"
      IO.puts "chaining to #{inspect self}";  chain(n-1)
      receive do
        _ -> {:ok}
      end
      end)
  end
end
