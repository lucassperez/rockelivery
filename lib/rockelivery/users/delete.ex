defmodule Rockelivery.Users.Delete do
  alias Ecto.UUID
  alias Rockelivery.{Error, Repo, User}

  def call(id) do
    with {:ok, _uuid} <- UUID.cast(id),
         %User{} = user <- Repo.get(User, id) do
      Repo.delete(user)
    else
      :error -> {:error, Error.build_id_format_error()}
      nil -> {:error, Error.build_user_not_found_error(id)}
    end
  end
end
