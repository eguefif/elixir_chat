defmodule Chat.Room do
  require Logger
  use GenServer

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add_client(server, name) do
    GenServer.call(server, {:add_client, name})
  end

  def add_message(server, name, messages) do
    GenServer.call(server, {:add_messages, name, messages})
  end

  def is_client?(server, name) do
    GenServer.call(server, {:is_client, name})
  end

  def get_messages(server, name) do
    GenServer.call(server, {:get_messages, name})
  end

  def remove_client(server, name) do
    GenServer.call(server, {:remove_client, name})
  end

  # TODO: add test for broadcast
  def broadcast(server, messages) do
    GenServer.call(server, {:broadcast, messages})
  end

  # Server API

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:add_client, name}, _from, clients) do
    Logger.info("ROOM: new client --#{name}--")
    clients = Map.put(clients, name, [])
    {:reply, clients, clients}
  end

  @impl true
  def handle_call({:add_messages, client, messages}, _from, clients) do
    {_, clients} = add_messages(clients, client, messages)

    {:reply, clients, clients}
  end

  @impl true
  def handle_call({:is_client, name}, _from, clients) do
    {:reply, Map.has_key?(clients, name), clients}
  end

  @impl true
  def handle_call({:get_messages, name}, _from, clients) do
    {:reply, Map.get(clients, name), clients}
  end

  @impl true
  def handle_call({:remove_client, name}, _from, clients) do
    {_, clients} = Map.pop(clients, name)
    {:reply, true, clients}
  end

  @impl true
  def handle_call({:broadcast, messages}, _from, clients) do
    Map.keys(clients)
    |> Enum.each(fn client ->
      add_messages(clients, client, messages)
    end)

    {:reply, true, clients}
  end

  defp add_messages(clients, client, messages) do
    Map.get_and_update(clients, client, fn current_value ->
      {current_value, [messages | current_value] |> List.flatten()}
    end)
  end
end
