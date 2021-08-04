defmodule Rockelivery.Users.Create do
  alias Rockelivery.{Error, Repo, User}
  alias Rockelivery.ViaCep.Client, as: ViaCepClient

  def call(%{"cep" => cep} = params) do
    changeset = User.changeset(params)

    with {:ok, %User{}} <- User.build(changeset),
         {:ok, _cep_info} <- ViaCepClient.get_cep_info(cep),
         {:ok, %User{} = user} <- Repo.insert(changeset)
    do
      {:ok, user}
    else
      {:error, %Error{} = error} -> {:error, error}
      {:error, result} -> {:error, Error.build(:bad_request, result)}
    end
  end
end
