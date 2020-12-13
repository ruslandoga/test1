defmodule T.Coder.DateTime do
  use FDB.Coder.Behaviour
  alias FDB.Coder
  alias Coder.{Tuple, NestedTuple, Integer}

  @spec new() :: Coder.t()
  def new do
    Tuple.new(
      {NestedTuple.new({Integer.new(), Integer.new(), Integer.new()}),
       NestedTuple.new({Integer.new(), Integer.new(), Integer.new()})}
    )
  end

  @impl true
  def encode(%DateTime{year: y, month: m, day: d, hour: h, minute: m, second: s}, coders) do
    Tuple.encode({{y, m, d}, {h, m, s}}, coders)
  end

  @impl true
  def decode(iodata, coders) do
    {{{y, m, d}, {h, m, s}}, <<>>} = Tuple.decode(iodata, coders)
    {DateTime.new!(Date.new!(y, m, d), Time.new!(h, m, s)), <<>>}
  end
end
