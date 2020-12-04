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
    :persistent_term.put(:usernames_coder, create_usernames_coder(dir))
    :persistent_term.put(:user_search_coder, create_user_search_coder(dir))
    :persistent_term.put(:filters_coder, create_filters_coder(dir))
  end

  # used to check if username is taken
  # test:usernames:{username} -> uuid
  defp create_usernames_coder(dir) do
    key =
      Subspace.concat(
        Subspace.new(dir),
        Subspace.new("usernames", ByteString.new())
      )

    Transaction.Coder.new(key, Coder.UUID.new())
  end

  # used to store user data
  # test:users:{uuid} -> data::json
  defp create_users_coder(dir) do
    key =
      Subspace.concat(
        Subspace.new(dir),
        Subspace.new("users", Coder.UUID.new())
      )

    Transaction.Coder.new(key, T.Coder.JSON.new())
  end

  # used to store index for searching
  # test:user_search:{age}:{geohash}:{uuid} -> filters::json
  defp create_user_search_coder(dir) do
    key =
      Subspace.concat(
        Subspace.new(dir),
        Subspace.new(
          "user_search",
          Coder.Tuple.new(
            {Coder.ByteString.new(), Coder.Integer.new(), Coder.ByteString.new(),
             Coder.UUID.new()}
          )
        )
      )

    Transaction.Coder.new(key, T.Coder.JSON.new())
  end

  # used to store filters for a user
  # test:filters:{uuid} -> filters::json
  defp create_filters_coder(dir) do
    key =
      Subspace.concat(
        Subspace.new(dir),
        Subspace.new("filters", Coder.UUID.new())
      )

    Transaction.Coder.new(key, T.Coder.JSON.new())
  end

  def db do
    :persistent_term.get(:fdb)
  end

  def users_coder do
    :persistent_term.get(:users_coder)
  end

  def filters_coder do
    :persistent_term.get(:filters_coder)
  end

  def user_search_coder do
    :persistent_term.get(:user_search_coder)
  end

  def usernames_coder do
    :persistent_term.get(:usernames_coder)
  end

  def transact(f) do
    FDB.Database.transact(T.db(), f)
  end
end
