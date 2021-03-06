# Copyright 2018, 2019 Mathijs Saey, Vrije Universiteit Brussel

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Skitter.Runtime.Nodes.Notifier do
  @moduledoc false
  @topics [:node_join, :node_leave]
  use GenServer, restart: :transient

  # ----------- #
  # Private API #
  # ----------- #

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def notify_join(node) do
    GenServer.cast(__MODULE__, {:node_join, node})
  end

  def notify_leave(node, reason) do
    GenServer.cast(__MODULE__, {:node_leave, node, reason})
  end

  # ------ #
  # Server #
  # ------ #

  def init(_) do
    {:ok, Map.new()}
  end

  def handle_cast({:subscribe, pid, topic}, state) when topic in @topics do
    state = Map.update(state, topic, MapSet.new([pid]), &MapSet.put(&1, pid))
    {:noreply, state}
  end

  def handle_cast({:unsubscribe, pid, topic}, state) when topic in @topics do
    state = Map.update(state, topic, MapSet.new(), &MapSet.delete(&1, pid))
    {:noreply, state}
  end

  def handle_cast({:node_join, node}, state) do
    notify(:node_join, {:node_join, node}, state)
    {:noreply, state}
  end

  def handle_cast({:node_leave, node, reason}, state) do
    notify(:node_leave, {:node_leave, node, reason}, state)
    {:noreply, state}
  end

  defp notify(topic, message, state) do
    state
    |> Map.get(topic, MapSet.new())
    |> MapSet.to_list()
    |> Enum.each(&send(&1, message))
  end
end
