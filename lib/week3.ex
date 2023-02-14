defmodule Week3 do
  defmodule Minimal.SimpleActor do
    def start() do
      pid = spawn(&loop/0)
      Process.register(pid, :echo_msg)
    end

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
    def start() do
      pid1 = spawn(fn -> first_actor() end)
      pid2 = spawn(fn -> second_actor(pid1) end)
      {pid1, pid2}
    end

    defp first_actor do
      receive do
        msg ->
          msg
      end
    end

    defp second_actor(target_pid) do
      _ref = Process.monitor(target_pid)
      second_actor_loop()
    end

    def second_actor_loop() do
      receive do
        {:DOWN, _ref, :process, _pid, reason} ->
          IO.puts("The actor I monitor exited because #{reason}")

        _ ->
          IO.puts("I do not know how to response to this message.")
          second_actor_loop()
      end
    end
  end

  defmodule Minimal.AverageActor do
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
end
