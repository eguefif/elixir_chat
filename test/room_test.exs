defmodule Chat.RoomTest do
  use ExUnit.Case

  setup do
    room = start_supervised!(Chat.Room)
    %{room: room}
  end

  test "add_client should add a new client", %{room: room} do
    assert Chat.Room.is_client?(room, "Robert") == false

    Chat.Room.add_client(room, "Robert")

    assert true == Chat.Room.is_client?(room, "Robert")
  end

  test "update message for Robert", %{room: room} do
    assert Chat.Room.is_client?(room, "Robert") == false

    Chat.Room.add_client(room, "Robert")
    assert Chat.Room.get_messages(room, "Robert") == []

    Chat.Room.add_message(room, "Robert", ["Hello", "World"])
    assert ["Hello", "World"] == Chat.Room.get_messages(room, "Robert")

    Chat.Room.add_message(room, "Robert", ["It's John"])
    assert ["It's John", "Hello", "World"] == Chat.Room.get_messages(room, "Robert")
  end

  test "remove_client should remove a client", %{room: room} do
    Chat.Room.add_client(room, "Robert")
    assert true == Chat.Room.is_client?(room, "Robert")

    client = Chat.Room.remove_client(room, "Robert")

    assert client == true
    assert Chat.Room.is_client?(room, "Robert") == false
  end
end
