defmodule ECS.ComponentTest do
  use ExUnit.Case, async: true

  test "set/2 sets the value as expected" do
    %{value: new_value} = ECS.Component.set(%{value: :initial}, :test)
    assert new_value == :test
  end

  test "type_of/1 properly figures type" do
    assert ECS.Component.type_of(Component.Test.new(nil)) == :test
  end

  test "update/2 updates value as expected" do
    cmp = %{value: :initial}
    %{value: new_value} = ECS.Component.update(cmp, fn(c) ->
      assert c == :initial
      :updated
    end)
    assert new_value == :updated
  end

  test "value_of/1 retrieves the value as expected" do
    assert ECS.Component.value_of(%{value: :ok}) == :ok
  end

  test "value_of/1 fails without `value` key" do
    assert_raise(FunctionClauseError, fn -> ECS.Component.value_of(%{}) end)
  end
end
