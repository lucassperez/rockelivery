defmodule Rockelivery.Orders.Create do
  import Ecto.Query
  alias Rockelivery.{Error, Item, Order, Repo}
  alias Rockelivery.Orders.ValidateAndMultiplyItems

  def call(params) do
    with {:ok, items_list} <- fetch_items(params),
         {:ok, %Order{} = order} <- handle_items(items_list, params)
    do
      {:ok, order}
    else
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
