defmodule ChatClients.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_clients,
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

  def application do
    [
      extra_applications: [:logger],
      mod: {ChatClients.Application, []}
    ]
  end

  defp deps do
    []
  end
end
