defmodule Domain.Entities.Tax do
  alias Domain.Entities.Operation

  @required_fields [:tax]
  @enforce_keys @required_fields
  defstruct @required_fields

  @twenty_percent_profit_tax 0.2

  @type t :: %__MODULE__{
    tax: number(),
  }


  @spec calculate_tax([Operation.t()]) :: list()
  def calculate_tax(operations) do
    {:ok, damage} = Agent.start_link(fn -> 0 end)
    {:ok, average_purchase_price} = Agent.start_link(fn -> 0 end)
    {:ok, list_of_buy} = Agent.start_link(fn -> [] end)

    Enum.map(operations, fn operation ->
      IO.inspect(operation)
      if operation.type == "buy" do
        Agent.update(list_of_buy, fn list -> [operation | list] end)
        operations_list = Agent.get(list_of_buy, fn list -> list end)
        Agent.update(average_purchase_price, fn _number -> Operation.weighted_average_purchase_price(operations_list) end)
      end

      weighted_average_purchase_price = Agent.get(average_purchase_price, fn number -> number end)
      IO.inspect(weighted_average_purchase_price, label: "weighted_average_purchase_price")

      has_damage = operation.unit_cost < weighted_average_purchase_price
      has_profit = operation.unit_cost > weighted_average_purchase_price

      cond do
        operation.type == "buy" -> 0
        has_damage ->
          Agent.update(damage, fn number ->
            IO.inspect(number, label: "damage_state")
            (calculate_damage(operation, weighted_average_purchase_price) + number) |> IO.inspect(label: "damage") end)
          0
        has_profit ->
          profit = calculate_profit(operation, weighted_average_purchase_price)
          damages_to_pay = Agent.get(damage, fn number -> number |> IO.inspect(label: "damage_to_pai") end)
          result = (damages_to_pay + profit)

          if result > 0 do
            result * @twenty_percent_profit_tax
          else
            Agent.update(damage, fn _number -> result end)
            0
          end
        true -> 0
      end
    end)
    |> IO.inspect()
  end

  defp calculate_profit(operation, weighted_average_purchase_price) do
    ((operation.unit_cost - weighted_average_purchase_price) * operation.quantity) |> IO.inspect(label: "calculate_profit")
  end

  defp calculate_damage(operation, weighted_average_purchase_price) do
    (operation.unit_cost - weighted_average_purchase_price) * operation.quantity
  end
end
