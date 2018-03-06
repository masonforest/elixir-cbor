defmodule Cbor.Decoder do
  @unsigned_integer Cbor.Types.unsigned_integer()
  @string Cbor.Types.string()
  @array Cbor.Types.array()
  @byte_string Cbor.Types.byte_string()
  @map Cbor.Types.map()

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
      << @unsigned_integer, bits::bits >> ->
        read_unsigned_integer(bits)
      << @string, bits::bits >> ->
        read_string(bits)
      << @byte_string, bits::bits >> ->
        read_byte_string(bits)
      << @array, bits::bits >> ->
        read_array(bits)
      << @map, bits::bits >> ->
        read_map(bits)
    end

  end

  def read_map(value) do
    {size, rest} = read_unsigned_integer(value)
    {map, rest} = Enum.reduce(1..size, {%{}, rest}, fn(_, acc) ->
      {key, rest} = read(elem(acc, 1))
      {value, rest} = read(rest)
      {Map.put(elem(acc, 0), key, value), rest}
    end)

    {map, rest}
  end

  def read_byte_string(value) do
    {length, rest} = read_unsigned_integer(value)
    <<bytes::binary-size(length), rest::binary>> = rest
    {bytes, rest}
  end

  def read_array(value) do
    {length, rest} = read_unsigned_integer(value)
    {values, rest} = Enum.reduce(1..length, {[], rest}, fn(_, acc) ->
      {value, rest} = read(elem(acc, 1))
      {[value | elem(acc, 0)], rest}
    end)
    {values|>Enum.reverse, rest}
  end

  def read_string(value) do
    {length, rest} = read_unsigned_integer(value)
    << value::binary-size(length), rest::bits >> = rest
    {String.to_atom(value), rest}
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
