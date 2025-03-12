defmodule ChatTcp do
  require Logger

  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    with {:ok, client} <- :gen_tcp.accept(socket),
         {:ok, pid} <- Task.Supervisor.start_child(Chat.TaskSupervisor, fn -> serve(client) end),
         :ok = :gen_tcp.controlling_process(client, pid) do
      loop_acceptor(socket)
    else
      e -> Logger.error("Error while accepting new connection: #{e}")
    end
  end

  defp add_client(socket) do
    ChatRoom.add_client(ChatRoom, get_name(socket))
  end

  defp serve(socket) do
    if not ChatRoom.is_registered?(ChatRoom) do
      add_client(socket)
    end

    with {:ok, data} <- read_line(socket),
         :ok <- broadcast_line(data) do
      serve_write(socket)
      serve(socket)
    else
      {:error, :timeout} ->
        serve_write(socket)
        serve(socket)

      _ ->
        Logger.info("Client disconnection")
    end
  end

  def get_name(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, name} ->
        name

      {:error, e} ->
        Logger.error("Error while retrieving client's name: #{e}")
        :error
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0, 100)
  end

  defp broadcast_line(message) do
    ChatRoom.broadcast(ChatRoom, message)
    :ok
  end

  defp serve_write(socket) do
    messages = ChatRoom.get_messages(ChatRoom)
    if messages != [], do: send_messages(socket, messages)
  end

  defp send_messages(socket, messages) do
    messages = messages |> Enum.join("\n")
    :gen_tcp.send(socket, messages)
  end
end
