defmodule ChatRoom do
  use Agent
  require Logger

  def start_link(:ok) do
    Agent.start_link(fn -> [] end)
  end

  def broadcast(room, message) do
    clients = Agent.get(room, fn state -> state end)

    Enum.each(clients, fn client ->
      ChatClients.add_message(client, message)
    end)

    :ok
  end

  def join(room, client) do
    Logger.debug("Room: client #{client}")
    Agent.update(room, fn clients -> clients ++ [client] end)
  end

  def remove(room, client) do
    Logger.debug("Room: remove client #{client}")

    Agent.update(
      room,
      fn clients -> List.delete(clients, client) end
    )
  end

  def is_client?(room, client) do
    Agent.get(room, fn clients -> clients end)
    |> Enum.any?(fn room_client -> room_client == client end)
  end
end
