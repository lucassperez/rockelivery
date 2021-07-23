defmodule Rockelivery.Users.Update do
  alias Ecto.UUID
  alias Rockelivery.{Error, Repo, User}

  def call(%{"id" => id} = params) do
    with {:ok, _uuid} <- UUID.cast(id),
         %User{} = user <- Repo.get(User, id) do
      update(user, params)
    else
      :error -> {:error, Error.build_id_format_error()}
      nil -> {:error, Error.build_user_not_found_error(id)}
    end
  end

  defp update(user, params) do
    user
    |> User.changeset(params)
    |> Repo.update()
  end
end
