defmodule ECS.ComponentTest do
  use ExUnit.Case, async: true

  test "type can be obtained" do
    assert ECS.Component.type_of(%{type: :ok}) == :ok
  end

  test "type lookup fails without `type` key" do
    assert_raise(FunctionClauseError, fn -> ECS.Component.type_of(%{}) end)
  end

  test "value is updated with update/2 as expected" do
    cmp = %{value: :initial}
    assert ECS.Component.value_of(cmp) == :initial

    updated_cmp = ECS.Component.update(cmp, fn(c) ->
      assert c == :initial
      :updated
    end)
    assert ECS.Component.value_of(updated_cmp) == :updated
  end

  test "value can be obtained" do
    assert ECS.Component.value_of(%{value: :ok}) == :ok
  end

  test "value lookup fails without `value` key" do
    assert_raise(FunctionClauseError, fn -> ECS.Component.value_of(%{}) end)
  end
end
