defmodule T.Users.User do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :username, :string
  end
end
