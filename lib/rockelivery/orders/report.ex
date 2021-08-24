defmodule Rockelivery.Orders.Report do
  import Ecto.Query

  alias Rockelivery.{Item, Order, Repo}
  alias Rockelivery.Orders.CalculateTotalPrice

  @chunk_size 500

  def create(filename \\ "report.csv") do
    query = from order in Order, order_by: order.user_id

    {:ok, order_list} =
      Repo.transaction(fn ->
        query
        |> Repo.stream(max_rows: @chunk_size)
        |> Stream.chunk_every(@chunk_size)
        |> Stream.flat_map(&Repo.preload(&1, :items))
        |> Enum.map(&parse_line/1)
      end)

    File.write("reports/#{filename}", order_list)
  end

  defp parse_line(
    %Order{user_id: user_id, payment_method: payment_method, items: items}
  ) do
    total_price = CalculateTotalPrice.call(items)
    "#{user_id},#{payment_method},#{items_string(items)},#{total_price}\n"
  end

  defp items_string(items, acc \\ "")

  defp items_string([], acc), do: acc

  defp items_string([item | rest], "") do
    items_string(rest, item_string(item))
  end

  defp items_string([item | rest], acc) do
    items_string(rest, acc <> "," <> item_string(item))
  end

  defp item_string(
    %Item{category: category, description: description, price: price}
  ) do
    "#{category},#{description},#{price}"
  end
end
