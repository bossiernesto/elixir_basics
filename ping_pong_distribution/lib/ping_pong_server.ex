defmodule PingPongServer do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def start(opts \\ []) do
    GenServer.start(__MODULE__, :ok, opts)
  end

  def ping(server) do
    GenServer.call server, :ping
  end

  def stop(server) do
    GenServer.call server, :stop
  end

  def crash(server) do
    GenServer.call server, :crash
  end

  # Callbacks

  def init(:ok) do
    {:ok, {}} #stateless
  end

  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, state}
  end

  def handle_call(:crash, _from, state) do
    9 / 0
  end
end
