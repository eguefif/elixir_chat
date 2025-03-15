defmodule Chat.Command do
  require Logger

  def parse(line) do
    Logger.info("Parsing: #{line}")

    case String.split(line) do
      ["NAME", msg] -> {:ok, {:add_client, msg}}
      ["WHISPER", interlocutor, content] -> {:ok, {:whisper, interlocutor, content}}
      _ -> {:error, :unknown_command}
    end
  end

  def run(command)

  def run({:add_client, name}) do
    Logger.info("Adding client: #{name}")
    ChatClients.add_client(ChatClients.Supervisor, name)
    :ok
  end
end
