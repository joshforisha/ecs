defmodule ECS.Entity do
  @moduledoc """
  Functions to work with entities.

  An entity is an agent-based container for a map of components. Components are
  placed in the map with their key as their struct reference atom.

  ## Examples

      # Create a monster entity.
      monster = ECS.Entity.new([
        Component.Health.new(100),
        Component.Name.new("Monty")
      ])

      # Output its name.
      monster
      |> ECS.Entity.get(Component.Name)
      |> IO.puts
      #=> "Monty"

      # Attach an attack component to the monster.
      monster
      |> ECS.Entity.attach(Component.Attack.new(:melee, 24))
  """

  @doc "Attaches a `component` to an `entity`."
  def attach(entity, component) do
    entity
    |> Agent.update(&Map.put_new(&1, component.__struct__, component))
    entity
  end

  @doc "Detaches a component of type `cmp_type` from an `entity`."
  def detach(entity, cmp_type) do
    entity
    |> Agent.update(&Map.delete(&1, cmp_type))
    entity
  end

  @doc "Retrieves a component's value of type `cmp_type` from an `entity`."
  def get(entity, cmp_type) do
    entity
    |> Agent.get(&Map.get(&1, cmp_type))
  end

  @doc "Checks whether an `entity` has component(s) of `cmp_type`."
  def has?(entity, cmp_types) when is_list(cmp_types) do
    cmp_types
    |> List.foldl(true, &(&2 && has?(entity, &1)))
  end

  def has?(entity, cmp_type) do
    entity
    |> Agent.get(&(&1))
    |> Map.has_key?(cmp_type)
  end

  @doc "Returns a new agent pid wrapping `components` as a map."
  def new(components) do
    {:ok, entity} = Agent.start(fn ->
      components
      |> Enum.map(&({&1.__struct__, &1}))
      |> Enum.into(%{})
    end)
    entity
  end

  @doc "Sets `entity` component of `cmp_type` to `value`."
  def set(entity, cmp_type, value) do
    update(entity, cmp_type, fn(_) -> value end)
  end

  @doc "Updates `entity`'s component value of `cmp_type` using `update_fn`."
  def update(entity, cmp_type, update_fn) do
    entity
    |> Agent.update(&Map.update!(&1, cmp_type, update_fn))
  end
end
