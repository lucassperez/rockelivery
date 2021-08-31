defmodule Rockelivery.Stack do
  use GenServer

  def start_link(initial_stack \\ [])

  def start_link(initial_stack) when is_list(initial_stack),
    do: GenServer.start_link(__MODULE__, initial_stack)

  def start_link(_initial_stack), do: {:error, "Initial value must be a List"}

  def push(pid, element), do: GenServer.call(pid, {:push, element})
  def pop(pid), do: GenServer.call(pid, :pop)
  def peek(pid), do: GenServer.call(pid, :peek)

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true # síncrono
  def handle_call({:push, element}, _from, stack) do
    new_stack = [element | stack]
    {:reply, new_stack, new_stack}
  end

  @impl true
  def handle_call(:pop, _from, []) do
    {:reply, nil, []}
  end

  @impl true
  def handle_call(:pop, _from, stack) do
    {:reply, hd(stack), tl(stack)}
  end

  @impl true
  def handle_call(:peek, _from, stack) do
    {:reply, stack, stack}
  end

  @impl true # assíncrono
  def handle_cast({:push, element}, stack) do
    {:noreply, [element | stack]}
  end

  def handle_cast(:pop, []) do
    {:noreply, []}
  end

  def handle_cast(:pop, stack) do
    {:noreply, tl(stack)}
  end
end
