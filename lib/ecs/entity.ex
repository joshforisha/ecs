defmodule ECS.Entity do
  @moduledoc """
  Functions to work with entities.

  An entity is a map container of components. Components are placed in the map with their key as a converted atom based
  on their struct atom. The key is created by converting the struct name after `Component` to snakecase, delimited
  by underscores.

  ## Examples

      # Create a monster entity.
      monster = ECS.Entity.new([
        Component.Health.new(100),
        Component.Name.new("Monty")
      ])

      # Output its name.
      IO.puts monster.name
      #=> "Monty"

      # Attach an attack component to the monster.
      attack_monster = ECS.Entity.attach(monster, Component.Attack.new(:melee, 24))
  """

  @doc "Attaches a `component` to an `entity`."
  def attach(entity, component) do
    Map.put_new(entity, component_atom(component), component)
  end

  @doc "Detaches a component at `key` from an `entity`."
  def detach(entity, key) do
    Map.delete(entity, key)
  end

  @doc "Returns a new entity map containing `components`."
  def new(components \\ []) do
    components
    |> Enum.map(&({component_atom(&1), &1}))
    |> Enum.into(%{})
  end

  @doc "Sets `entity` component at `key` to `value`."
  def set(entity, key, value) do
    update(entity, key, fn(_) -> value end)
  end

  @doc "Updates `entity`'s component value at `key` using `update_fn`."
  def update(entity, key, update_fn) do
    Map.update!(entity, key, update_fn)
  end

  defp component_atom(component) do
    component.__struct__
    |> Atom.to_string
    |> String.split(".")
    |> Enum.drop_while(&(&1 !== "Component"))
    |> Enum.drop(1)
    |> Enum.map(&(String.replace(&1, ~r/(.)([A-Z])/, "\\1_\\2")))
    |> Enum.reverse
    |> Enum.join("_")
    |> String.downcase
    |> String.to_atom
  end
end
