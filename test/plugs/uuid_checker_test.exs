defmodule RockeliveryWeb.Plugs.UUIDCheckerTest do
  use RockeliveryWeb.ConnCase, async: true
  use Plug.Test

  alias RockeliveryWeb.Plugs.UUIDChecker

  import Rockelivery.Factory

  @opts UUIDChecker.init([])

  test "when ID is a valid uuid, it returns the connection" do
    id = Ecto.UUID.generate()
    insert(:user, id: id)

    conn =
      conn(:get, "/api/users/#{id}")
      |> Map.put(:params, %{"id" => id})

    conn = UUIDChecker.call(conn, @opts)

    refute conn.halted
  end

  test """
  when ID is not a valid uuid, it halts the connection
  """ do
    id = "6dc714c4"

    conn =
      conn(:get, "/api/users/#{id}")
      |> Map.put(:params, %{"id" => id})

    conn = UUIDChecker.call(conn, @opts)

    assert conn.halted
    assert conn.status == 400
    assert Enum.member?(
      conn.resp_headers,
      {"content-type", "application/json; charset=utf-8"}
    )
    assert conn.resp_body == "{\"message\":\"Invalid ID format\"}"
    assert conn.state == :sent
  end

  test """
  when ID is not passed, it does nothing
  """ do
    conn = conn(:get, "/api/users")

    assert conn == UUIDChecker.call(conn, @opts)
  end
end
