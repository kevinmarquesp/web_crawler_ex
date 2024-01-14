defmodule WebCrawlerEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :web_crawler_ex,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript_config(),
    ]
  end

  def escript_config do
    [main_module: WebCrawlerEx]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.0"},
      {:sqlite_ecto2, "~> 2.2"},
      {:httpoison, "~> 1.6"},
    ]
  end
end
