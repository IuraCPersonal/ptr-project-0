defmodule Week4.Minimal.Worker do
  use GenServer

  # CLIENT

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def echo(pid, msg) do
    GenServer.cast(pid, {:echo, msg})
  end

  def kill(pid) do
    GenServer.call(pid, :kill)
  end

  def child_spec(arg) do
    %{
      id: arg,
      start: {Week4.Minimal.Worker, :start_link, [arg]}
    }
  end

  # SERVER

  def init(_init_args) do
    {:ok, []}
  end

  def handle_cast({:echo, msg}, _state) do
    IO.puts(msg)
    {:noreply, msg}
  end

  def handle_call({:kill, pid}, _state) do
    Process.exit(pid, :kill)
    {:noreply, pid}
  end
end

defmodule Week4.Minimal.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    children = 0..args |> Enum.map(fn x -> Week4.Minimal.Worker.child_spec(x) end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
