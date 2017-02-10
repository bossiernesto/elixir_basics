defmodule ListaAnotados.Bucket do

  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def get(bucket, user) do
    Agent.get(bucket, &Map.get(&1, user))
  end

  def put(bucket, user, value) do
    Agent.update(bucket, &Map.put(&1, user, value))
  end

  def delete(bucket, user) do
    Agent.get_and_update(bucket, &Map.pop(&1, user))
  end
end
