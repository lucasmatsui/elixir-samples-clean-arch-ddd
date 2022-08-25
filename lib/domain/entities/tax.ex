defmodule Domain.Entities.Tax do
  alias Domain.Entities.Operation

  @required_fields [:tax]
  @enforce_keys @required_fields
  defstruct @required_fields

  @spec calculate_tax([Operation.t()], float()) :: number()
  def calculate_tax(operations, weighted_average_purchase_price) do
    {:ok, agent} = Agent.start_link(fn -> 0 end)

    Enum.map(operations, fn operation ->
      has_damage = operation.unit_cost < weighted_average_purchase_price
      has_profit = operation.unit_cost > weighted_average_purchase_price

      cond do
        has_damage ->
          Agent.update(agent, fn _number ->
            total_operation_value(operation.quantity, operation.unit_cost)
          end)
        has_profit ->
          (operation.unit_cost - weighted_average_purchase_price)
        true -> 0
      end
    end)
  end

  defp total_operation_value(quantity, unit_cost) do
    quantity * unit_cost
  end
end
