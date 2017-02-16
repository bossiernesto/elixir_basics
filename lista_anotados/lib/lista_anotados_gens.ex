defmodule ListaAnotados.RegistryMonitored do
  use GenServer

  ### Client API
  @doc """
  Starts the registry.
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @doc """
  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ### Server Callbacks
  def init(:ok) do
    talks = %{}
    refs  = %{}
    {:ok, {talks, refs}}
  end

  def handle_call({:lookup, name}, _from, {talks, _} = state) do
    {:reply, Map.fetch(talks, name), state}
  end

  #This shouldn't be a cast, but for educational purposes we changed
  #this for a cast
  def handle_cast({:create, name}, {talks, refs} = state) do
    if Map.has_key?(talks, name) do
      {:noreply, state}
    else
      {:ok, pid} = KV.Bucket.start_link
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      talks = Map.put(talks, name, pid)
      {:noreply, {talks, refs}}
    end
  end

  # This is to handle when a process has received a DOWN process from the scheduler
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {talks, refs}) do
    {name, refs} = Map.pop(refs, ref)
    talks = Map.delete(talks, name)
    {:noreply, {talks, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
