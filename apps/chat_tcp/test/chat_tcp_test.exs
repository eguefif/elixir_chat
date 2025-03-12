defmodule ChatTcpTest do
  use ExUnit.Case
  doctest ChatTcp

  test "greets the world" do
    assert ChatTcp.hello() == :world
  end
end
