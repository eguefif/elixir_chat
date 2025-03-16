defmodule ChatRooms do
  require Logger
  use GenServer

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add_client(server) do
    GenServer.call(server, :add_client)
  end

  def broadcast(server, message) do
    GenServer.call(server, {:broadcast, message})
  end

  def remove_client(server) do
    GenServer.call(server, :remove_client)
  end

  # Server API

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:join_client, room}, {pid, _}, clients) do
    {:reply, :ok, clients}
  end

  @impl true
  def handle_call({:remove_client, room, client}, {pid, _}, clients) do
    {:reply, true, clients}
  end

  @impl true
  def handle_call({:broadcast, room, message}, {pid, _}, clients) do
    {:reply, true, clients}
  end
end
