# Copyright 2018, Mathijs Saey, Vrije Universiteit Brussel

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Skitter.Runtime.Worker do
  @moduledoc false

  alias __MODULE__
  alias Skitter.Runtime.Nodes

  def supervisor, do: Worker.Supervisor

  def verify_worker(node) do
    Nodes.on(node, __MODULE__, :verify_worker, [])
  end

  def verify_local_worker() do
    !is_nil(GenServer.whereis(__MODULE__.SuperVisor))
  end
end
