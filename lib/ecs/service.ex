defmodule ECS.Service do
  @moduledoc """
  Functions to setup and control services.

  A service iterates over entities with certain components, defined in
  `component_types/0`, and calls `perform/1` on each entity. `perform/1` should
  return the entity_pid when the entity should continue to exist in the
  shared collection.

  ## Examples

      # Define a service to display entities' names.
      defmodule DisplayNames do
        @behaviour ECS.Service

        # Accepts entities with a "name" component.
        def component_types, do: [:name]

        def perform(entity) do
          # Displays the entity's name.
          IO.puts ECS.Entity.get(entity, :name)

          # Return the entity so that it is passed onto other services.
          entity
        end
      end

      # Run entities through systems.
      updated_entities = ECS.Service.run([DisplayNames], entities)
  """

  @callback component_types() :: [atom]
  @callback perform(pid) :: pid

  @doc "Run `services` over `entities`."
  def run([], entities), do: entities
  def run([service|services], entities) do
    next_entities = Enum.map(entities, &iterate(service, &1))
    run(services, next_entities)
  end

  defp iterate(service, entity) do
    cmp_types = service.component_types
    if ECS.Entity.has?(entity, cmp_types) do
      service.perform(entity)
    else
      entity
    end
  end
end
