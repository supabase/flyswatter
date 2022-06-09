defmodule FlySwatter.StackConsumer do
  require Logger

  alias FlySwatter.Stacks

  def start_link(stack) do
    Logger.info("StackConsumer started!")

    Task.start_link(fn -> Stacks.ping_stack(stack) end)
  end
end
