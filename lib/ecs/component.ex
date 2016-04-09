defprotocol ECS.Component do
  @moduledoc """
  A protocol to allow specific component type checking.

  This protocol is intended to be used for a module with a struct directly
  representative of a component data structure.

  ## Examples

      # Define a custom "name" component.
      defmodule Component.Name do
        defstruct name: nil

        def new(name), do: %Component.Name{name: name}
      end

      defimpl ECS.Component, for: Component.Name do
        def type_of(_), do: :name
      end
  """

  @doc "Returns the type of component as an atom."
  def type_of(component)
end
