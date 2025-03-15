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
    ChatClients.add_client(name)
    :ok
  end

  def run({:whisper, interlocutor, content}) do
    Logger.info("Whispering to #{interlocutor}")
    name = ChatClients.get_name()
    msg = name <> ": " <> content
    ChatClients.add_message(interlocutor, msg)
    :ok
  end
end
