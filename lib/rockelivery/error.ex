defmodule Rockelivery.Error do
  @keys ~w[status result]a

  @enforce_keys @keys

  defstruct @keys

  def build(status, result), do: %__MODULE__{status: status, result: result}

  def build_user_not_found_error(id \\ nil) do
    if id do
      build(:not_found, "User not found: [#{id}]")
    else
      build(:not_found, "User not found")
    end
  end
end
