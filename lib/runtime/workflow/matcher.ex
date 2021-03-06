# Copyright 2018, Mathijs Saey, Vrije Universiteit Brussel

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Skitter.Runtime.Workflow.Matcher do
  @moduledoc false

  alias Skitter.Runtime.Workflow.Store

  def new, do: Map.new()

  def empty?(map) when map == %{}, do: true
  def empty?(_), do: false

  def add(matcher, token = {id, _, _}, ref) do
    {entry, arity} = get_and_update_entry(matcher, token, ref)

    if map_size(entry) == arity do
      {:ready, Map.delete(matcher, id), id, entry_to_args(ref, id, entry)}
    else
      {:ok, Map.put(matcher, id, {entry, arity})}
    end
  end

  defp get_and_update_entry(matcher, {id, port, data}, ref) do
    case Map.get(matcher, id) do
      nil -> {%{port => data}, get_meta(ref, id).arity}

      {entry, arity} -> {Map.put(entry, port, data), arity}
    end
  end

  defp entry_to_args(ref, id, entry) do
    ports = get_meta(ref, id).in_ports
    Enum.map(ports, fn port -> entry[port] end)
  end

  defp get_meta(ref, id), do: Store.get(ref, id).meta
end
