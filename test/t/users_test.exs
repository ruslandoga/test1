defmodule T.UsersTest do
  use T.DataCase, async: false
  alias T.Users
  alias Users.{User, Search, Filters}

  describe "create_user/1" do
    test "with empty attrs" do
      assert {:error, changeset} = Users.create_user(%{})
      refute changeset.valid?

      assert errors_on(changeset) == %{
               username: ["can't be blank"],
               age: ["can't be blank"],
               gender: ["can't be blank"],
               geohash: ["can't be blank"]
             }
    end

    test "with username,gender,age,geohash" do
      assert {:ok, %User{id: id} = user} =
               Users.create_user(%{
                 username: "test",
                 geohash: Geohash.encode(55.751244, 37.618423, 8),
                 gender: "m",
                 age: 26
               })

      Ecto.UUID.cast!(id)
      assert user.username == "test"
      assert user.geohash == "ucfv0j0y"
      assert user.gender == "m"
      assert user.age == 26
    end

    # test "with bio"
    # test "with job"
    # test "with school"
    # test "with profile image urls"

    test "with username too short" do
      assert {:error, changeset} = Users.create_user(%{username: "a"})
      refute changeset.valid?
      assert errors_on(changeset).username == ["should be at least 3 character(s)"]
    end

    test "with username too long" do
      assert {:error, changeset} = Users.create_user(%{username: String.duplicate("a", 31)})
      refute changeset.valid?
      assert errors_on(changeset).username == ["should be at most 30 character(s)"]
    end

    # TODO test that username can be taken after the owner changes their username
    test "duplicate username" do
      assert %User{username: "test"} = user_fixture(username: "test")

      assert {:error, changeset} =
               Users.create_user(%{
                 username: "test",
                 geohash: Geohash.encode(55.751244, 37.618423, 8),
                 gender: "m",
                 age: 26
               })

      refute changeset.valid?
      assert errors_on(changeset) == %{username: ["already exists"]}
    end
  end

  describe "get_user_by_username/1" do
    test "when no user exists" do
      refute Users.get_user_by_id(Ecto.UUID.bingenerate())
    end

    test "when user exists" do
      assert %User{id: id} = user = user_fixture()
      assert user == Users.get_user_by_id(id)
    end
  end

  describe "search" do
    setup do
      %User{} =
        me = user_fixture(username: "john", geohash: moscow_geohash(), gender: "m", age: 26)

      %Filters{} =
        filters =
        filters_fixture(
          user: me,
          age_filter_min: 20,
          age_filter_max: 30,
          gender_filter: "f",
          distance_filter: 50
        )

      {:ok, me: me, filters: filters}
    end

    test "when no other users exist doesn't return self", %{me: me} do
      %Filters{} =
        filters =
        filters_fixture(
          user: me,
          age_filter_min: 20,
          age_filter_max: 30,
          gender_filter: "m",
          distance_filter: 50
        )

      assert [] == Search.search(me, filters)
    end

    test "when other users exist", %{me: me, filters: filters} do
      %User{} = not_me = user_fixture(geohash: moscow_geohash(), gender: "f", age: 26)

      %Filters{} =
        filters_fixture(
          user: not_me,
          age_filter_min: 18,
          age_filter_max: 30,
          gender_filter: "m",
          distance_filter: 50
        )

      assert [
               %User{id: not_me.id, age: 26, gender: "f", geohash: "ucfv0j0y"}
             ] == Search.search(me, filters)
    end
  end
end
