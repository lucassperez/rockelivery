defmodule RockeliveryWeb.UsersViewTest do
  use RockeliveryWeb.ConnCase, async: true

  import Phoenix.View
  import Rockelivery.Factory

  alias Rockelivery.User
  alias RockeliveryWeb.UsersView

  test "renders create.json" do
    user = build(:user, name: "Eu", address: "Aqui")

    response = render(UsersView, "create.json", user: user)

    assert %{
      message: "User created",
      user: %User{
        name: "Eu",
        address: "Aqui"
      }
    } = response
  end
end
