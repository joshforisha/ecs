defmodule ECS.ComponentTest do
  use ExUnit.Case, async: true

  test "type_of/1: type can be obtained" do
    assert ECS.Component.type_of(%{type: :ok}) == :ok
  end

  test "type_of/1: type lookup fails without `type` key" do
    assert_raise(FunctionClauseError, fn -> ECS.Component.type_of(%{}) end)
  end

  test "update/2: value is updated as expected" do
    cmp = %{value: :initial}
    assert ECS.Component.value_of(cmp) == :initial

    updated_cmp = ECS.Component.update(cmp, fn(c) ->
      assert c == :initial
      :updated
    end)
    assert ECS.Component.value_of(updated_cmp) == :updated
  end

  test "value_of/1: value can be obtained" do
    assert ECS.Component.value_of(%{value: :ok}) == :ok
  end

  test "value_of/1: value lookup fails without `value` key" do
    assert_raise(FunctionClauseError, fn -> ECS.Component.value_of(%{}) end)
  end
end
