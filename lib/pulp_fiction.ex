defmodule Brett do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init([]) do
    {:ok, nil}
  end

  def handle_call({:ask, ref, message}, _from, _state) do
    answer =
      case message do
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
          "Well he's... he's... black."

        "Go on." ->
          "...and he's... he's... bald"

        "Does he look like a bitch?" ->
          "What?"
      end

    Process.sleep(1_000)
    {:reply, {:answer, ref, answer}, nil}
  end
end

defmodule Jules do
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

    GenServer.start_link(__MODULE__, questions, [])
  end

  def init(questions) do
    loop(nil, questions)
    {:ok, questions}
  end

  def loop(nil, questions) do
    {:ok, brett_pid} = Brett.start_link()

    loop({self(), brett_pid}, questions)
  end

  def loop({_monitor_ref, brett_pid}, []) do
    Process.exit(brett_pid, :shoot)
    IO.puts("--- Jules shot Brett. END. --- ")

    {:stop, :normal, []}
  end

  def loop({monitor_ref, brett_pid}, [question | questions]) do
    question_ref = make_ref()
    reply = GenServer.call(brett_pid, {:ask, question_ref, question})

    IO.puts("** JULES ** - #{question}")

    case reply do
      {:answer, _ref, answer} ->
        Process.sleep(1_000)
        IO.puts("** BRETT ** - #{answer}\n")
        loop({monitor_ref, brett_pid}, questions)
    end
  end
end
