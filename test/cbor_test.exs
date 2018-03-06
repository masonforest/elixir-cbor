defmodule CborTest do
  use ExUnit.Case
  doctest Cbor

  test "unsigned integers" do
    round_trip(1)
    round_trip(42)
    round_trip(:test)
    round_trip([1,2,3])
    round_trip(%{key1: :value1, key2: :value2})
  end

  def round_trip(value) do
    assert value == Cbor.decode(Cbor.encode(value))
  end
end
