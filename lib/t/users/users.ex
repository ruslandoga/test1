defmodule T.Users do
  alias T.Users.User
  import Ecto.Changeset
  import TWeb.Gettext

  def create_user(attrs) do
    %User{}
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> validate_length(:username, min: 3, max: 30)
    |> insert()
  end

  def get_user_by_username(username) when is_binary(username) do
    T.transact(fn tr -> get_user(tr, username) end)
  end

  defp insert(%Ecto.Changeset{valid?: valid?} = changeset) do
    if valid? do
      %User{username: username} = user = apply_changes(changeset)

      T.transact(fn tr ->
        if get_user(tr, username) do
          {:error, add_error(changeset, :username, dgettext("errors", "already exists"))}
        else
          :ok = set_user(tr, user)
          {:ok, user}
        end
      end)
    else
      {:error, changeset}
    end
  end

  defp get_user(tr, username) do
    user = FDB.Transaction.get(tr, username, %{coder: T.users_coder()})

    if user do
      %User{username: username}
    end
  end

  defp set_user(tr, %User{username: username}) do
    FDB.Transaction.set(tr, username, Jason.encode!(%{}), %{coder: T.users_coder()})
  end
end
