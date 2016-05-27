defmodule ECS.SystemTest do
  use ExUnit.Case, async: true

  test "run/2 checks services' required types and calls `perform/1`" do
    defmodule CheckColor do
      @behaviour ECS.System
      def component_types, do: [:test]
      def perform(entity) do
        assert ECS.Entity.get(entity, :test) == :blue
        entity
      end
    end

    ECS.System.run([CheckColor], [
      ECS.Entity.new([Component.Test.new(:blue)])
    ])
  end
end
