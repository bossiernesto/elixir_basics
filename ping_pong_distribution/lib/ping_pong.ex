defmodule PingPong do
  use Application

  def start(_type, _args) do
    PingPongSupervisor.start_link
  end

  def ping do
    PingPongServer.ping {:global, GlobalPingPong}
  end
end
