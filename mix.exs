defmodule ECS.Mixfile do
  use Mix.Project

  def project do
    [app: :ecs,
     version: "0.0.3",
     elixir: "~> 1.2",
     description: description,
     deps: deps,
     package: package]
  end

  def application do
    []
  end

  defp description do
    "An experimental Entity-Component System (ECS) game engine."
  end

  defp deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
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
