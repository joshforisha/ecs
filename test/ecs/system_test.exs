defmodule ECS.SystemTest do
  use ExUnit.Case, async: true

  test "run/2 checks services' required types and calls `perform/1`" do
    defmodule CheckColor do
      use ECS.System

      def component_keys, do: [:test]

      def perform(entity) do
        assert entity.test.value == :blue
        entity
      end
    end

    ECS.System.run([CheckColor], [
      ECS.Entity.new([Component.Test.new(:blue)])
    ])
  end

  test "" do
    defmodule Counter do
      use ECS.System

      def component_keys, do: [:countable]

      def initial_state, do: 0

      def perform(entity, counter) do
        {entity, counter + 1}
      end
    end

    defmodule MultiplierCounter do
      use ECS.System

      def other_component_keys, do: [:multiplier]
      def component_keys, do: [:countable]

      def initial_state, do: 0

      def perform(entity, counter, multipliers) do
        factor =
          case multipliers do
            [] ->
              1

            m ->
              Enum.reduce(m, 0, fn e, x ->
                x + e.multiplier.factor
              end)
          end

        {entity, counter + 1 * factor}
      end
    end

    {_entities, results} =
      ECS.System.run([Counter, MultiplierCounter], [
        ECS.Entity.new([
          Component.Countable.new()
        ]),
        ECS.Entity.new([
          Component.Countable.new()
        ]),
        ECS.Entity.new([
          Component.Countable.new()
        ]),
        ECS.Entity.new([
          Component.Multiplier.new(4)
        ])
      ])

    [counter_result, counter_multiplier_result] = results

    assert(counter_result == 3)
    assert(counter_multiplier_result == 12)
  end
end
