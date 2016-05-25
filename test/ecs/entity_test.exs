defmodule ECS.EntityTest do
  use ExUnit.Case, async: true

  test "attach/2 works as expected" do
    entity = ECS.Entity.new([])
    Agent.get(entity, &refute(Map.has_key?(&1, :test)))

    ECS.Entity.attach(entity, Component.Test.new(:ok))
    Agent.get(entity, &assert(Map.has_key?(&1, :test)))
  end

  test "detach/2 works as expected" do
    entity = ECS.Entity.new([Component.Test.new(:ok)])
    Agent.get(entity, &assert(Map.has_key?(&1, :test)))

    ECS.Entity.detach(entity, :test)
    Agent.get(entity, &refute(Map.has_key?(&1, :test)))
  end

  test "get/2 component value lookup is supported" do
    entity = ECS.Entity.new([Component.Test.new(:ok)])
    assert ECS.Entity.get(entity, :test) == :ok
  end

  test "has?/2 returns `true` when component is attached" do
    entity = ECS.Entity.new([Component.Test.new(:ok)])
    assert ECS.Entity.has?(entity, :test)
  end

  test "has?/2 returns `false` when component is not attached" do
    entity = ECS.Entity.new([])
    refute ECS.Entity.has?(entity, :test)
  end

  test "has_all?/2 returns `true` when components are attached" do
    entity = ECS.Entity.new([Component.Test.new(:ok)])
    assert ECS.Entity.has_all?(entity, [:test])
  end

  test "has_all?/2 returns `false` when any components are not attached" do
    entity = ECS.Entity.new([Component.Test.new(:test_one)])
    refute ECS.Entity.has_all?(entity, [:test_one, :test_two])
  end

  test "new/1 returns an agent pid" do
    entity = ECS.Entity.new([])
    assert is_pid(entity)
  end

  test "new/1 creates entity with expected components" do
    entity = ECS.Entity.new([Component.Test.new(:ok)])
    Agent.get(entity, &assert(Map.has_key?(&1, :test)))
  end

  test "set/3 changes component value" do
    entity = ECS.Entity.new([Component.Test.new(:initial)])
    Agent.get(entity, &assert(Map.get(&1, :test).value == :initial))

    ECS.Entity.set(entity, :test, :updated)
    Agent.get(entity, &assert(Map.get(&1, :test).value == :updated))
  end

  test "update/3 changes component value" do
    entity = ECS.Entity.new([Component.Test.new(:initial)])
    Agent.get(entity, &assert(Map.get(&1, :test).value == :initial))

    ECS.Entity.update(entity, :test, fn(value) ->
      assert value == :initial
      :updated
    end)
    Agent.get(entity, &assert(Map.get(&1, :test).value == :updated))
  end
end
