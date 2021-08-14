defmodule Rockelivery.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rockelivery.Order

  @primary_key {:id, :binary_id, autogenerate: true}

  @required_params ~w[address age cep cpf email name password]a
  @update_params @required_params -- [:password]

  @derive {Jason.Encoder, only: ~w[id name cpf email]a}

  schema "users" do
    field :address, :string
    field :age, :integer
    field :cep, :string
    field :cpf, :string
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    has_many :orders, Order

    timestamps()
  end

  def build(changeset), do: apply_action(changeset, :create)

  def changeset(params) do
    %__MODULE__{}
    |> changes(params, @required_params)
  end

  def changeset(struct, params) do
    struct
    |> changes(params, @update_params)
  end

  defp changes(struct, params, fields) do
    struct
    |> cast(params, fields)
    |> validate_required(fields)
    |> validate_length(:password, min: 6)
    |> validate_format(:cep, ~r/^\d{5}[\.\-]?\d{3}$/)
    |> validate_format(:cpf, ~r/^\d{3}\.?\d{3}\.?\d{3}\.?\d{2}$/)
    |> validate_format(:email, ~r/^.+@.+\.com(\.\w+)?$/)
    |> validate_number(:age, greater_than_or_equal_to: 18)
    |> unique_constraint([:email])
    |> unique_constraint([:cpf])
    |> put_password_hash()
  end

  defp put_password_hash(
    %Ecto.Changeset{
      valid?: true,
      changes: %{
        password: password
      }
    } = changeset
  ) do
    change(changeset, Pbkdf2.add_hash(password))
  end

  defp put_password_hash(changeset), do: changeset
end
