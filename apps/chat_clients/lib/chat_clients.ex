defmodule ChatClients do
  use GenServer

  # Client API
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def add_client(server, name) do
    GenServer.call(server, {:add_client, name})
  end

  def add_message(server, name, message) do
    GenServer.call(server, {:add_message, name, message})
  end

  def get_messages(server, name) do
    GenServer.call(server, {:get_message, name})
  end

  # Server API
  @impl true
  def init(:ok) do
    clients = %{}
    refs = %{}
    {:ok, {clients, refs}}
  end

  @impl true
  def handle_call({:lookup, id}, _from, {clients, _}) do
    {:reply, Map.get(clients, id), clients}
  end

  @impl true
  def handle_call({:add_client, id}, _from, {clients, refs}) do
    if Map.has_key?(clients, id) do
      {:noreply, id}
    else
      {:ok, client} = Chat.ChatClient.start_link(:ok)
      clients = Map.put(clients, id, client)
      ref = Process.monitor(client)
      refs = Map.put(refs, ref, id)
      {:reply, id, {clients, refs}}
    end
  end

  @impl true
  def handle_call({:get_message, id}, _from, {clients, _}) do
    if Map.has_key?(clients, id) do
      client = Map.get(clients, id)
      messages = Chat.ChatClient.get_messages(client)
      {:reply, messages, clients}
    else
      {:reply, {:error, :key_error, id}, clients}
    end
  end

  @impl true
  def handle_call({:add_message, id, message}, _from, {clients, _}) do
    if Map.has_key?(clients, id) do
      client = Map.get(clients, id)
      Chat.ChatClient.add_messages(client, message)
      {:reply, :ok, clients}
    else
      {:reply, {:error, :key_error, id}, clients}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {clients, refs}) do
    {id, refs} = Map.pop(refs, ref)
    names = Map.pop(clients, id)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in ChatClients: #{inspect(msg)}")
    {:noreply, state}
  end
end
