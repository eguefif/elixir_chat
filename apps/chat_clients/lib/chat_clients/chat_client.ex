defmodule ChatClient do
  use Agent
  require Logger

  def start_link(:ok) do
    Agent.start_link(fn -> %{"name" => "", "messages" => []} end)
  end

  def is_client(client, name) do
    String.trim(name) == Agent.get(client, &Map.get(&1, "name"))
  end

  def get_messages(client) do
    Agent.get_and_update(client, fn state ->
      {Map.get(state, "messages"), Map.update!(state, "messages", fn _ -> [] end)}
    end)
  end

  def get_name(client) do
    Agent.get(client, &Map.get(&1, "name"))
  end

  def set_name(client, name) do
    Agent.update(client, fn state ->
      Map.update!(state, "name", fn _ -> name end)
    end)
  end

  def add_message(client, message) do
    Agent.update(client, fn state ->
      Map.update(state, "messages", %{"name" => "", "messages" => []}, fn value ->
        value ++ [message]
      end)
    end)
  end
end
