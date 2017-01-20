defmodule ECS.Mixfile do
  use Mix.Project

  def project do
    [app: :ecs,
     version: "0.5.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:dogma, "~> 0.1", only: :dev},
     {:earmark, "~> 1.0", only: :dev},
     {:ex_doc, "~> 0.14", only: :dev}]
  end

  defp description do
    "An experimental Entity-Component System (ECS) game engine."
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Josh Forisha"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/joshforisha/ecs"
     }]
  end
end
