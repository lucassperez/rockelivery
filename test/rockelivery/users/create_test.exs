defmodule Rockelivery.Users.CreateTest do
  use Rockelivery.DataCase, async: true

  import Mox

  alias Rockelivery.{Error, User}
  alias Rockelivery.Users.Create
  alias Rockelivery.Users.Create
  alias Rockelivery.ViaCep.ClientMock

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

      expect(ClientMock, :get_cep_info, fn _cep ->
        {
          :ok,
          %{
            "bairro" => "Sé",
            "cep" => "01001-000",
            "complemento" => "lado ímpar",
            "ddd" => "11",
            "gia" => "1004",
            "ibge" => "3550308",
            "localidade" => "São Paulo",
            "logradouro" => "Praça da Sé",
            "siafi" => "7107",
            "uf" => "SP"
          }
        }
      end)

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
