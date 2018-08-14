defmodule Skitter.Runtime.Invocation do
  import Skitter.Runtime.WorkflowInstance

  import Skitter.Component
  import Skitter.Workflow

  def invoke_react_async(workflow, id, args) do
    Task.start(__MODULE__, :process_react, [workflow, id, args, self()])
  end

  def process_react(workflow, id, args, pid) do
    links = get_links(workflow, id)
    {:ok, instance} = init_id(workflow, id)
    {:ok, _state, spits} = react(instance, args)

    Enum.map(spits, fn {port, val} ->
      Enum.map(Keyword.get(links, port, []), fn address ->
        add_token(pid, val, address)
      end)
    end)

    GenServer.cast(pid, :react_finished)
  end
end
