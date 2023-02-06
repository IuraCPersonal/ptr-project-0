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
  """
  def smallestNumber(a, b, c) do
    Enum.sort([a, b, c])
  end
end
