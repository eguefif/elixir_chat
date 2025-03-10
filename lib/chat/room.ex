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
  def handle_call({:add_messages, name, messages}, _from, clients) do
    # concatenated = Enum.join(messages, "    \n")
    # Logger.info("ROOM: update message for #{name}:")
    # Logger.info("    #{concatenated}")

    {_, clients} =
      Map.get_and_update(clients, name, fn current_value ->
        {current_value, [messages | current_value] |> List.flatten()}
      end)

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
end
