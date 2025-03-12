defmodule ChatRoom.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ChatRoom, name: ChatRoom}
    ]

    opts = [strategy: :one_for_one, name: ChatRoom.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
