defmodule Chat.Application do
  use Application

  @impl true
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Chat.Room.Supervisor, name: Chat.Room.Supervisor},
      Supervisor.child_spec({Task, fn -> Chat.accept(port) end}, restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
