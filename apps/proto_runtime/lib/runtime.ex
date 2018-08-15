defmodule Runtime do
  use GenServer

  alias Skitter.Runtime.WorkflowManager, as: WorkflowManager

  # --- #
  # API #
  # --- #

  @slaves [:slave_1@Nimrodel, :slave_2@Nimrodel]

  def start_link(workflow, slaves \\ @slaves) do
    GenServer.start_link(__MODULE__, {workflow, slaves})
  end

  def react(rt, token) do
    GenServer.cast(rt, {:token, token})
  end

  # ------ #
  # Server #
  # ------ #

  def init({workflow, slaves}) do
    {:ok, {workflow, []}, {:continue, slaves}}
  end

  def handle_continue(slave_nodes, {workflow, []}) do
    pids =
      Enum.map(slave_nodes, fn node ->
        {:ok, pid} = WorkflowManager.start_remote_link(node, workflow)
        pid
      end)

    {:noreply, {workflow, pids}}
  end

  def handle_cast({:token, token}, state = {_, slaves}) do
    slave = Enum.random(slaves)
    WorkflowManager.react(slave, token)
    {:noreply, state}
  end

  def terminate(_, {_, slaves}) do
    Enum.map(slaves, fn slave -> WorkflowManager.stop(slave) end)
  end
end
