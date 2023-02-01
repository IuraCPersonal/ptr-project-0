defmodule HelloWorldTest do
  use ExUnit.Case

  test "hello returns Hello, World!" do
    assert HelloWorld.hello == "Hello, World!"
  end
end
