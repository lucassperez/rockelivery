defmodule Rockelivery.Factory do
  use ExMachina.Ecto, repo: Rockelivery.Repo

  alias Rockelivery.User

  def user_factory do
    %User{
      address: "Rua Legal, 123",
      age: 25,
      cep: "12345678",
      cpf: "12345678901",
      email: "teste@email.com",
      name: "Lucas",
      password: "123456",
      id: Ecto.UUID.generate()
    }
  end
end
