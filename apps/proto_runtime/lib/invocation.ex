defmodule Skitter.Runtime.Invocation do
  alias Skitter.Runtime.WorkflowInstance
  alias Skitter.Runtime.Orchestration

  def invoke_react_async(workflow, id, args) do
    Task.start(__MODULE__, :process_react, [workflow, id, args, self()])
  end

  def process_react(workflow, id, args, pid) do
    instance = workflow[id]
    {:ok, spits} = Orchestration.react(instance, args)

    Enum.each(spits, fn {val, address} ->
      WorkflowInstance.add_token(pid, val, address)
    end)

    GenServer.cast(pid, :react_finished)
  end
end
