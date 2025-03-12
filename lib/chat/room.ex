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

  def get_messages(server) do
    GenServer.call(server, :get_messages)
  end

  def remove_client(server) do
    GenServer.call(server, :remove_client)
  end

  def broadcast(server, message) do
    GenServer.call(server, {:broadcast, message})
  end

  def is_registered?(server) do
    GenServer.call(server, :is_registered)
  end

  # Server API

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:add_client, name}, {pid, _}, clients) do
    Logger.info("ROOM: new client --#{name}--")
    clients = Map.put(clients, pid, %{:name => String.trim(name), :messages => []})
    {:reply, :ok, clients}
  end

  @impl true
  def handle_call(:get_messages, {pid, _}, clients) do
    res = Map.get(clients, pid)
    clients = Map.replace(clients, pid, %{:name => res.name, :messages => []})
    {:reply, res.messages, clients}
  end

  @impl true
  def handle_call(:remove_client, {pid, _}, clients) do
    {_, clients} = Map.pop(clients, pid)
    {:reply, true, clients}
  end

  @impl true
  def handle_call({:broadcast, message}, {pid, _}, clients) do
    name = Map.get(clients, pid).name

    message = "#{name}: " <> String.trim(message) <> "\n"

    clients =
      Map.to_list(clients)
      |> Enum.reduce(%{}, fn {pid, value}, acc ->
        Map.put(acc, pid, add_messages(value, message))
      end)

    {:reply, true, clients}
  end

  @impl true
  def handle_call(:is_registered, {pid, _}, clients) do
    res = Map.get(clients, pid)
    {:reply, res != nil, clients}
  end

  defp add_messages(value, message) do
    %{
      :name => value.name,
      :messages => (value.messages ++ [message]) |> List.flatten()
    }
  end
end
