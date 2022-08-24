defmodule TaxTest do
  use ExUnit.Case
  doctest Tax

  test "greets the world" do
    assert Tax.hello() == :world
  end
end
