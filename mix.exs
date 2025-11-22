defmodule AstrologersBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :astrologers_bot,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer, :wx, :runtime_tools],
      mod: {AstrologersBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:telegex, "~> 1.9.0-rc.0"},
      {:finch, "~> 0.20.0"},
      {:multipart, "~> 0.4.0"}
    ]
  end
end
