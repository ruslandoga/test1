defmodule T.Users.Search do
  @moduledoc """
  - [ ] geo search stuff - given a coordinate and a radius, find geohash prefix for searching in the users table

  say for user u1 we get 10 geohashes, and 18-30 age filter, then we need to issue 120 parallel requests for the users

  and then filter the users `u` who have `u1.age in u.age_filter_min..u.age_filter_max` and `u1.position in u.distance_filter` and `u1.gender == u.gender_filter`

  after that we need to get the most likable candidates for `u1` (TODO)

  ```
  table:
  users:{gender}:{age}:{geohash}:{user_id} -> {age_filter: [min,max], distance_filter: n, gender_filter}
  ```
  """

  alias T.Users.{User, Filters}

  def search(%User{} = user, %Filters{} = filters) do
    %User{geohash: geohash} = user
    {lat, lon} = Geohash.decode(geohash)

    %Filters{
      age_filter_min: age_filter_min,
      age_filter_max: age_filter_max,
      gender_filter: gender,
      distance_filter: radius_km
    } = filters

    radius_km = Decimal.to_float(radius_km)

    geohashes =
      Geobox.geohashes_within_radius({lat, lon}, radius_km, radius_to_precision(radius_km))

    tasks =
      for age <- age_filter_min..age_filter_max, geohash <- geohashes do
        prefix = {gender, age, geohash}
        range = FDB.KeySelectorRange.starts_with(prefix)

        Task.async(fn ->
          T.transact(fn tr ->
            tr
            |> FDB.Transaction.get_range_stream(range, %{
              coder: T.user_search_coder(),
              snapshot: true
            })
            |> Enum.into([])
          end)
        end)
      end

    # TODO limit and use cursors
    tasks
    # TODO limit concurrency
    |> Enum.map(&Task.await/1)
    |> List.flatten()
    |> filter_by_their_options(user)
    |> Enum.map(fn row ->
      {{gender, age, geohash, id}, %{}} = row
      # TODO username?
      %User{id: id, age: age, gender: gender, geohash: geohash}
    end)
  end

  def filter_by_their_options(users, user) do
    %User{id: id1, gender: gender, age: age, geohash: geohash1} = user

    Enum.filter(
      users,
      fn {{_gender, _age, geohash2, id2},
          %{
            "age_filter_min" => min_age,
            "age_filter_max" => max_age,
            "distance_filter" => radius_km,
            "gender_filter" => genger_filter
          }} ->
        id1 != id2 &&
          gender == genger_filter &&
          (min_age <= age and max_age >= age) &&
          distance(geohash1, geohash2) <= radius_km
      end
    )
  end

  defp distance(_geohash1, _geohash2) do
    # TODO
    0
  end

  defp radius_to_precision(radius_km) do
    cond do
      radius_km <= 10 -> 6
      radius_km <= 30 -> 5
      true -> 4
    end
  end
end
