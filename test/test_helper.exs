ExUnit.start()

defmodule Component.Test do
  defstruct value: nil

  def new(value), do: %__MODULE__{value: value}
end
