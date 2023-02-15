defmodule Week3Test do
  use ExUnit.Case, async: true
  doctest Week3.Minimal.SimpleActor
  doctest Week3.Minimal.ModificatorActor
  doctest Week3.Minimal.MonitoringActor
  doctest Week3.Minimal.AverageActor
  doctest Week3.Main.FIFOQueue
end
