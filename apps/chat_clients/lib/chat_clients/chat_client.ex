defmodule Chat.ChatClient do
  use Agent

  def start_link(:ok) do
    Agent.start_link(fn -> %{"name" => "", "messages" => []} end)
  end

  def get_messages(client) do
    Agent.get(client, &Map.get(&1, "messages"))
  end

  def add_messages(client, message) do
    Agent.update(client, fn state ->
      Map.update(state, "messages", %{"name" => "", "messages" => []}, fn value ->
        value ++ [message]
      end)
    end)
  end
end
