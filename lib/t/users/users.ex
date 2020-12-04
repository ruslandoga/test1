defmodule T.Users do
  alias T.Users.{User, Filters}
  import Ecto.Changeset
  import TWeb.Gettext

  def create_user(attrs) do
    %User{id: Ecto.UUID.bingenerate()}
    |> cast(attrs, [:username, :geohash, :gender, :age])
    |> validate_required([:username, :geohash, :gender, :age])
    |> validate_length(:username, min: 3, max: 30)
    |> validate_inclusion(:gender, ["m", "f"])
    |> validate_inclusion(:age, 18..120)
    |> insert()
  end

  def get_user_by_id(uuid) when is_binary(uuid) do
    T.transact(fn tr -> get_user_by_id(tr, uuid) end)
  end

  defp insert(%Ecto.Changeset{valid?: valid?} = changeset) do
    if valid? do
      %User{username: username} = user = apply_changes(changeset)

      T.transact(fn tr ->
        if username_taken?(tr, username) do
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

  defp username_taken?(tr, username) do
    !!FDB.Transaction.get(tr, username, %{coder: T.usernames_coder()})
  end

  defp get_user_by_id(tr, uuid) do
    data = FDB.Transaction.get(tr, uuid, %{coder: T.users_coder(), snapshot: true})

    if data do
      %{"age" => age, "gender" => gender, "geohash" => geohash, "username" => username} = data
      %User{id: uuid, username: username, age: age, gender: gender, geohash: geohash}
    end
  end

  defp set_user(tr, %User{} = user) do
    %User{id: id, username: username, age: age, gender: gender, geohash: geohash} = user

    # TODO clear prev used username if changed
    FDB.Transaction.set(tr, username, id, %{coder: T.usernames_coder()})

    data = %{"username" => username, "age" => age, "gender" => gender, "geohash" => geohash}
    FDB.Transaction.set(tr, id, data, %{coder: T.users_coder()})

    # TODO also store under users:{gender}:{age}:{geohash}:{user_id} -> {age_filter: [min,max], distance_filter: n, gender_filter} with no filters?
  end

  # TODO
  def set_filters(user, attrs) do
    changeset =
      %Filters{}
      |> cast(attrs, [:age_filter_min, :age_filter_max, :gender_filter, :distance_filter])
      |> validate_inclusion(:age_filter_min, 18..120)
      |> validate_inclusion(:age_filter_max, 18..120)
      |> validate_inclusion(:gender_filter, ["m", "f"])
      |> validate_number(:distance_filter, greater_than_or_equal_to: 5, less_than_or_equal_to: 50)

    if changeset.valid? do
      %User{id: user_id} = user

      %Filters{
        age_filter_min: age_filter_min,
        age_filter_max: age_filter_max,
        gender_filter: gender_filter,
        distance_filter: distance_filter
      } = filters = apply_changes(changeset)

      data = %{
        age_filter_min: age_filter_min,
        age_filter_max: age_filter_max,
        gender_filter: gender_filter,
        distance_filter: distance_filter
      }

      T.transact(fn tr ->
        FDB.Transaction.set(tr, user_id, data, %{coder: T.filters_coder()})

        FDB.Transaction.set(
          tr,
          {user.gender, user.age, user.geohash, user_id},
          data,
          %{coder: T.user_search_coder()}
        )
      end)

      {:ok, filters}
    else
      {:error, changeset}
    end
  end
end
