defmodule DieScheiteApi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :die_scheite_api,
      version: "0.4.3",
      elixir: "~> 1.8.1",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {DieScheiteApi.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:distillery, "~> 2.0.9", runtime: false},
      {:esjql, git: "https://github.com/DrunkenInfant/esjql.git", tag: "0.3.1"},
      {:httpoison, "~> 1.3.0"},
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
    ]
  end
end
