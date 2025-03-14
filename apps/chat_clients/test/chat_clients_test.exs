defmodule ChatClientsTest do
  use ExUnit.Case
  doctest ChatClients

  test "greets the world" do
    assert ChatClients.hello() == :world
  end
end
