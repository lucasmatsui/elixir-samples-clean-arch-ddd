defmodule Domain.Entities.Tax do
  alias Domain.Entities.Operation

  @required_fields [:tax]
  @enforce_keys @required_fields
  defstruct @required_fields

  @twenty_percent_profit_tax 0.2
  @zero_tax 0

  @type t :: %__MODULE__{
    tax: number(),
  }

  @spec calculate_taxs([Operation.t()]) :: list()
  def calculate_taxs(operations) do
    all_state_agents = Operation.start_all_agents_links()

    Enum.map(operations, &calculate_tax(&1, all_state_agents))
  end

  defp calculate_tax(operation, all_state_agents) do
    agents_operation = %{
      agents: all_state_agents,
      operation: operation
    }

    maybe_buy_operation(agents_operation)

    cond do
      operation.type == "buy" -> @zero_tax
      Operation.has_damage(all_state_agents.average_purchage, operation.unit_cost) ->
        calculate_damage(all_state_agents, operation)
      Operation.has_profit(agents_operation) ->
        calculate_profit(agents_operation)
      true -> @zero_tax
    end
  end

  defp calculate_damage(all_state_agents, operation) do
    calculate_damage = Operation.calculate_damage(all_state_agents.average_purchage, operation)
    Operation.update_damage(all_state_agents.damage, calculate_damage, [increment: true])
    @zero_tax
  end

  defp calculate_profit(agents_operation) do
    damages_minus_profit = Operation.profit_after_damages(agents_operation)

    cond do
      Operation.total_operation(agents_operation.operation) < 20_000 -> @zero_tax
      damages_minus_profit > 0 -> damages_minus_profit * @twenty_percent_profit_tax
      true ->
        Operation.update_damage(agents_operation.agents.damage, damages_minus_profit)
        @zero_tax
    end
  end

  defp maybe_buy_operation(agents_operation) when agents_operation.operation.type == "buy" do
    Operation.calculate_weighted_average_purchase_price(agents_operation)
  end

  defp maybe_buy_operation(_), do: nil
end
