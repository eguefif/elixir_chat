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
  def handle_call({:join_client, room_name, client}, _, rooms) do
    if Map.has_key?(rooms, room_name) do
      room = Map.get(rooms, room_name)
      ChatRoom.join(room, client)
    else
      {:ok, room} = ChatRoom.start_link(:ok)
      ChatRoom.join(room, client)
      Map.put(rooms, room_name, room)
    end

    {:reply, :ok, rooms}
  end

  @impl true
  def handle_call({:remove_client, room_name, client}, _, rooms) do
    room = Map.get(rooms, room_name)
    ChatRoom.remove(room, client)
    {:reply, true, rooms}
  end

  @impl true
  def handle_call({:broadcast, room_name, message}, _, rooms) do
    room = Map.get(rooms, room_name)
    ChatRoom.broadcast(room, message)
    {:reply, true, rooms}
  end
end
