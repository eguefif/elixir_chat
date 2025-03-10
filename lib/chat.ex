defmodule Chat do
  require Logger

  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    with {:ok, client} <- :gen_tcp.accept(socket),
         {:ok, pid} <- Task.Supervisor.start_child(Chat.TaskSupervisor, fn -> serve(client) end) do
      :ok = :gen_tcp.controlling_process(client, pid)
      loop_acceptor(socket)
    else
      e -> Logger.error("Error while accepting new connection: #{e}")
    end
  end

  defp serve(socket) do
    {ip, port} = get_ip_port(socket)
    Logger.info("Serving new connexion: #{ip}:#{port}")

    with {:ok, data} <- read_line(socket),
         :ok <- broadcast_line(data, socket) do
      serve(socket)
    else
      _ -> Logger.info("Client disconnection")
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp broadcast_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

  def get_ip_port(socket) do
    case :inet.peername(socket) do
      {:ok, {ip, port}} ->
        addr = :inet.ntoa(ip) |> to_string()
        {addr, port}

      {:error, reason} ->
        Logger.info("Error while getting IP adress: #{reason}")
    end
  end
end
