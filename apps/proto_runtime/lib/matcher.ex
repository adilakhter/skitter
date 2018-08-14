defmodule Skitter.Runtime.Matcher do
  import Skitter.Component
  import Skitter.Workflow

  def new(), do: Map.new()

  def empty?(%{}), do: true
  def empty?(_), do: false

  def add(matcher, {id, port}, data, workflow) do
    entry =
      {record, arity} =
      case Map.get(matcher, id) do
        nil -> {%{port => data}, in_ports_size(get_component(workflow, id))}
        {record, arity} -> {Map.put(record, port, data), arity}
      end

    if map_size(record) == arity do
      component = get_component(workflow, id)
      arguments = entry_to_args(record, component)
      {:trigger, Map.delete(matcher, id), id, arguments}
    else
      {:ok, Map.put(matcher, id, entry)}
    end
  end

  defp entry_to_args(entry, component) do
    Enum.map(in_ports(component), fn port -> entry[port] end)
  end
end
