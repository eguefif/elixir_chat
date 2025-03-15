defmodule ChatClientsTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, client} = ChatClient.start_link(:ok)
    %{client: client}
  end

  test "add messages", %{client: client} do
    ChatClient.add_message(client, "Hello, World")
    assert ChatClient.get_messages(client) == ["Hello, World"]
  end
end
