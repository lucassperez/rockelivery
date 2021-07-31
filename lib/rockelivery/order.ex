defmodule Rockelivery.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rockelivery.{Item, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_params ~w[address payment_method user_id]a

  @derive {Jason.Encoder, only: @required_params ++ ~w[id comments items]a}

  schema "orders" do
    field :address, :string
    field :comments, :string
    field :payment_method, Ecto.Enum, values: ~w[money credit_card debit_card]a

    many_to_many :items, Item, join_through: "orders_items"
    belongs_to :user, User

    timestamps()
  end

  def changeset(params, items) do
    %__MODULE__{}
    |> cast(params, @required_params ++ [:comments])
    |> validate_required(@required_params)
    |> put_assoc(:items, items)
  end
end
