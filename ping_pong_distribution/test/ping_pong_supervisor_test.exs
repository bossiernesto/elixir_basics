defmodule PingPongSupervisorTest do
  use ExUnit.Case

  test "starts a ping pong server" do
    {:ok, _} = PingPongSupervisor.start_link
    server = Process.whereis GlobalPingPong

    assert Process.alive?(server)
  end
end
