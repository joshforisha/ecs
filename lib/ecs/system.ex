defmodule ECS.System do
  @moduledoc """
  Functions to setup and control systems.

  # Basic Usage

  A system iterates over entities with certain components, defined in
  `component_keys/0`, and calls `perform/1` on each entity. `perform/1` should
  return the entity_pid when the entity should continue to exist in the shared
  collection.

  ## Examples

      # Define a service to display entities' names.
      defmodule DisplayNames do
        @use ECS.System

        # Accepts entities with a name component.
        def component_keys, do: [:name]

        def perform(entity) do
          # Displays the entity's name.
          IO.puts entity.name

          # Return the entity so that it is passed onto other systems.
          entity
        end
      end

      # Run entities through systems.
      updated_entities = ECS.System.run([DisplayNames], entities)

  # Stateful System

  A system may also specify `initial_state/0` (`fn -> nil end` by default) which
  will be passed as the second argument to `perform/2`. `perform/2` should
  return a tuple in the form `{entity, state}` where state will be the new state
  for the next `perform/2` call. You can use this, for example, to keep track of
  changes made, such as to note how many entities actually changed. This state
  will be returned by `run/2` in the second element of the tuple as a list,
  where each item in the list is the corresponding state from the System passed
  to `run/2`.

  This could be used, for example, to track collisions amongst collidable
  components for later use.

  ## Examples

      defmodule Counter do
        use ECS.System
        def component_keys, do: [:countable]
        def initial_state, do: 0
        def perform(entity, counter) do
          {entity, counter + 1}
        end
      end

      systems = [Counter, MultiplierCounter]
      entities = [%{countable: true}]
      {_, [num_countable_entities]} = ECS.System.run(systems, entities)

  # Interacting with Multiple Components

  Often, a system requires knowledge of multiple components in order to have the
  intended affects, such as the aforementions collision resolution. You can
  specify `other_component_keys/0` similar to `component_keys/0` which will
  cause affiliated entities to be passed to `perform/3` as the third argument.

  ## Examples

      defmodule MultiplyCounter do
        use ECS.System
        def other_component_keys, do: [:multiplier]
        def component_keys, do: [:countable]
        def initial_state, do: 0
        def perform(entity, counter, multipliers) do
          factor = case multipliers do
            [] -> 1
            m ->
              Enum.reduce(m, 0, fn e, x ->
                x + e.multiplier.factor
              end)
          end

        {entity, counter + 1 * factor}
      end

  ## Pre/Post Hooks

  You may also specify `pre_perform` and `post_perform` which can be used to
  transform the state and/or entities before any `perform` calls are made. This
  can be used for more dynamic filtering or transformation from within the
  system.

  """

  @doc "Defines the component keys to search for that the system processes."
  @callback component_keys() :: [atom]

  @doc "Defines the component keys to search for that the system's entities may interact with."
  @callback other_component_keys() :: [atom]

  @doc "Defines the initial state for a system's run cycle."
  @callback initial_state() :: state :: any

  @doc "Called before any `perform` calls are made in order to transform the entities list or the state."
  @callback pre_perform(entities :: [pid], state :: any, opts :: Keyword.t()) ::
              {entities :: [pid], state :: any}

  @doc "Modifies the given `entity` and, optionally, the system's current run's `state`."
  @callback perform(
              entity :: pid,
              state :: term | nil,
              other_entities :: [pid] | [],
              opts :: Keyword.t()
            ) :: {entity :: pid, state :: any} | entity :: pid

  @doc "Called after all `perform` calls are made in order to transform the entities list or the state."
  @callback post_perform(entities :: [pid], state :: any, opts :: Keyword.t()) ::
              {entities :: [pid], state :: any}

  defmacro __using__(_opts) do
    quote do
      @behaviour ECS.System

      def initial_state(), do: nil
      defoverridable initial_state: 0

      def other_component_keys(), do: []
      defoverridable other_component_keys: 0

      def pre_perform(entities, state, _opts \\ nil), do: {entities, state}
      defoverridable pre_perform: 3

      def post_perform(entities, state, _opts \\ nil), do: {entities, state}
      defoverridable post_perform: 3

      def perform(entity) do
        entity
      end

      defoverridable perform: 1

      def perform(entity, nil) do
        perform(entity)
      end

      def perform(entity, state) do
        {entity, state}
      end

      defoverridable perform: 2

      def perform(entity, state, other_entities) do
        perform(entity, state)
      end

      defoverridable perform: 3

      def perform(entity, state, other_entities, opts) do
        perform(entity, state, other_entities)
      end

      defoverridable perform: 4
    end
  end

  @doc "Run `systems` over `entities`."
  def run(systems, entities, opts \\ []) do
    {entities, states} =
      Enum.reduce(systems, {entities, []}, fn system, {entities, states} ->
        {entities, state} = do_run(system, entities, opts)
        {entities, [state | states]}
      end)

    {entities, Enum.reverse(states)}
  end

  defp do_run([], entities, _opts), do: {entities, nil}

  defp do_run(system, entities, opts) do
    state = system.initial_state()
    {entities, state} = system.pre_perform(entities, state, opts)

    other_entities =
      case system.other_component_keys do
        [] ->
          []

        keys ->
          Enum.filter(
            entities,
            &Enum.reduce(keys, true, fn key, okay ->
              okay && Map.has_key?(&1, key)
            end)
          )
      end

    {entities, state} =
      Enum.map_reduce(entities, state, fn entity, state ->
        iterate(system, entity, state, other_entities, opts)
      end)

    system.post_perform(entities, state, opts)
  end

  defp iterate(system, entity, state, other_entities, opts) do
    if Enum.reduce(system.component_keys, true, fn key, okay ->
         okay && Map.has_key?(entity, key)
       end) do
      case system.perform(entity, state, other_entities, opts) do
        {entity, state} -> {entity, state}
        entity -> {entity, state}
      end
    else
      {entity, state}
    end
  end
end
