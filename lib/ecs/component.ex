defprotocol ECS.Component do
  @moduledoc """
  A protocol to allow custom specific component definitions.

  The default Any implementation assumes a struct definition with a `value`
  property that represents the primary raw data. Components can be customized
  with any other structure by implementing this protocol directly.

  The Any implementation of `type_of/1` returns an atom of the interpreted name
  of the component struct, where anything before and including "Component." in
  the component's name will be ignored. For example, "ECS.Component.Test.String"
  would have a calculated type atom of `:string_test`.

  ## Example

      # Define a custom "name" component.
      defmodule Component.Name do
        defstruct value: nil
        def new(name), do: %__MODULE__{value: name}
      end
  """

  @fallback_to_any true

  @doc """
  Sets the underlying value of the `component` to `value`.

  ## Example

      Component.Name.new(nil)
      |> ECS.Component.set("Josh")
      #=> "Josh"
  """
  def set(component, value)

  @doc """
  Converts a component struct to a "type" atom.

  ## Example

      Component.Name.new("Josh")
      |> ECS.Component.type_of
      #=> :name
  """
  def type_of(component)

  @doc ~S"""
  Updates the underlying value of the `component` using `update_fn`.

  ## Example

      Component.Name.new("Josh")
      |> ECS.Component.update(&("#{&1} F"))
      #=> %Component.Name{value: "Josh F"}
  """
  def update(component, update_fn)

  @doc """
  Retrieves the underlying value of the `component`.

  ## Example

      Component.Name.new("Josh")
      |> ECS.Component.value_of
      #=> "Josh"
  """
  def value_of(component)
end

defimpl ECS.Component, for: Any do
  def set(%{value: _value} = component, value) do
    update(component, fn(_) -> value end)
  end

  def type_of(%{value: _value} = component) do
    full_name = component.__struct__
    |> Macro.to_string
    |> String.split(".")
    |> Enum.reverse
    |> Enum.map(&String.downcase(&1))
    |> Enum.join("_")

    Regex.replace(~r/_component\S*$/, full_name, "")
    |> String.to_atom
  end

  def update(%{value: _value} = component, update_fn) do
    Map.update!(component, :value, update_fn)
  end

  def value_of(%{value: _value} = component), do: Map.get(component, :value)
end
