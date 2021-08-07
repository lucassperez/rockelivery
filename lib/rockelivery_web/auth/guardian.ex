defmodule RockeliveryWeb.Auth.Guardian do
  use Guardian, otp_app: :rockelivery

  alias Rockelivery.{Error, User}

  def subject_for_token(%User{id: id}, _claims), do: {:ok, id}

  def resource_from_claims(claims) do
    claims
    |> Map.get("sub")
    |> Rockelivery.get_user_by_id()
  end

  def authenticate(%{"id" => user_id, "password" => password}) do
    with {:ok, ^user_id} <-
            Ecto.UUID.cast(user_id),
         {:ok, %User{password_hash: password_hash} = user} <-
           Rockelivery.get_user_by_id(user_id),
         true <-
           Pbkdf2.verify_pass(password, password_hash),
         {:ok, token, _claims} <-
           encode_and_sign(user) do
      {:ok, token}
    else
      false ->
        {:error, Error.build(:unauthorized, "Invalid credentials")}

      :error ->
        {:error, Error.build(:bad_request, "Invalid ID format")}

      error ->
        error
    end
  end

  def authenticate(_),
    do: {:error, Error.build(:bad_request, "Parameters missing")}
end
