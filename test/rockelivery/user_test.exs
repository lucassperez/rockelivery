defmodule Rockelivery.UserTest do
  use Rockelivery.DataCase, async: true

  alias Ecto.Changeset
  alias Rockelivery.User

  setup do
    params = %{
      address: "Rua Legal, 123",
      age: 25,
      cep: "12345678",
      cpf: "12345678901",
      email: "teste@email.com",
      name: "Lucas",
      password: "123456"
    }

    {:ok, params: params}
  end

  describe "changeset/1" do
    test """
         when params are valid, it returns a valid changeset
    """,
    %{params: params} do
      response = User.changeset(params)

      assert %Changeset{
        changes: %{
          address: "Rua Legal, 123",
          age: 25,
          cep: "12345678",
          cpf: "12345678901",
          email: "teste@email.com",
          name: "Lucas",
          password: "123456"
        },
        valid?: true
      } = response
    end

    test "all fields are required" do
      response = User.changeset(%{})

      assert %Changeset{
        valid?: false,
        errors: [
          address: {"can't be blank", _},
          age: {"can't be blank", _},
          cep: {"can't be blank", _},
          cpf: {"can't be blank", _},
          email: {"can't be blank", _},
          name: {"can't be blank", _},
          password: {"can't be blank", _}
        ]
      } = response
    end

    test """
         when params are invalid, it returns an invalid changeset
         """,
         %{params: params} do
           params = %{
             params
             | age: 17,
             cep: 123,
             cpf: "1238901",
             email: "teste@com",
             password: "123"
           }

           response = User.changeset(params)

           assert %Changeset{
             valid?: false,
             errors: [
               age: {"must be greater than or equal to " <> _number, _},
               email: {"has invalid format", _},
               cpf: {"has invalid format", _},
               password: {
                 "should be at least %{count} character(s)",
                 [{:count, 6} | _]
               },
               cep: {"is invalid", _}
             ]
           } = response
         end
  end

  describe "changeset/2" do
    test """
    when update params are valid, it returns a valid changeset
    """,
    %{params: params} do
      changeset = User.changeset(params)

      update_params = %{
        name: "Juliana",
        age: 24,
        address: "Rua Ainda Mais Legal, 456",
        cep: "09876543",
        cpf: "09876543210",
        email: "ju@liana.com"
      }

      response = User.changeset(changeset, update_params)

      assert %Changeset{
        changes: %{
          name: "Juliana",
          age: 24,
          address: "Rua Ainda Mais Legal, 456",
          cep: "09876543",
          cpf: "09876543210",
          email: "ju@liana.com"
        },
        valid?: true
      } = response
    end

    test """
    when params are invalid, it returns an invalid changeset
    """,
    %{params: params} do
      params = %{
        params
        | age: 17,
        cep: 123,
        cpf: "1238901",
        email: "teste@com",
        password: "123"
      }

      response = User.changeset(params)

      assert errors_on(response) == %{
        age: ["must be greater than or equal to 18"],
        cep: ["is invalid"],
        cpf: ["has invalid format"],
        email: ["has invalid format"],
        password: ["should be at least 6 character(s)"]
      }
    end
  end
end
