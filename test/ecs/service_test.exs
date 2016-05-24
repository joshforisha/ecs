defmodule ECS.ServiceTest do
  use ExUnit.Case, async: true

  test "`run/2` checks services' required types and calls `perform/1`" do
    defmodule CheckColor do
      @behaviour ECS.Service
      def component_types, do: [:color]
      def perform(entity) do
        assert ECS.Entity.get(entity, :color) == "blue"
        entity
      end
    end

    defmodule CheckName do
      @behaviour ECS.Service
      def component_types, do: [:name]
      def perform(entity) do
        assert ECS.Entity.get(entity, :name) == "Bob"
        entity
      end
    end

    ECS.Service.run([CheckColor, CheckName], [
      ECS.Entity.new([%{type: :color, value: "blue"}]),
      ECS.Entity.new([%{type: :name, value: "Bob"}])
    ])
  end
end
