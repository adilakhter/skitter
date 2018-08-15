defmodule Skitter.Runtime.ComponentInstance do
  use GenServer
  require Logger

  alias Skitter.Component

  # --- #
  # API #
  # --- #

  def start_remote_link(remote, comp, init) do
    Node.spawn_link(remote, __MODULE__, :start_and_notify, [comp, init, self()])

    pid =
      receive do
        {:start_ok, pid} -> pid
      end

    Process.link(pid)
    {:ok, pid}
  end

  @doc false
  def start_and_notify(comp, init, owner) do
    {:ok, pid} = GenServer.start_link(__MODULE__, {comp, init})
    send(owner, {:start_ok, pid})
  end

  def react(inst, args) do
    GenServer.call(inst, {:react, args})
  end

  # ------ #
  # Server #
  # ------ #

  def init({comp, init}) do
    {:ok, nil, {:continue, {comp, init}}}
  end

  def handle_continue({comp, args}, nil) do
    {:ok, instance} = Component.init(comp, args)
    {:noreply, instance}
  end

  def handle_call({:react, args}, _, instance) do
    {:ok, instance, spits} = Component.react(instance, args)
    {:reply, {:ok, spits}, instance}
  end
end
