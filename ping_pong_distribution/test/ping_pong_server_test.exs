defmodule PingPongServerTest do
  use ExUnit.Case

  test "ping answers pong" do
    {:ok, server} = PingPongServer.start_link

    answer = PingPongServer.ping server

    assert answer = :pong
  end
end
