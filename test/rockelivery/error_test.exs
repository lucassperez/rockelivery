defmodule Rockelivery.ErrorTest do
  use ExUnit.Case

  alias Rockelivery.Error

  describe "build/2" do
    test "it returns a struct with status and result" do
      result = Error.build(:error_status, "Error message")

      assert result == %Error{status: :error_status, result: "Error message"}
    end
  end

  describe "build_user_not_found_error/0" do
    test "it returns a struct with status not_found and a not found message" do
      result = Error.build_user_not_found_error()

      assert result == %Error{
        status: :not_found,
        result: "User not found"
      }
    end
  end

  describe "build_user_not_found_error/1" do
    test "it returns a struct with status not_found and a not found message" do
      id = Ecto.UUID.generate()
      result = Error.build_user_not_found_error(id)

      assert result == %Error{
        status: :not_found,
        result: "User not found: [#{id}]"
      }
    end
  end
end
