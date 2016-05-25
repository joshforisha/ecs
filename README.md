# ECS

[![build](https://img.shields.io/travis/joshforisha/ecs.svg?maxAge=2592000?style=flat-square)](https://travis-ci.org/joshforisha/ecs)
[![Hex.pm](https://img.shields.io/hexpm/v/ecs.svg?maxAge=2592000?style=flat-square)](https://hex.pm/packages/ecs)

Elixir Entity-Component System game engine

## Installation

Add ecs to your list of dependencies in `mix.exs`:

    def deps do
      [{:ecs, "~> 0.2.0"}]
    end

## Example

```elixir
# Define a simple component for containing a "name" value.
defmodule Component.Name do
  defstruct value: nil
  
  def new(name), do: %__MODULE__{value: name}
end

# Define a player entity that will contain components.
defmodule Entity.Player do
  def new(name) do
    ECS.Entity.new([
      Component.Name.new(name)
    ])
  end
end

# Define a service that prints out names of entities that have name components.
defmodule Service.DisplayName do
  @behaviour ECS.Service
  
  def component_types, do: [:name]
  
  def perform(entity) do
    IO.puts ECS.Entity.get(entity, :name)
    entity
  end
end

# Take our modules for a spin!
player = Entity.Player.new("Josh")
ECS.Service.run([Service.DisplayName], [player])
```
