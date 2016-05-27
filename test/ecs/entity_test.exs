defmodule ECS.EntityTest do
  use ExUnit.Case, async: true
  alias Component.Test

  test "attach/2 works as expected" do
    entity = ECS.Entity.new([])
    Agent.get(entity, &refute(Map.has_key?(&1, Test)))

    ECS.Entity.attach(entity, Test.new(:ok))
    Agent.get(entity, &assert(Map.has_key?(&1, Test)))
  end

  test "detach/2 works as expected" do
    entity = ECS.Entity.new([Test.new(:ok)])
    Agent.get(entity, &assert(Map.has_key?(&1, Test)))

    ECS.Entity.detach(entity, Test)
    Agent.get(entity, &refute(Map.has_key?(&1, Test)))
  end

  test "get/2 component value lookup is supported" do
    entity = ECS.Entity.new([Test.new(:ok)])
    assert ECS.Entity.get(entity, Test).value == :ok
  end

  test "has?/2 returns `true` when component is attached" do
    entity = ECS.Entity.new([Test.new(:ok)])
    assert ECS.Entity.has?(entity, Test)
  end

  test "has?/2 returns `false` when component is not attached" do
    entity = ECS.Entity.new([])
    refute ECS.Entity.has?(entity, Test)
  end

  test "has?/2 returns `true` when multiple components are attached" do
    entity = ECS.Entity.new([Test.new(:ok)])
    assert ECS.Entity.has?(entity, [Test])
  end

  test "has?/2 returns `false` when any listed components are not attached" do
    entity = ECS.Entity.new([Test.new(:ok)])
    refute ECS.Entity.has?(entity, [Test, Component.Empty])
  end

  test "new/1 returns an agent pid" do
    entity = ECS.Entity.new([])
    assert is_pid(entity)
  end

  test "new/1 creates entity with expected components" do
    ECS.Entity.new([Test.new(:ok)])
    |> Agent.get(&assert(Map.has_key?(&1, Test)))
  end

  test "set/3 changes component value" do
    entity = ECS.Entity.new([Test.new(:initial)])
    Agent.get(entity, &assert(Map.get(&1, Test).value == :initial))

    ECS.Entity.set(entity, Test, %{value: :updated})
    Agent.get(entity, &assert(Map.get(&1, Test).value == :updated))
  end

  test "update/3 changes component value" do
    entity = ECS.Entity.new([Test.new(:initial)])
    Agent.get(entity, &assert(Map.get(&1, Test).value == :initial))

    ECS.Entity.update(entity, Test, fn(cmp) ->
      assert cmp.value == :initial
      %Test{value: :updated}
    end)
    Agent.get(entity, &assert(Map.get(&1, Test).value == :updated))
  end
end
