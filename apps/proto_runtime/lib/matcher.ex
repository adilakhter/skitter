defmodule Skitter.Runtime.Matcher do
  def new(), do: Map.new()

  def empty?(%{}), do: true
  def empty?(_), do: false

  def add(matcher, {id, port}, data, workflow) do
    {record, arity} =
      case Map.get(matcher, id) do
        nil ->
          {_, _c, _i, _l, arity} = workflow[id]
          {%{port => data}, arity}

        {record, arity} ->
          {Map.put(record, port, data), arity}
      end

    if map_size(record) == arity do
      {:trigger, Map.delete(matcher, id), id, record}
    else
      {:ok, Map.put(matcher, id, {record, arity})}
    end
  end
end
