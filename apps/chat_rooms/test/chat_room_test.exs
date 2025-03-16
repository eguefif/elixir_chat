defmodule ChatRoomTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, room} = ChatRoom.start_link(:ok)
    %{room: room}
  end

  test "join room", %{room: room} do
    ChatRoom.join(room, "River")

    assert ChatRoom.is_client?(room, "River")
  end
end
