defmodule Skitter.Workflow do
  @moduledoc """
  Documentation for Workflow.
  """

  def get_component(workflow, id), do: elem(workflow[id], 0)
  def get_links(workflow, id), do: elem(workflow[id], 2)
  def get_init(workflow, id), do: elem(workflow[id], 1)

  def init_id(workflow, id) do
    {cmp, init, _} = workflow[id]
    Skitter.Component.init(cmp, init)
  end
end
