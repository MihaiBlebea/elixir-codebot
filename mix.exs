defmodule Codebot.MixProject do
    use Mix.Project

    def project do
        [
            app: :codebot,
            version: "0.1.0",
            elixir: "~> 1.10",
            elixirc_paths: elixirc_paths(Mix.env),
            start_permanent: Mix.env() == :prod,
            deps: deps()
        ]
    end

    # Run "mix help compile.app" to learn about applications.
    def application do
        [
            extra_applications: [:logger, :mongodb_driver],
            mod: {Codebot, []}
        ]
    end

    defp elixirc_paths(_), do: ["lib", "web"]

    # Run "mix help deps" to learn about dependencies.
    defp deps do
        [
            {:plug_cowboy, "~> 2.0"},
            {:cors_plug, "~> 1.2"},
            {:httpoison, "~> 1.6"},
            {:floki, "~> 0.29.0"},
            {:json, "~> 1.2"},
            {:ex_doc, "~> 0.22", only: :dev, runtime: false},
            {:mongodb_driver, "~> 0.5"}
        ]
    end
end
