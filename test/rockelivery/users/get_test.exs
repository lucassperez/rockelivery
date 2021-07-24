defmodule Rockelivery.Users.GetTest do
  use Rockelivery.DataCase, async: true

  alias Rockelivery.Error
  alias Rockelivery.User
  alias Rockelivery.Users.Get

  import Rockelivery.Factory

  describe "by_id/1" do
    test """
    when user with the specified id exists, it returns the user
    """ do
      id = Ecto.UUID.generate()
      insert(:user, id: id)

      response = Get.by_id(id)

      assert {
        :ok,
        %User{
          address: "Rua Legal, 123",
          age: 25,
          cep: "12345678",
          cpf: "12345678901",
          email: "teste@email.com",
          name: "Lucas",
          id: ^id,
          password_hash: _password_hash
        }
      } = response
    end

    test """
    when user with the specified id does not exists, it returns an error
    """ do
      id = Ecto.UUID.generate()

      result = Get.by_id(id)

      assert result == {
        :error,
        %Error{
          result: "User not found: [#{id}]",
          status: :not_found
        }
      }
    end

    test """
    when the id is not a valid uuid4, it returns an error
    """ do
      assert_raise(
        Ecto.Query.CastError,
        ~r/value `1` in `where` cannot be cast to type :binary_id/,
        fn -> Get.by_id(1) end
      )
    end
  end
end
