defmodule T.Users.LastActive do
  @moduledoc """
  Every action should increase "last active" timestamp of the user.
  A higher timestamp means the user is more likely to interact with their matches on the platform.
  """
  alias T.Users.User

  def update_last_active(tr, %User{id: user_id}) do
    # FDB.Transaction.set(tr, {DateTime.utc_now(), user_id}, )
  end
end
