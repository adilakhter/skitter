defmodule Skitter.Runtime.WorkflowInstance do
  use GenServer

  require Logger

  alias Skitter.Runtime.Matcher, as: Matcher
  alias Skitter.Runtime.Invocation, as: Invocation

  # --- #
  # API #
  # --- #

  def start(workflow) do
    GenServer.start_link(__MODULE__, workflow)
  end

  def add_token(instance, token, address \\ {:_, :__PRIVATE__}) do
    GenServer.cast(instance, {:token, token, address})
  end

  # ------ #
  # Server #
  # ------ #

  def init(workflow) do
    Logger.debug("Creating new workflow instance")
    {:ok, {workflow, Matcher.new(), 0}}
  end

  def handle_cast(:react_finished, {workflow, matcher, 1}) do
    if Matcher.empty?(matcher) do
      {:stop, :normal, {workflow, matcher, 0}}
    else
      Logger.warn("Unused tokens in workflow: #{matcher}")
      {:noreply, {workflow, matcher, 0}}
    end
  end

  def handle_cast(:react_finished, {workflow, matcher, pending}) do
    {:noreply, {workflow, matcher, pending - 1}}
  end

  def handle_cast({:token, data, address}, {workflow, matcher, pending}) do
    {matcher, tasks_spawned} = add_token(matcher, address, data, workflow)
    {:noreply, {workflow, matcher, pending + tasks_spawned}}
  end

  defp add_token(matcher, address, data, workflow) do
    case Matcher.add(matcher, address, data, workflow) do
      {:ok, matcher} ->
        {matcher, 0}

      {:trigger, matcher, id, args} ->
        Logger.debug(
          "Invoking react of instance #{id}, with args #{inspect(args, charlists: :as_lists)}"
        )

        Invocation.invoke_react_async(workflow, id, args)
        {matcher, 1}
    end
  end
end
