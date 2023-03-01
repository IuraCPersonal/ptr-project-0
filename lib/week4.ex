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
    IO.puts("[#{__MODULE__}]: Started at #{inspect(self())}.")
    {:ok, []}
  end

  def handle_cast({:echo, msg}, _state) do
    IO.puts(msg)
    {:noreply, msg}
  end

  def handle_call({:kill, pid}, _state) do
    Process.exit(pid, :kill)
    IO.puts("Process #{pid} was killed.")
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

# TASK #2

defmodule Week4.Main.Split do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def split(pid, msg) do
    GenServer.cast(pid, {:split, msg})
  end

  @impl true
  def init(stack) do
    IO.puts("[#{__MODULE__}] started at pid #{inspect(self())}")
    {:ok, stack}
  end

  @impl true
  def handle_cast({:split, msg}, _state) do
    processed_msg =
      msg
      |> String.split()
      |> Enum.map(fn word ->
        String.downcase(word)
      end)

    IO.puts("[#{__MODULE__}] #{msg} was splitted.")
    IO.inspect(processed_msg)

    Week4.Main.LineSupervisor.get_worker("Nomster")
    |> GenServer.cast({:nom, processed_msg})

    {:noreply, :ok}
  end

  def child_spec do
    %{
      id: "Split",
      start: {Week4.Main.Split, :start_link, [[]]}
    }
  end
end

defmodule Week4.Main.Nomster do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def nom(pid, msg) do
    GenServer.cast(pid, {:nom, msg})
  end

  @impl true
  def init(stack) do
    IO.puts("[#{__MODULE__}] started at pid #{inspect(self())}")
    {:ok, stack}
  end

  @impl true
  def handle_cast({:nom, msg}, _state) do
    IO.puts("[#{__MODULE__}] Message received. Processing")

    processed_msg =
      msg
      |> Enum.map(fn word ->
        String.replace(word, ["m", "n"], fn
          "m" -> "n"
          "n" -> "m"
        end)
      end)

    IO.inspect(processed_msg)

    Week4.Main.LineSupervisor.get_worker("Join")
    |> GenServer.cast({:join, processed_msg})

    {:noreply, :ok}
  end

  def child_spec do
    %{
      id: "Nomster",
      start: {Week4.Main.Nomster, :start_link, [[]]}
    }
  end
end

defmodule Week4.Main.Join do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(stack) do
    IO.puts("[#{__MODULE__}] started at pid #{inspect(self())}")
    {:ok, stack}
  end

  @impl true
  def handle_cast({:join, msg}, _state) do
    IO.puts("[#{__MODULE__}] Message received. Processing")

    processed_msg = msg |> Enum.join(" ")

    IO.puts(processed_msg)

    {:noreply, :ok}
  end

  def child_spec do
    %{
      id: "Join",
      start: {Week4.Main.Join, :start_link, [[]]}
    }
  end
end

defmodule Week4.Main.LineSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_init_args) do
    children = [
      Week4.Main.Split.child_spec(),
      Week4.Main.Nomster.child_spec(),
      Week4.Main.Join.child_spec()
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def process_message(msg) do
    get_worker("Split")
    |> GenServer.cast({:split, msg})
  end

  def get_worker(id) do
    {^id, pid, _type, _modules} =
      __MODULE__
      |> Supervisor.which_children()
      |> Enum.find(fn {worker_id, _pid, _type, _modules} -> worker_id == id end)

    pid
  end
end

# TASK #3

defmodule Week4.Bonus.Sensor do
  use GenServer

  def start_link(args) do
    IO.puts("[#{args}] Status: ON.")
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(_init_args) do
    {:ok, []}
  end

  @impl true
  def terminate(reason, state) do
    IO.inspect("terminate/2 callback")
    IO.inspect({:reason, reason})
    IO.inspect({:state, state})
  end

  def child_spec(id) do
    %{
      id: id,
      start: {Week4.Bonus.Sensor, :start_link, [id]}
    }
  end
end

defmodule Week4.Bonus.WheelsSensorSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children =
      1..4
      |> Enum.map(fn id ->
        Week4.Bonus.Sensor.child_spec("Wheel_#{id}")
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Week4.Bonus.MainSensorSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      Week4.Bonus.Sensor.child_spec("Cabin"),
      Week4.Bonus.Sensor.child_spec("Motor"),
      Week4.Bonus.Sensor.child_spec("Chassis"),
      {Week4.Bonus.WheelsSensorSupervisor, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

# defmodule Week4.Bonus.Simulate do
#   def start() do
#     {:ok, sup} = Week4.Bonus.MainSensorSupervisor.start_link([])

#     sensors =
#       Supervisor.which_children(sup)
#       |> Enum.map(&elem(&1, 0))

#     loop(sup, sensors)
#   end

#   def loop(sup, sensors) do
#     random_pid = Enum.random(sensors)

#     Supervisor.terminate_child(sup, random_pid)

#     loop(sup, sensors)
#   end
# end

defmodule Week4.Bonus.PulpFiction do
  defmodule Jules do
    use GenServer

    def start_link do
      questions = [
        "What does Marsellus Wallace look like?",
        "What country you from?",
        "What ain't no country I ever heard of. They speak English in what?",
        "English motherfucker. Do you speak it?",
        "Then you know what I'm saying",
        "Describe what Marsellus Wallace looks like",
        "Say what again. Say what again. I dare you, not dare you, I double dare you motherfucker. Say what one more goddamn time.",
        "Go on.",
        "Does he look like a bitch?"
      ]

      GenServer.start_link(__MODULE__, [questions], name: __MODULE__)
    end

    def init(questions) do
      {:ok, {nil, questions}}
    end
  end

  defmodule Brett do
    use GenServer

    def start_link do
      GenServer.start(__MODULE__, [], name: __MODULE__)
    end

    def init(state) do
      {:ok, state}
    end

    def handle_info(:timeout, state) do
      :ok = Process.sleep(1_000)
      {:noreply, state}
    end

    def handle_cast({:ask, pid, ref, question}, state) do
      answer =
        case question do
          "What does Marsellus Wallace look like?" ->
            "What?"

          "What country you from?" ->
            "What?"

          "What ain't no country I ever heard of. They speak English in what?" ->
            "What?"

          "English motherfucker. Do you speak it?" ->
            "Yes"

          "Then you know what I'm saying" ->
            "Yes"

          "Describe what Marsellus Wallace looks like" ->
            "What?"

          "Say what again. Say what again. I dare you, not dare you, I double dare you motherfucker. Say what one more goddamn time." ->
            "He's black."

          "Go on." ->
            "He's bald."

          "Does he look like a bitch?" ->
            "What?"
        end

      send(pid, {:answer, ref, answer})
      {:noreply, state}
    end
  end
end
