defmodule Domain.Entities.Tax do
  alias Domain.Entities.Operation
  alias Domain.OperationAgent

  @required_fields [:tax]
  @enforce_keys @required_fields
  defstruct @required_fields

  @twenty_percent_profit_tax 0.2
  @zero_tax 0

  @type t :: %__MODULE__{
    tax: number(),
  }

  @spec calculate_taxs([Operation.t()]) :: [number()]
  def calculate_taxs(operations) do
    all_state_agents = OperationAgent.start_all_agents_links()
    Enum.map(operations, &calculate_tax(OperationAgent.new(&1, all_state_agents)))
  end

  defp calculate_tax(agents_operation) do
    Operation.calculate_weighted_average_purchase_price(agents_operation)

    cond do
      agents_operation.operation.type == "buy" -> @zero_tax
      Operation.has_damage(agents_operation) ->
        Operation.calculate_damage(agents_operation)
        @zero_tax
      Operation.has_profit(agents_operation) ->
        calculate_profit(agents_operation)
      true -> @zero_tax
    end
  end

  defp calculate_profit(agents_operation) do
    damages_minus_profit = Operation.calculate_profit_after_damages(agents_operation)
    has_profit_after_damage = damages_minus_profit > 0
    has_damage = true

    cond do
      Operation.total_operation(agents_operation.operation) < 20_000 -> @zero_tax
      has_profit_after_damage -> damages_minus_profit * @twenty_percent_profit_tax
      has_damage ->
        Operation.change_damage(agents_operation.agents.damage, damages_minus_profit)
        @zero_tax
    end
  end
end
