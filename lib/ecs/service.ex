defmodule ECS.Service do
  @moduledoc """
  Functions to setup and control services.

  A service iterates over entities with certain components, and `perform`s an
  action with them.

  ## Examples

      # Define a service to display entities' names.
      defmodule Service.DisplayNames do
        # Accepts entities with a name component.
        def accepts?(entity) do
          ECS.Entity.has?(entity, :name)
        end

        # Displays the entity's name
        def perform(entity) do
          IO.puts ECS.Entity.get(entity, :name)
        end
      end
  """

  @callback accepts?(pid) :: Bool
  @callback perform(pid) :: any

  @doc "Run `service` over `entities`."
  def run(entities, []), do: entities
  def run(entities, [service|services]) do
    entities
    |> Enum.map(&iterate(&1, service))
    |> run(services)
  end

  defp iterate(entity, service) do
    if service.accepts?(entity), do: service.run(entity)
    entity
  end
end
