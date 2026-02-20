defmodule Devvy.MixProject do
  use Mix.Project

  def project do
    [
      app: :devvy,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  def application do
    [
      mod: {Devvy.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:liquid, github: "biznitos/liquid-elixir", branch: "master", override: true},
      {:jason, "~> 1.4"},
      {:earmark, "~> 1.4"},
      {:html_sanitize_ex, "~> 1.4"},
      {:html_entities, "~> 0.5"},
      {:number, "~> 1.0"},
      {:timex, "~> 3.7"},
      {:bandit, "~> 1.5"},
      {:file_system, "~> 1.0"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:dns_cluster, "~> 0.2.0"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
