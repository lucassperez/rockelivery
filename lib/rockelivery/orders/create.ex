defmodule Rockelivery.Orders.Create do
  import Ecto.Query
  alias Rockelivery.{Error, Item, Order, Repo, User}
  alias Rockelivery.Orders.ValidateAndMultiplyItems
  alias Rockelivery.Users.Get, as: UserGet

  def call(params) do
    with {:ok, %User{}} <- UserGet.by_id(params["user_id"]),
         {:ok, items_list} <- fetch_items(params),
         {:ok, %Order{} = order} <- handle_items(items_list, params) do
      {:ok, order}
    else
      {:error, %Error{} = error} -> {:error, error}
      {:error, reason} -> {:error, Error.build(:bad_request, reason)}
    end
  end

  defp fetch_items(%{"items" => items_params}) do
    items_ids = Enum.map(items_params, fn item -> item["id"] end)

    query = from(item in Item, where: item.id in ^items_ids)

    query
    |> Repo.all()
    |> ValidateAndMultiplyItems.call(items_ids, items_params)
  end

  defp handle_items(items_list, params) do
    params
    |> Order.changeset(items_list)
    |> Repo.insert()
  end
end
