defmodule ChatRooms.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ChatRooms, name: ChatRooms}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
