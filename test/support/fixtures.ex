defmodule T.Fixtures do
  alias T.Users.{User, Filters}

  def rand_key do
    Base.encode64(:crypto.strong_rand_bytes(8))
  end

  def moscow_geohash(precision \\ 8) do
    Geohash.encode(55.751244, 37.618423, precision)
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, %User{} = user} =
      T.Users.create_user(%{
        username: attrs[:username] || "test-" <> rand_key(),
        age: attrs[:age] || 22,
        gender: attrs[:gender] || "m",
        geohash: attrs[:geohash] || moscow_geohash()
      })

    user
  end

  def filters_fixture(attrs \\ %{}) do
    %User{} = user = attrs[:user] || raise "need :user"

    {:ok, %Filters{} = filters} =
      T.Users.set_filters(user, %{
        age_filter_min: attrs[:age_filter_min] || 22,
        age_filter_max: attrs[:age_filter_max] || 28,
        gender_filter: attrs[:gender_filter] || "f",
        distance_filter: attrs[:distance_filter] || 50
      })

    filters
  end
end
