defmodule ECS.Routine do
  @moduledoc """
  Functions to setup and control routines.

  A routine iterates over entities with certain components, and `perform`s an
  action with them.

  ## Examples

      # Define a routine to display entities' names.
      defmodule Routine.DisplayNames do
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

  @doc "Run `routines` over `entities`."
  def run(entities, []), do: entities
  def run(entities, [routine|rs]) do
    entities
    |> Enum.map(&iterate(&1, routine))
    |> run(rs)
  end

  defp iterate(entity, routine) do
    if routine.accepts?(entity), do: routine.run(entity)
    entity
  end
end
