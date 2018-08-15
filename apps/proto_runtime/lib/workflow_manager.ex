defmodule Skitter.Runtime.WorkflowManager do
  use GenServer
  require Logger

  alias Skitter.Runtime.WorkflowInstance, as: WorkflowInstance

  # --- #
  # API #
  # --- #

  def start_remote_link(remote, workflow) do
    Node.spawn(remote, __MODULE__, :start_and_notify, [workflow, self()])

    pid =
      receive do
        {:start_ok, pid} -> pid
      end

    Process.link(pid)
    {:ok, pid}
  end

  def stop(remote) do
    GenServer.stop(remote)
  end

  def react(manager, token) do
    GenServer.cast(manager, {:token, token})
  end

  @doc false
  def start_and_notify(workflow, owner) do
    {:ok, pid} = GenServer.start(__MODULE__, workflow)
    send(owner, {:start_ok, pid})
  end

  # ------ #
  # Server #
  # ------ #

  def init(workflow) do
    Logger.info("Workflow manager on `#{Node.self()}` started")
    {:ok, workflow}
  end

  def handle_cast({:token, token}, workflow) do
    {:ok, pid} = WorkflowInstance.start_link(workflow)
    WorkflowInstance.add_token(pid, token)
    {:noreply, workflow}
  end
end
