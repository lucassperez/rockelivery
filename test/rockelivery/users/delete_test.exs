defmodule Rockelivery.Users.DeleteTest do
  use Rockelivery.DataCase, async: true

  alias Rockelivery.Error
  alias Rockelivery.User
  alias Rockelivery.Users.Delete

  import Rockelivery.Factory

  describe "call/1" do
    test "when the user exists, it deletes it" do
      id = Ecto.UUID.generate()
      insert(:user, id: id)

      result = Delete.call(id)

      assert Rockelivery.Repo.get(User, id) == nil

      assert {
        :ok,
        %User{
          address: "Rua Legal, 123",
          age: 25,
          cep: "12345678",
          cpf: "12345678901",
          email: "teste@email.com",
          name: "Lucas",
          id: ^id
        }
      } = result
    end

    test "when the user does not exists, it returns an error" do
      id = Ecto.UUID.generate()

      result = Delete.call(id)

      assert result == {
        :error,
        %Error{
          result: "User not found: [#{id}]",
          status: :not_found
        }
      }
    end
  end
end
