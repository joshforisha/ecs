defmodule ECS.Routine do
  @moduledoc """
  Routines iterate over entities with certain components and update them.
  """

  @callback accepts?(Entity) :: Bool
  @callback run(Entity) :: Entity

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
