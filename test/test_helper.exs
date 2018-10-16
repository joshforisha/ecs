ExUnit.start()

defmodule Component.Empty do
end

defmodule Component.Test do
  defstruct value: nil

  def new(value), do: %__MODULE__{value: value}
end

defmodule Component.Multiplier do
  defstruct factor: 1

  def new(value), do: %__MODULE__{factor: value}
end

defmodule Component.Countable do
  defstruct []

  def new(), do: %__MODULE__{}
end
