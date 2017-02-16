defmodule ListaAnotados do

  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  def loop(state) do
    receive do
      {:get, _caller, key}  ->
        send _caller, Map.get(state, key)
        loop(state)
      {:put, _caller, key, value} ->
        loop(Map.put(map, key, value))   
    end
  end
end
