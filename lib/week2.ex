defmodule Minimal do
  @moduledoc """
    PTR Week 2 Minimal Tasks.
  """

  @doc """
    Write a function that determines whether an input is prime.
  
    ## Examples
  
        iex> Minimal.isPrime(3)
        :true
  
        iex> Minimal.isPrime(4)
        :false
  """
  def isPrime(num) do
    Enum.filter(2..num, fn a -> rem(num, a) == 0 end) |> length() == 1
  end

  @doc """
    Write a function to calculate the area of a cylinder, given it's height and radius.
  
    ## Examples
  
        iex> Minimal.cylinderArea(2, 3)
        95.0
  
        iex> Minimal.cylinderArea()
        13.0
  """
  def cylinderArea(height \\ 1, radius \\ 1) do
    Float.ceil(2 * :math.pi() * radius * radius + 2 * :math.pi() * radius * height)
  end

  @doc """
    Write a function to reverse a list.
  
    ## Examples
  
        iex> Minimal.reverse([1, 2, 3])
        [3, 2, 1]
  
        iex> Minimal.reverse([])
        []
  
        iex> Minimal.reverse([1])
        [1]
  """
  def reverse(list) do
    try do
      (Enum.count(list) - 1)..0
      |> Enum.map(fn a -> Enum.fetch!(list, a) end)
    rescue
      Enum.OutOfBoundsError -> []
    end
  end

  @doc """
    Write a function to calculate the sum of unique
    elements in a list.
  
    ## Examples
  
        iex> Minimal.uniqueSum([1, 2, 3])
        6
  
        iex> Minimal.uniqueSum([1, 1, 1])
        1
  
        iex> Minimal.uniqueSum([])
        0
  """
  def uniqueSum(list) do
    # Easy way 🚀
    list |> Enum.uniq() |> Enum.sum()
  end

  @doc """
    Write a function that extracts a given number of randomly selected
    elements from a list.
  """
  def extractRandomN(list, n) do
    1..n |> Enum.map(fn _ -> Enum.random(list) end)
  end

  @doc """
    Write a function that returns the first n elements of the Fibonacci sequence.
  
    ## Examples
  
        iex> Minimal.firstFibonacciElements(7)
        [0, 1, 1, 2, 3, 5, 8]
  
        iex> Minimal.firstFibonacciElements(1)
        [0]
  
        iex> Minimal.firstFibonacciElements(0)
        []
  """
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n), do: fib(n - 1) + fib(n - 2)

  def firstFibonacciElements(n) do
    cond do
      n == 0 -> []
      n != 0 -> Enum.map(0..(n - 1), fn i -> fib(i) end)
    end
  end

  @doc """
    Write a function that, given a dictionary would translate a sentence.
  
    ## Examples
  
        iex> Minimal.translator(%{"mama" => "mother", "papa" => "father"}, "mama is with papa")
        "mother is with father"
  
        iex> Minimal.translator(%{"none" => "all"}, "is that all?")
        "is that all?"
  
        iex> Minimal.translator(%{"none" => "all"}, "")
        ""
  
  """
  def process(key, map) do
    value = Map.get(map, key)
    str_value = if value, do: "#{value}", else: "#{key}"

    # return:
    "#{str_value}"
  end

  def translator(map, expr) do
    expr
    |> String.split(" ")
    |> Enum.map_join(" ", fn target -> Minimal.process(target, map) end)
  end

  @doc """
    Write a function that recieves as input three digits and arranges them in an order
    that would create the smallest possible number.
  
    ❗ Numbers cannot start with zero.
  
    ## Examples
  
        iex> Minimal.smallestNumber(4, 5, 3)
        345
  
        iex> Minimal.smallestNumber(0, 3, 4)
        304
  """
  def smallestNumber(a, b, c) do
    list = Enum.sort([a, b, c])

    count_zeros =
      Enum.reduce(list, 0, fn target, acc ->
        if target == 0, do: acc + 1, else: acc
      end)

    e1 = Enum.at(list, 0)
    e2 = Enum.at(list, 1)

    case count_zeros do
      2 ->
        Enum.reduce(list |> :lists.reverse(), "", fn x, acc ->
          acc <> "#{x}"
        end)
        |> String.to_integer()

      1 ->
        Enum.reduce(
          list
          |> List.replace_at(0, e2)
          |> List.replace_at(1, e1),
          "",
          fn x, acc ->
            acc <> "#{x}"
          end
        )
        |> String.to_integer()

      _ ->
        Enum.reduce(list, "", fn x, acc ->
          acc <> "#{x}"
        end)
        |> String.to_integer()
    end
  end

  @doc """
    Write a function that would rotate a list n places to the left.
  
    ## Examples
  
        iex> Minimal.rotateLeft([1, 2, 4, 8, 4], 3)
        [8, 4, 1, 2, 4]
  
        iex> Minimal.rotateLeft([1, 1, 1, 1], 3)
        [1, 1, 1, 1]
  
        iex> Minimal.rotateLeft([1, 2], 3)
        [2, 1]
  """
  def rotateLeft(list, n) do
    val = elem(List.pop_at(list, 0), 0)

    try do
      cond do
        n == 0 ->
          throw(:break)

        true ->
          list
          |> List.pop_at(0)
          |> elem(1)
          |> List.insert_at(-1, val)
          |> Minimal.rotateLeft(n - 1)
      end
    catch
      :break -> list
    end
  end

  @doc """
    Write a function that lists all tuples a, b, c such that a^2 + b^2 = c^2 and a, b <= 20.
  
    ## Examples
  
        iex> Minimal.listRightAngleTriangles()
  """
  def listRightAngleTriangles(a \\ 20, b \\ 20, c \\ 20) do
    list =
      for i <- 1..a,
          j <- 1..b,
          k <- 1..c,
          do:
            if(:math.pow(i, 2) + :math.pow(j, 2) == :math.pow(k, 2),
              do: {i, j, k}
            )

    list
    |> Enum.filter(fn x ->
      if x != "" do
        x
      end
    end)

    # |> Enum.filter(fn
    #   nil -> false
    # end)
  end
end

IO.inspect(Minimal.listRightAngleTriangles())

defmodule Main do
  @doc """
    Write a function that eliminates consecutive duplicates in a list.
  
    ## Examples
  
        iex> Main.removeConsecutiveDuplicates([1, 2, 2, 3])
        [1, 2, 3]
  
        iex> Main.removeConsecutiveDuplicates([1, 1, 1])
        [1]
  """
  def removeConsecutiveDuplicates(list) do
    list
    |> Enum.reduce([], fn target, acc ->
      case acc do
        [^target | _] -> acc
        _ -> [target | acc]
      end
    end)
    |> :lists.reverse()
  end

  @doc """
    Write a function that, given an array of strings, will return the words that can
    be typed using only one row of the letters on an English keyboard layout.
  
    ## Examples
  
        iex>Main.lineWords(["asd", "aaa", "bcd", "qaz"])
        ["asd", "aaa"]
  
        iex>Main.lineWords(["qwerty", "asus"])
        ["qwerty"]
  
        iex>Main.lineWords(["Hello", "Alaska", "Dad", "Peace"])
        ["Alaska", "Dad"]
  
  """
  def lineWords(list) do
    map = %{
      "q" => 1,
      "a" => 2,
      "z" => 3,
      "w" => 1,
      "s" => 2,
      "x" => 3,
      "e" => 1,
      "d" => 2,
      "c" => 3,
      "r" => 1,
      "f" => 2,
      "v" => 3,
      "t" => 1,
      "g" => 2,
      "b" => 3,
      "y" => 1,
      "h" => 2,
      "n" => 3,
      "u" => 1,
      "j" => 2,
      "m" => 3,
      "i" => 1,
      "k" => 2,
      "o" => 1,
      "l" => 2,
      "p" => 1
    }

    for word <- list do
      rowNum = Map.get(map, String.at(word |> String.downcase(), 0))

      if Enum.reduce(
           word |> String.downcase() |> String.graphemes(),
           true,
           fn char, acc ->
             acc and Map.get(map, char) == rowNum
           end
         ),
         do: word
    end
    |> Enum.filter(fn word -> word != nil end)
  end

  @doc """
    Create a pair of functions to encode and decode strings using the Caesar cipher.
  
    ## Examples
  
        iex> Main.encode("hello", 6)
        'nkrru'
  
        iex> Main.decode("bbbb", 1)
        'aaaa'
  """
  def encode(expr, cipher) do
    for chr <- expr |> String.graphemes() do
      (chr |> String.to_charlist() |> hd) + cipher
    end
  end

  def decode(expr, cipher) do
    for chr <- expr |> String.graphemes() do
      (chr |> String.to_charlist() |> hd) - cipher
    end
  end
end
