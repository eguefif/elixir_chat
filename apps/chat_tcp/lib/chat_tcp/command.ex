defmodule Chat.Command do
  require Logger

  def parse(line) do
    Logger.info("Parsing: #{line}")

    case String.split(line, " ", parts: 2, trim: true) do
      ["NAME", msg] -> {:ok, {:add_client, String.trim(msg)}}
      ["WHISPER", args] -> get_whisper(args)
      ["JOIN", room] -> {:ok, {:join_room, String.trim(room)}}
      ["LEAVE", room] -> {:ok, {:leave_room, String.trim(room)}}
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

  def run({:join_room, room}) do
    Logger.info("Joining room #{room}")
    name = ChatClients.get_name()

    if name != :unknown_client do
      ChatRooms.add_client(room, name)
      :ok
    else
      {:error, :unnamed_client}
    end
  end

  def run({:leave_room, room}) do
    Logger.info("Leaving room #{room}")
    name = ChatClients.get_name()

    if name != nil do
      ChatRooms.remove_client(room, name)
      :ok
    else
      {:error, :unnamed_client}
    end
  end
end
