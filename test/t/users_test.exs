defmodule T.UsersTest do
  use T.DataCase, async: false
  alias T.{Users, Users.User}

  describe "create_user/1" do
    test "without username" do
      assert {:error, changeset} = Users.create_user(%{})
      refute changeset.valid?
      assert errors_on(changeset) == %{username: ["can't be blank"]}
    end

    test "with username" do
      assert {:ok, %User{username: "test"}} = Users.create_user(%{username: "test"})
    end

    test "with username too short" do
      assert {:error, changeset} = Users.create_user(%{username: "a"})
      refute changeset.valid?
      assert errors_on(changeset) == %{username: ["should be at least 3 character(s)"]}
    end

    test "with username too long" do
      assert {:error, changeset} = Users.create_user(%{username: String.duplicate("a", 31)})
      refute changeset.valid?
      assert errors_on(changeset) == %{username: ["should be at most 30 character(s)"]}
    end

    test "duplicate username" do
      assert {:ok, %User{username: "test"}} = Users.create_user(%{username: "test"})
      assert {:error, changeset} = Users.create_user(%{username: "test"})
      refute changeset.valid?
      assert errors_on(changeset) == %{username: ["already exists"]}
    end
  end

  describe "get_user_by_username/1" do
    test "when no user exists" do
      refute Users.get_user_by_username("test1")
    end

    test "when user exists" do
      assert {:ok, %User{username: "test"} = user} = Users.create_user(%{username: "test"})
      assert user == Users.get_user_by_username("test")
    end
  end
end
