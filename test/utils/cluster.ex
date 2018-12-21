# Copyright 2018, Mathijs Saey, Vrije Universiteit Brussel

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Skitter.Test.Cluster do
  @hostname "127.0.0.1"
  @nodename "skitter_test_node"
  @fullname :"#{@nodename}@#{@hostname}"
  @hostname_charlst to_charlist(@hostname)

  @moduledoc """
  Provide support for distributed skitter tests.

  Based on: https://github.com/phoenixframework/phoenix_pubsub/blob/master/test/support/cluster.ex
  """

  def spawn_master(name \\ :test_master, workers \\ []) do
    ensure_distributed()
    spawn_node(name, :master, worker_nodes: workers)
  end

  def spawn_worker(name \\ :test_worker) do
    ensure_distributed()
    spawn_node(name, :worker, [])
  end

  def kill_node(node), do: :slave.stop(node)

  def rpc(n, mod, func, args \\ []), do: :rpc.block_call(n, mod, func, args)

  # Local Setup
  # -----------

  defp distribute_local do
    Node.start(@fullname)
    :erl_boot_server.start([@hostname_charlst])
  end

  defp cluster_ready?, do: Node.alive?() and Node.self() == @fullname
  defp ensure_distributed, do: unless cluster_ready?(), do: distribute_local()

  # Remote setup
  # ------------

  defp spawn_node(name, mode, extra_opts) do
    {:ok, node} = :slave.start(@hostname_charlst, name, spawn_args())

    add_code_paths(node)
    transfer_configuration(node)

    start_mix(node)
    start_skitter(node, mode, extra_opts)
    node
  end

  defp add_code_paths(n), do: rpc(n, :code, :add_paths, [:code.get_path()])

  defp transfer_configuration(node) do
    for {app_name, _, _} <- Application.loaded_applications do
      for {key, val} <- Application.get_all_env(app_name) do
        rpc(node, Application, :put_env, [app_name, key, val])
      end
    end
  end

  defp start_mix(node) do
    rpc(node, Application, :ensure_all_started, [:mix])
    rpc(node, Mix, :env, [Mix.env()])
  end

  defp start_skitter(node, mode, extra_opts) do
    for {k, v} <- extra_opts do
      rpc(node, Application, :put_env, [:skitter, k, v])
    end
    rpc(node, Application, :put_env, [:skitter, :mode, mode])
    rpc(node, Application, :ensure_all_started, [:skitter])
  end

  defp spawn_args do
    to_charlist(
      "-loader inet -hosts #{@hostname} -setcookie #{Node.get_cookie()}"
    )
  end
end
