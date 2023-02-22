defmodule Week3 do
  defmodule Minimal.SimpleActor do
    @doc """
      ## TODO:
        Create an actor that prints on the screen any message it receives

      ## Examples:

          iex> Week3.Minimal.SimpleActor.start()
          iex> Week3.Minimal.SimpleActor.echo("Hello, PTR")
          "Hello, PTR"
    """
    def start() do
      pid = spawn(&loop/0)
      Process.register(pid, :echo_msg)
    end

    # receives messages from its mailbox and processes them
    defp loop() do
      receive do
        {:echo, msg, reply_pid} ->
          send(reply_pid, msg)
      end

      loop()
    end

    def echo(msg) do
      send(:echo_msg, {:echo, msg, self()})

      receive do
        msg ->
          msg
      end
    end
  end

  defmodule Minimal.ModificatorActor do
    @doc """
      ## TODO:
        Create an actor that returns any message it receives, while modifying it. Infer
        the modification from the following example:

      ## Example:

          iex> Week3.Minimal.ModificatorActor.start()
          iex> Week3.Minimal.ModificatorActor.modify(4)
          5

          iex> Week3.Minimal.ModificatorActor.modify("HELLO")
          "hello"
    """
    def start() do
      pid = spawn(&loop/0)
      Process.register(pid, :modificator)
    end

    defp loop() do
      receive do
        {:modify, msg, reply_pid} ->
          send(reply_pid, msg)
      end

      loop()
    end

    def modify(msg) do
      send(:modificator, {:modify, msg, self()})

      receive do
        msg when is_number(msg) ->
          msg + 1

        msg when is_bitstring(msg) ->
          String.downcase(msg)

        _ ->
          "I don't know how to HANDLE this !"
      end
    end
  end

  defmodule Minimal.MonitoringActor do
    @doc """
      ## TODO:
          Create a two actors, actor one 'monitoring' the other. If the second actor
          stops, actor one gets notified via a message.

      ## Examples:

          iex> {pid1, _pid2} = Week3.Minimal.MonitoringActor.start()
          iex> Process.exit(pid1, :kill)
          true
    """
    def start() do
      pid1 = spawn(fn -> first_actor() end)
      pid2 = spawn(fn -> second_actor(pid1) end)
      {pid1, pid2}
    end

    defp first_actor() do
      receive do
        msg ->
          msg
      end
    end

    defp second_actor(target_pid) do
      # create a new reference _ref that identifies the monitoring process
      _ref = Process.monitor(target_pid)
      second_actor_handler()
    end

    def second_actor_handler() do
      receive do
        # it means that the process with the ID _pid that is being monitored has terminated
        {:DOWN, _ref, :process, _pid, reason} ->
          IO.puts("The actor I monitor exited because #{reason}")

        _ ->
          IO.puts("I do not know how to response to this message.")
          second_actor_handler()
      end
    end
  end

  defmodule Minimal.AverageActor do
    @doc """
      ## TODO:
        Create an actor which receives numbers and with each request prints out the
        current average.

      ## Examples:

          iex> pid = Week3.Minimal.AverageActor.start()
          iex> send(pid, 23)
          iex> send(pid, 2)
    """
    def start() do
      _pid = spawn(fn -> loop() end)
    end

    def loop(acc \\ 0, count \\ 0) do
      receive do
        value ->
          IO.puts("Current Average: #{(acc + value) / (count + 1)}")
          loop(acc + value, count + 1)
      end
    end
  end

  defmodule Main.FIFOQueue do
    @doc """
      ## TODO:
        Create an actor which maintains a simple FIFO queue. You should write helper
        functions to create an API for the user, which hides how the queue is implemented.

      ## Examples:

        iex> Week3.Main.FIFOQueue.start_link()
        iex> Week3.Main.FIFOQueue.push(4)
        iex> Week3.Main.FIFOQueue.pop()
        4
    """
    use Agent

    def start_link() do
      Agent.start_link(fn -> [] end, name: __MODULE__)
    end

    def push(value) do
      Agent.update(__MODULE__, fn state -> state ++ [value] end)
    end

    def pop() do
      Agent.get_and_update(
        __MODULE__,
        fn state ->
          case state do
            [head | tail] ->
              {head, tail}

            [] ->
              raise "Queue Empty!"
          end
        end
      )
    end
  end

  defmodule Main.Semaphore do
    use Agent

    @doc """
    Starts a new bucket.
    """
    def start_link(counter) do
      Agent.start_link(fn -> %{size: counter, counter: counter} end)
    end

    def acquire(semaphore) do
      if get_counter(semaphore) > 0 do
        Agent.update(semaphore, fn state ->
          %{size: Map.get(state, :size), counter: Map.get(state, :counter) - 1}
        end)
      else
        raise "Error! Semaphore Full."
      end
    end

    def release(semaphore) do
      if get_counter(semaphore) < get_size(semaphore) do
        Agent.update(semaphore, fn state ->
          %{size: Map.get(state, :size), counter: Map.get(state, :counter) + 1}
        end)
      else
        raise "Error! Semaphore already Empty."
      end
    end

    def get_size(semaphore) do
      Agent.get(semaphore, fn state -> Map.get(state, :size) end)
    end

    def get_counter(semaphore) do
      Agent.get(semaphore, fn state -> Map.get(state, :counter) end)
    end
  end

  defmodule Bonus.Scheduler do
    def schedule(args) do
      worker_node = fn ->
        if :rand.uniform(2) == 1 do
          {:error, "Unlucky"}
        else
          {:ok, "Miau"}
        end
      end

      # Task.async to spawn the task as a separate process
      # Task.await to wait for it to complete and return the result
      # pattern-match on the task result
      case Task.async(worker_node) |> Task.await() do
        {:error, reason} ->
          IO.puts("Task failed: #{reason}")
          schedule(args)

        {:ok, message} ->
          IO.puts("Task successful: #{message}")
          :ok
      end
    end
  end
end
