defmodule Skitter.Runtime.Orchestration do
  alias Skitter.Component
  alias Skitter.Runtime.ComponentInstance

  def create_instance(remotes, {comp, init, lnks}) do
    [hd | tl] = remotes
    arity = comp |> Component.in_ports() |> length()

    if Component.state_change?(comp) do
      {:ok, inst} = ComponentInstance.start_remote_link(hd, comp, init)
      {{:send, comp, inst, lnks, arity}, tl ++ [hd]}
    else
      {{:spawn, comp, init, lnks, arity}, remotes}
    end
  end

  def create_workflow_template(remotes, workflow) do
    {workflow, _} =
      Enum.map_reduce(Map.to_list(workflow), remotes, fn {id, comp}, remotes ->
        {entry, remotes} = create_instance(remotes, comp)
        {{id, entry}, remotes}
      end)

    Map.new(workflow)
  end

  def react({:send, comp, inst, lnks, _arity}, args) do
    args = entry_to_args(comp, args)
    {:ok, spits} = ComponentInstance.react(inst, args)
    {:ok, port_to_address(spits, lnks)}
  end

  def react({:spawn, comp, init, lnks, _arity}, args) do
    args = entry_to_args(comp, args)
    {:ok, instance} = Component.init(comp, init)
    {:ok, _state, spits} = Component.react(instance, args)
    {:ok, port_to_address(spits, lnks)}
  end

  defp port_to_address(spits, links) do
    Enum.flat_map(spits, fn {port, val} ->
      Enum.map(Keyword.get(links, port, []), fn address ->
        {val, address}
      end)
    end)
  end

  defp entry_to_args(component, entry) do
    Enum.map(Component.in_ports(component), fn port -> entry[port] end)
  end
end
