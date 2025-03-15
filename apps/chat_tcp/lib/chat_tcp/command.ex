defmodule Chat.Command do
  require Logger

  def parse(line) do
    Logger.info("Parsing: #{line}")

    case String.split(line, " ", parts: 2, trim: true) do
      ["NAME", msg] -> {:ok, {:add_client, String.trim(msg)}}
      ["WHISPER", args] -> get_whisper(args)
      _ -> {:error, :unknown_command}
    end
  end

  def get_whisper(args) do
    case String.split(args, " ", parts: 2, trim: true) do
      [interlocutor, content] ->
        {:ok, {:whisper, String.trim(interlocutor), String.trim(content)}}

      _ ->
        {:error, :wrong_whisper_format}
    end
  end

  def run(command)

  def run({:add_client, name}) do
    Logger.info("Adding client: #{name}")
    ChatClients.add_client(name)
    :ok
  end

  def run({:whisper, interlocutor, content}) do
    Logger.info("Whispering to #{interlocutor}: content: #{content}")
    name = ChatClients.get_name()
    msg = name <> ": " <> content
    ChatClients.add_message(interlocutor, msg)
    :ok
  end
end
