defmodule T do
  @moduledoc """
  T keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias FDB.{Database, Directory, Coder, Transaction}
  alias Coder.{Subspace, ByteString}

  def setup_db do
    :ok = FDB.start(620)

    db = FDB.Database.create()
    :persistent_term.put(:fdb, db)

    dir =
      Database.transact(db, fn t ->
        Directory.create_or_open(Directory.new(), t, ["test"])
      end)

    :persistent_term.put(:users_coder, create_users_coder(dir))
  end

  defp create_users_coder(dir) do
    key =
      Subspace.concat(
        Subspace.new(dir),
        Subspace.new("users", ByteString.new())
      )

    # TODO value = JSON
    Transaction.Coder.new(key)
  end

  def db do
    :persistent_term.get(:fdb)
  end

  def users_coder do
    :persistent_term.get(:users_coder)
  end

  def transact(f) do
    FDB.Database.transact(T.db(), f)
  end
end
