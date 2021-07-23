defmodule Rockelivery.Users.Delete do
  alias Rockelivery.{Repo, User}
  alias Ecto.UUID

  def call(id) do
    case UUID.cast(id) do
      :error -> {:error, %{status: :bad_request, result: "Invalid ID format"}}
      {:ok, uuid} -> delete(uuid)
    end
  end

  defp delete(id) do
    case Repo.get(User, id) do
      nil -> {:error, %{status: :not_found, result: "User not found: [#{id}]"}}
      %User{} = user -> Repo.delete(user)
    end
  end
end
