defmodule Skitter.Runtime do
  use GenServer

  alias Skitter.Runtime.WorkflowManager
  alias Skitter.Runtime.Orchestration

  # --- #
  # API #
  # --- #

  def start_link(workflow, slaves) do
    GenServer.start_link(__MODULE__, {workflow, slaves})
  end

  def react(rt, token) do
    GenServer.cast(rt, {:token, token})
  end

  # ------ #
  # Server #
  # ------ #

  def init({workflow, slaves}) do
    {:ok, {nil, nil}, {:continue, {slaves, workflow}}}
  end

  def handle_continue({slave_nodes, workflow}, {nil, nil}) do
    workflow = Orchestration.create_workflow_template(slave_nodes, workflow)

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
