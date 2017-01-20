defmodule ECS.EntityTest do
  use ExUnit.Case, async: true
  alias Component.Test

  test "attach/2 works as expected" do
    entity = ECS.Entity.new([])
    refute Map.has_key?(entity, :test)

    entity = ECS.Entity.attach(entity, Test.new(:ok))
    assert Map.has_key?(entity, :test)
  end

  test "detach/2 works as expected" do
    entity = ECS.Entity.new([Test.new(:ok)])
    assert Map.has_key?(entity, :test)

    entity = ECS.Entity.detach(entity, :test)
    refute Map.has_key?(entity, :test)
  end

  test "new/1 returns a map" do
    entity = ECS.Entity.new([])
    assert is_map(entity)
  end

  test "new/1 creates entity map with expected components" do
    entity = ECS.Entity.new([Test.new(:ok)])
    assert Map.has_key?(entity, :test)
  end

  test "set/3 changes component value" do
    entity = ECS.Entity.new([Test.new(:initial)])
    assert entity.test.value == :initial

    entity = ECS.Entity.set(entity, :test, %{value: :updated})
    assert entity.test.value == :updated
  end

  test "update/3 changes component value" do
    entity = ECS.Entity.new([Test.new(:initial)])
    assert entity.test.value == :initial

    entity = ECS.Entity.update(entity, :test, fn(cmp) ->
      assert cmp.value == :initial
      %Test{value: :updated}
    end)
    assert entity.test.value == :updated
  end

  test "components are retrievable by key" do
    entity = ECS.Entity.new([Test.new(:initial)])
    assert entity.test.value === :initial
  end
end
