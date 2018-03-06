defmodule Cbor.Types do
  @unsigned_integer <<0b000::3>>
  @string <<0b011::3>>
  @array <<0b100::3>>

  def unsigned_integer, do: @unsigned_integer
  def string, do: @string
  def array, do: @array
end
