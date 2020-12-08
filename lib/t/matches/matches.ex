defmodule T.Matches do
  @moduledoc """
  - likes:{from_user_id}:{to_user_id}
  - passes:{from_user_id}:{to_user_id}
  - seen:{swiper_id}:{swipee_id}

  - matches:{user_id}:{user_id} (one for each user)
  - matches:{user_id}:{user_id}

  - recommened:{user_id}:{user_id}
  """

  # TODO timestamp somewhere
  def like(from_id, to_id) do
    T.transact(fn tr ->
      FDB.Transaction.set(tr, {from_id, to_id}, nil, %{coder: T.likes_coder()})
      FDB.Transaction.set(tr, {from_id, to_id}, nil, %{coder: T.seen_coder()})

      # TODO if the other user has also liked us, create matches
      # TODO if the other user hasn't liked us, make sure we recommend from_id profile to to_id
    end)
  end

  def pass(from_id, to_id) do
    T.transact(fn tr ->
      FDB.Transaction.set(tr, {from_id, to_id}, nil, %{coder: T.pass_coder()})
      FDB.Transaction.set(tr, {from_id, to_id}, nil, %{coder: T.seen_coder()})
    end)
  end

  # TODO order matches by timestamp?
  def get_matches_stream(user_id) do
    T.transact(fn tr ->
      range = FDB.KeySelectorRange.starts_with({user_id})
      FDB.Transaction.get_range_stream(tr, range, %{coder: T.matches_coder()})
    end)
  end
end