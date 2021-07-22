defmodule Rockelivery.Users.Get do
  alias Rockelivery.{Repo, User}
  alias Ecto.UUID

  def by_id(id) do
    with {:ok, _uuid} <- UUID.cast(id),
         %User{} = user <- Repo.get(User, id) do
      {:ok, user}
    else
      :error -> {:error, %{status: :bad_request, result: "Invalid ID format"}}
      nil -> {:error, %{status: :not_found, result: "User not found: [#{id}]"}}
    end
  end
end
