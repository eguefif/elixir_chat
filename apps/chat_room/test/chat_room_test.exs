defmodule ChatRoomTest do
  use ExUnit.Case
  doctest ChatRoom

  test "greets the world" do
    assert ChatRoom.hello() == :world
  end
end
