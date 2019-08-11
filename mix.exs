defmodule LeaguesWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :leagues_web,
      version: "0.1.0",
      elixir: "~> 1.7.0-rc.1",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      applications: [:prometheus_ex],
      extra_applications: [:logger, :plug_cowboy, :poison, :exprotobuf, :prometheus, :prometheus_ex, :stream_data, :prometheus_plugs, :prometheus_process_collector],      
      mod: {LeaguesWeb.Application, []}
    ]
  end

  defp deps do
    [
      # Plug (Composable Modules for web application) AND Cowboy (HTTP Server)
      {:plug_cowboy, "~> 2.0"},
      # Json handling
      {:poison, "~> 4.0.1"},
      # Protobuffers
      {:exprotobuf, "~> 1.2.9"},
      # Property based testing
      {:stream_data, "~> 0.1"},
      # Documentation generation
      {:ex_doc, "~> 0.11", only: :dev},	
      # Tool for packaging Elixir applications      
      {:distillery, "~> 2.0"},
      # Metrics
      {:prometheus, "~> 4.0", override: true},
      {:prometheus_ex, "~> 3.0"},
      {:prometheus_plugs, "~> 1.1"},
      {:prometheus_process_collector, "~> 1.3"}
      
    ]
  end
end
