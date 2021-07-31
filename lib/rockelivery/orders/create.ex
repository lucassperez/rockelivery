defmodule Rockelivery.Orders.Create do
  import Ecto.Query
  alias Rockelivery.{Error, Item, Order, Repo}

  def call(params) do
    params
    |> fetch_items()
    |> handle_items(params)
  end

  defp fetch_items(%{"items" => items_params}) do
    items_ids = Enum.map(items_params, fn item -> item["id"] end)

    query = from(item in Item, where: item.id in ^items_ids)

    query
    |> Repo.all()
    |> validate_items(items_ids)
    |> multiply_items_if_valid(items_params)
  end

  defp validate_items(items, items_ids) do
    items_map = Map.new(items, fn item -> {item.id, item} end)

    items_ids
    |> Enum.map(fn id -> {id, Map.get(items_map, id)} end)
    |> Enum.any?(fn {_id, value} -> is_nil(value) end)
    |> fn items_invalid? ->
      if items_invalid? do
        {:error, "Invalid item id"}
      else
        {:ok, items_map}
      end
    end.()
  end

  defp multiply_items_if_valid({:error, reason}, _items_params),
    do: {:error, reason}

  defp multiply_items_if_valid({:ok, items_map}, items_params) do
    items_list =
      items_params
      |> Enum.reduce([], fn %{"id" => id, "quantity" => quantity}, acc ->
        item = Map.get(items_map, id)
        List.duplicate(item, quantity) ++ acc
      end)

    {:ok, items_list}
  end

  defp handle_items({:ok, items_list}, params) do
    params
    |> Order.changeset(items_list)
    |> Repo.insert()
    |> handle_insert()
  end

  defp handle_items({:error, reason}, _params),
    do: handle_insert({:error, reason})

  defp handle_insert({:ok, %Order{} = order}), do: {:ok, order}

  defp handle_insert({:error, reason}) do
    {:error, Error.build(:bad_request, reason)}
  end
end
