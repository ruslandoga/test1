defmodule T.Users.User do
  use Ecto.Schema

  # users:(user_id,profile)
  embedded_schema do
    field :username, :string

    # field :lat, :decimal
    # field :lon, :decimal
    field :geohash, :string

    # field :bio, :string
    # field :profile_image_urls, {:array, :string}

    field :gender, :string
    field :age, :integer

    # JOB:
    # %{
    #   "company" => %{"id" => "TODO", "name" => "University of Miami", "displayed" => true},
    #   "title" => %{"id" => "TODO", "name" => "Research Assistant", "displayed" => true}
    # }

    # field :job, :map

    # # SCHOOLS:
    # # [%{"id" => "school_id_TODO"}]
    # field :schools, {:array, :map}
  end
end
