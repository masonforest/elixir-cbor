defmodule Cbor.Encoder do
  alias Cbor.Types

  def encode(value) do
    write(value)
  end

  def write(value) do
      case value do
        value when is_list(value) ->
          concat(Types.array, write_unsigned_int(length(value)))
            <>
            (Enum.map(value, &write/1) |> Enum.join)
        value when is_integer(value) ->
          concat(Types.unsigned_integer, write_unsigned_int(value))
        value when is_atom(value) ->
          concat(Types.string, to_string(value))
      end
  end

  defp concat(left, right) do
    <<left::bitstring, right::bitstring>>
  end

  def write_unsigned_int(value) do
    case value do
      value when value in 0..24 ->
        <<value::5>>
      value when value in 25..0x100 ->
        <<24::size(5), value>>
    end
  end
end
