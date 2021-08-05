defmodule Rockelivery.Orders.ValidateAndMultiplyItems do
  def call(items, items_ids, items_params) do
    items_map = Map.new(items, fn item -> {item.id, item} end)

    items_ids
    |> Enum.map(fn id -> {id, Map.get(items_map, id)} end)
    |> Enum.any?(fn {_id, value} -> is_nil(value) end)
    |> (fn items_invalid? ->
          if items_invalid? do
            {:error, "Invalid item id"}
          else
            {:ok, items_map}
          end
        end).()
    |> multiply_items_if_valid(items_params)
  end

  defp multiply_items_if_valid({:error, reason}, _items_params),
    do: {:error, reason}

  defp multiply_items_if_valid({:ok, items_map}, items_params) do
    items_list =
      items_params
      |> Enum.reduce_while([], fn %{"id" => id, "quantity" => quantity}, acc ->
        if quantity > 0 do
          item = Map.get(items_map, id)
          {:cont, List.duplicate(item, quantity) ++ acc}
        else
          {:halt, {:error, "Item quantity has to be greater than zero"}}
        end
      end)

    case items_list do
      {:error, reason} -> {:error, reason}
      _ -> {:ok, items_list}
    end
  end
end
