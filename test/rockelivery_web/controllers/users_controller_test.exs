defmodule RockeliveryWeb.UsersControllerTest do
  use RockeliveryWeb.ConnCase, async: true

  import Rockelivery.Factory

  setup do
    params = %{
      "address" => "Rua Legal, 123",
      "age" => 25,
      "cep" => "12345678",
      "cpf" => "12345678901",
      "email" => "teste@email.com",
      "name" => "Lucas",
      "password" => "123456"
    }

    {:ok, params: params}
  end

  describe "create/2" do
    test """
    when all params are valid, it creates the user
    """, %{conn: conn, params: params} do
      response =
        conn
        |> post(Routes.users_path(conn, :create, params))
        |> json_response(:created)

      assert %{
        "message" => "User created",
        "user" => %{
          "cpf" => "12345678901",
          "email" => "teste@email.com",
          "id" => _uuid,
          "name" => "Lucas"
        }
      } = response
    end

    test """
    when there is some error, it returns an error
    """, %{conn: conn} do
      params = %{
        "password" => "123456",
        "name" => "Lucas"
      }

      response =
        conn
        |> post(Routes.users_path(conn, :create, params))
        |> json_response(:bad_request)

      assert response == %{
        "message" => %{
          "address" => ["can't be blank"],
          "age" => ["can't be blank"],
          "cep" => ["can't be blank"],
          "cpf" => ["can't be blank"],
          "email" => ["can't be blank"]
        }
      }
    end
  end

  describe "delete/2" do
    test """
    when there is a user with the given id, it deletes the user
    """, %{conn: conn} do
      %{id: id} = insert(:user)

      response =
        conn
        |> delete(Routes.users_path(conn, :delete, id))
        |> response(:no_content)

      assert response == ""
    end
  end
end
