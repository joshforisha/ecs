defmodule ECS.System do
  @moduledoc """
  Functions to setup and control systems.

  A system iterates over entities with certain components, defined in `component_keys/0`, and calls `perform/1` on each
  entity. `perform/1` should return the entity_pid when the entity should continue to exist in the shared collection.

  ## Examples

      # Define a service to display entities' names.
      defmodule DisplayNames do
        @behaviour ECS.System

        # Accepts entities with a name component.
        def component_keys, do: [:name]

        def perform(entity) do
          # Displays the entity's name.
          IO.puts entity.name

          # Return the entity so that it is passed onto other systems.
          entity
        end
      end

      # Run entities through systems.
      updated_entities = ECS.System.run([DisplayNames], entities)
  """

  @callback component_keys() :: [atom]
  @callback perform(pid) :: pid

  @doc "Run `systems` over `entities`."
  def run([], entities), do: entities
  def run([system | systems], entities) do
    run(systems, Enum.map(entities, &iterate(system, &1)))
  end

  defp iterate(system, entity) do
    if Enum.reduce(system.component_keys, fn(key, okay) -> okay && Map.has_key?(entity, key) end) do
      system.perform(entity)
    else
      entity
    end
  end
end
