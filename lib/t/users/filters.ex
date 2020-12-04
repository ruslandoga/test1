defmodule T.Users.Filters do
  use Ecto.Schema

  # users:filters:(user_id)
  embedded_schema do
    field :age_filter_min, :integer
    field :age_filter_max, :integer
    field :gender_filter, :string
    field :distance_filter, :decimal
  end
end
