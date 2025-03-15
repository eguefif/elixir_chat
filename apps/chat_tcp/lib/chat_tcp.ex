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

  defp serve(socket) do
    with {:ok, line} <- read_line(socket),
         {:ok, data} <- Chat.Command.parse(line),
         :ok <- Chat.Command.run(data) do
      serve(socket)
    else
      {:error, :timeout} ->
        serve(socket)

      {:error, reason} ->
        Logger.error("Error serving client #{reason}")
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0, 100)
  end
end
