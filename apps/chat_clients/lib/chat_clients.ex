defmodule ChatClients do
  use GenServer
  require Logger

  # Client API
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get_name() do
    GenServer.call(__MODULE__, {:get_name})
  end

  def add_client(name) do
    GenServer.call(__MODULE__, {:add_client, name})
  end

  def add_message(interlocutor, message) do
    Logger.debug("In add message")
    GenServer.call(__MODULE__, {:add_message, interlocutor, message})
  end

  def get_messages() do
    GenServer.call(__MODULE__, {:get_message})
  end

  # Server API
  @impl true
  def init(:ok) do
    clients = %{}
    clients_name = %{}
    refs = %{}
    {:ok, {clients, refs, clients_name}}
  end

  @impl true
  def handle_call({:add_client, name}, {pid, _}, {clients, refs, clients_name}) do
    if Map.has_key?(clients, pid) do
      {:noreply, {clients, refs}}
    else
      {:ok, client} = ChatClient.start_link(:ok)
      ChatClient.set_name(client, name)
      clients = Map.put(clients, pid, client)
      clients_name = Map.put(clients_name, name, client)
      ref = Process.monitor(client)
      refs = Map.put(refs, ref, pid)
      require Logger
      Logger.info("Adding client Genserver: #{inspect(clients)}")
      {:reply, pid, {clients, refs, clients_name}}
    end
  end

  @impl true
  def handle_call({:get_message}, {pid, _}, {clients, refs, clients_name}) do
    if Map.has_key?(clients, pid) do
      client = Map.get(clients, pid)
      messages = ChatClient.get_messages(client)
      {:reply, messages, {clients, refs, clients_name}}
    else
      {:reply, {:error, :key_error, pid}, {clients, refs, clients_name}}
    end
  end

  @impl true
  def handle_call({:add_message, interlocutor, message}, _, {clients, refs, clients_name}) do
    client = Map.get(clients_name, interlocutor)
    ChatClient.add_message(client, message)
    {:reply, :ok, {clients, refs, clients_name}}
  end

  @impl true
  def handle_call({:get_name}, {pid, _}, {clients, refs, clients_name}) do
    client = Map.get(clients, pid)
    {:reply, ChatClient.get_name(client), {clients, refs, clients_name}}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {clients, refs, clients_name}) do
    {id, refs} = Map.pop(refs, ref)
    names = Map.pop(clients, id)
    {:noreply, {names, refs, clients_name}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in ChatClients: #{inspect(msg)}")
    {:noreply, state}
  end
end
