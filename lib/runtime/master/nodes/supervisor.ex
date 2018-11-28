# Copyright 2018, Mathijs Saey, Vrije Universiteit Brussel

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Skitter.Runtime.Master.Nodes.Supervisor do
  @moduledoc false
  use Supervisor

  alias Skitter.Runtime.Master.Nodes

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_) do
    children = [
      Nodes.Registry,
      Nodes.MonitorSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_all, max_restarts: 0)
  end
end
