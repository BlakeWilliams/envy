defmodule Envy.Mixfile do
  use Mix.Project

  def project do
    [app: :envy,
     version: "1.1.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.10", only: :dev}]
  end

  def package do
    %{
      description: "A package for managing env files",
      licenses: ["MIT"],
      maintainers: ["Blake Williams"],
      links: %{github: "https://github.com/BlakeWilliams/envy"},
    }
  end
end
