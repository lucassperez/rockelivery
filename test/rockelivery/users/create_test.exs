defmodule Rockelivery.Users.CreateTest do
  use Rockelivery.DataCase, async: true

  alias Rockelivery.Error
  alias Rockelivery.User
  alias Rockelivery.Users.Create

  describe "call/1" do
    test "when all params are valid, it returns the user" do
      params = %{
        address: "Rua Legal, 123",
        age: 25,
        cep: "12345678",
        cpf: "12345678901",
        email: "teste@email.com",
        name: "Lucas",
        password: "123456"
      }

      response = Create.call(params)

      assert {
        :ok,
        %User{
          address: "Rua Legal, 123",
          age: 25,
          cep: "12345678",
          cpf: "12345678901",
          email: "teste@email.com",
          name: "Lucas",
          password: "123456"
        }
      } = response
    end

    test "when there are invalid params, it returns an error" do
      params = %{
        address: "Rua Legal, 123",
        age: 17,
        cep: 123,
        cpf: "1238901",
        email: "teste@com",
        name: "Lucas",
        password: "123"
      }

      result = Create.call(params)
      {:error, %Error{result: changeset}} = result
      search_result = Rockelivery.Repo.all(User)

      assert search_result == []
      assert {:error, %Error{status: :bad_request}} = result
      assert errors_on(changeset) == %{
        age: ["must be greater than or equal to 18"],
        cep: ["is invalid"],
        cpf: ["has invalid format"],
        email: ["has invalid format"],
        password: ["should be at least 6 character(s)"]
      }
    end
  end
end
