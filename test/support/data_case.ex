defmodule T.DataCase do
  use ExUnit.CaseTemplate
  alias FDB.{Transaction, KeyRange}

  def flushdb do
    t = new_transaction()
    :ok = Transaction.clear_range(t, KeyRange.range("", <<0xFF>>))
    Transaction.commit(t)
  end

  def random_value(size \\ 1024) do
    :crypto.strong_rand_bytes(size)
  end

  def random_key(size \\ 1024) do
    "fdb:" <> :crypto.strong_rand_bytes(size)
  end

  def new_transaction do
    Transaction.create(database())
  end

  def database do
    T.db()
  end

  def errors_on(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  using do
    quote do
      import T.DataCase
    end
  end

  setup do
    flushdb()
    :ok
  end
end
