defmodule RockeliveryWeb.UsersControllerTest do
  use RockeliveryWeb.ConnCase, async: true

  import Mox
  import Rockelivery.Factory

  alias Rockelivery.User
  alias Rockelivery.ViaCep.ClientMock
  alias RockeliveryWeb.Auth.Guardian

  setup %{conn: conn} do
    user = insert(:user, cpf: "09876543210", email: "testesetup@email.com")
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")

    params = %{
      "address" => "Rua Legal, 123",
      "age" => 25,
      "cep" => "12345678",
      "cpf" => "12345678901",
      "email" => "teste@email.com",
      "name" => "Lucas",
      "password" => "123456"
    }

    {:ok, params: params, conn: conn}
  end

  describe "show/2" do
    test "when user exists, it shows the user", %{conn: conn} do
      id = Ecto.UUID.generate()
      insert(:user, id: id, name: "Lucy", cpf: "12345678901", email: "l@uc.com")

      response =
        conn
        |> get(Routes.users_path(conn, :show, id))
        |> json_response(:ok)

      assert %{
        "user" => %{
          "cpf" => "12345678901",
          "name" => "Lucy",
          "email" => "l@uc.com",
          "id" => ^id
        }
      } = response
    end

    test "when user does not exists, it shows an error", %{conn: conn} do
      id = Ecto.UUID.generate()

      response =
        conn
        |> get(Routes.users_path(conn, :show, id))
        |> json_response(:not_found)

      assert response == %{"message" => "User not found: [#{id}]"}
    end
  end

  describe "create/2" do
    test """
    when all params are valid, it creates the user
    """, %{conn: conn, params: params} do
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

    test "when there are invalid params, it shows an error", %{conn: conn} do
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

  describe "update/2" do
    test """
    when the user exists and all params are valid, it updates the user
    """, %{conn: conn} do
      %{id: id, cpf: cpf, email: email}  = insert(:user)

      params = %{
        "id" => id,
        "name" => "Juliana"
      }

      response =
        conn
        |> patch(Routes.users_path(conn, :update, id, params))
        |> json_response(:ok)

      updated_user = Rockelivery.get_user_by_id(id)

      assert {:ok, %User{name: "Juliana"}} = updated_user

      assert %{
        "user" => %{
          "name" => "Juliana",
          "cpf" => ^cpf,
          "email" => ^email,
          "id" => ^id
        }
      } = response
    end

    test """
    when the user exists but there are invalid params, it shows an error
    """, %{conn: conn} do
      id = Ecto.UUID.generate()
      insert(:user, id: id)

      params = %{
        "id" => id,
        "cpf" => "123",
        "cep" => "456",
        "email" => "email@inválido.com.br"
      }

      response =
        conn
        |> patch(Routes.users_path(conn, :update, id, params))
        |> json_response(:bad_request)

      assert response == %{
        "message" => %{
          "cep" => ["has invalid format"],
          "cpf" => ["has invalid format"]
        }
      }
    end

    test """
    when the user does not exists, it shows an error
    """, %{conn: conn, params: params} do
      id = Ecto.UUID.generate()

      response =
        conn
        |> patch(Routes.users_path(conn, :update, id, params))
        |> json_response(:not_found)

      assert response == %{"message" => "User not found: [#{id}]"}
    end
  end

  describe "delete/2" do
    test """
    when there is a user with the given id, it deletes the user
    """, %{conn: conn} do
      user = insert(:user)

      response =
        conn
        |> delete(Routes.users_path(conn, :delete, user.id))
        |> response(:no_content)

      assert response == ""
    end

    test """
    when there is no user with the given id, it shows an error
    """, %{conn: conn} do
      id = Ecto.UUID.generate()

      response =
        conn
        |> delete(Routes.users_path(conn, :delete, id))
        |> json_response(:not_found)

      assert response == %{"message" => "User not found: [#{id}]"}
    end
  end
end
