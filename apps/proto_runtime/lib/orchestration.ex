defmodule Skitter.Runtime.Orchestration do
  alias Skitter.Component
  alias Skitter.Runtime.ComponentInstance

  def create_instance(remotes, {comp, init, lnks}) do
    [hd | tl] = remotes

    if Component.state_change?(comp) do
      {:ok, inst} = ComponentInstance.start_remote_link(hd, comp, init)
      {{:send, inst, lnks}, tl ++ [hd]}
    else
      {{:spawn, {component, init}, lnks}, remotes}
    end
  end

  def create_workflow_template(remotes, workflow) do
    {workflow, _} =
      Enum.map_reduce(Map.to_list(workflow), fn {id, comp}, remotes ->
        create_instance(remotes, comp)
      end)

    Map.new(workflow)
  end
end
