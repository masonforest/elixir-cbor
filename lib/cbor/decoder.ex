defmodule Cbor.Decoder do
  @unsigned_integer Cbor.Types.unsigned_integer()
  @string Cbor.Types.string()
  @array Cbor.Types.array()

  def decode(value) do
    {value, rest} = read(value)

    if rest == <<>> do
      value
    else
      raise "invalid trailing data"
    end
  end

  def read(value) do
    case value do
      << @array, bits::bits >> ->
        read_array(bits)
      << @unsigned_integer, bits::bits >> ->
        read_unsigned_integer(bits)
      << @string, bits::bits >> ->
        read_string(bits)
    end

  end

  def read_array(value) do
    {length, rest} = read_unsigned_integer(value)
    {values, rest} = Enum.reduce(1..length, {[], rest}, fn(x, acc) ->
      {value, rest} = read(elem(acc, 1))
      {[value | elem(acc, 0)], rest}
    end)
    {values|>Enum.reverse, rest}
  end

  def read_string(value) do
    {String.to_atom(value), <<>>}
  end

  def read_unsigned_integer(value) do
    case value do
      << 24::size(5), value::size(8), rest::bits >> ->
        {value, rest}
      << <<value::size(5)>>::bitstring, rest::bits >> ->
        {value, rest}
    end
  end
end
