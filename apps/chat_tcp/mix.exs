defmodule ChatTcp.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_tcp,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ChatTcp.Application, []}
    ]
  end

  defp deps do
    [
      {:chat_rooms, in_umbrella: true},
      {:chat_clients, in_umbrella: true}
    ]
  end
end
