defmodule RockeliveryWeb.UsersViewTest do
  use RockeliveryWeb.ConnCase, async: true

  import Phoenix.View
  import Rockelivery.Factory

  alias Rockelivery.User
  alias RockeliveryWeb.UsersView
  alias RockeliveryWeb.Auth.Guardian

  test "renders create.json" do
    user = insert(:user, name: "Eu", address: "Aqui")
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    response = render(UsersView, "create.json", user: user, token: token)

    assert %{
      message: "User created",
      token: ^token,
      user: %User{
        name: "Eu",
        address: "Aqui",
        age: _,
        cep: _,
        cpf: _,
        email: _
      }
    } = response
    assert Map.keys(response) == [:message, :token, :user]
  end
end
