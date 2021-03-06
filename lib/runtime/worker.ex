# Copyright 2018, 2019 Mathijs Saey, Vrije Universiteit Brussel

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Skitter.Runtime.Worker do
  @moduledoc false

  use GenServer
  require Logger

  # --- #
  # API #
  # --- #

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def register_master(node) do
    GenServer.cast({__MODULE__, node}, {:add_master, Node.self()})
  end

  def remove_master(node) do
    GenServer.cast({__MODULE__, node}, {:remove_master, Node.self()})
  end

  def verify_worker(node) do
    !is_nil(:rpc.call(node, GenServer, :whereis, [__MODULE__]))
  end

  # ------ #
  # Server #
  # ------ #

  @impl true
  def init(_) do
    {:ok, MapSet.new()}
  end

  @impl true
  def handle_cast({:add_master, master}, set) do
    Logger.info("Registering master: #{master}")
    {:noreply, MapSet.put(set, master)}
  end

  def handle_cast({:remove_master, master}, set) do
    Logger.info("Removing master: #{master}")
    {:noreply, MapSet.delete(set, master)}
  end
end

