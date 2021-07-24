defmodule Rockelivery.Users.UpdateTest do
  use Rockelivery.DataCase, async: true

  alias Rockelivery.Error
  alias Rockelivery.User
  alias Rockelivery.Users.Update

  import Rockelivery.Factory

  describe "call/1" do
    test "when the user exists and all params are valid, it updates the user" do
      id = Ecto.UUID.generate()
      insert(:user, id: id)
      params = %{
        "address" => "Rua Mais Legal, 456",
        "age" => 24,
        "cep" => "09876543",
        "cpf" => "09876543210",
        "email" => "ju@liana.com.br",
        "name" => "Juliana",
        "id" => id
      }

      result = Update.call(params)
      updated_user = Rockelivery.Repo.get(User, id)

      assert {:ok, %User{}} = result
      assert %User{
        address: "Rua Mais Legal, 456",
        age: 24,
        cep: "09876543",
        cpf: "09876543210",
        email: "ju@liana.com.br",
        name: "Juliana",
        id: ^id
      } = updated_user
    end

    test "when the user does not exists, it returns an error" do
      id = Ecto.UUID.generate()
      params = %{"age" => 24, "id" => id}

      result = Update.call(params)

      assert result == {
        :error,
        %Error{
          result: "User not found: [#{id}]",
          status: :not_found
        }
      }
    end

    test """
    when the user exists but there are invalid params, it does not update the
    user and returns an error
    """ do
      id = Ecto.UUID.generate()
      user = insert(:user, id: id)
      params = %{
        "cep" => "98",
        "cpf" => "98",
        "email" => "ju@com",
        "id" => id
      }

      result = Update.call(params)
      {:error, changeset} = result
      updated_user =
        Rockelivery.Repo.get(User, id)
        |> Map.put(:password, user.password)

      assert {:error, %Changeset{}} = result
      assert errors_on(changeset) == %{
        cep: ["has invalid format"],
        cpf: ["has invalid format"],
        email: ["has invalid format"],
      }
      assert user == updated_user
    end
  end
end
