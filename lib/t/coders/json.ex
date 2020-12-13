defmodule T.Coder.JSON do
  use FDB.Coder.Behaviour

  @spec new() :: FDB.Coder.t()
  def new do
    %FDB.Coder{module: __MODULE__}
  end

  @impl true
  def encode(term, _) do
    Jason.encode!(term)
  end

  @impl true
  def decode(iodata, _) do
    {Jason.decode!(iodata), <<>>}
  end
end
