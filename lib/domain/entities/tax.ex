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
    maybe_buy_operation(all_state_agents, operation)

    cond do
      operation.type == "buy" -> @zero_tax
      Operation.has_damage(all_state_agents.average_purchage, operation.unit_cost) ->
        calculate_damage(all_state_agents, operation)
      Operation.has_profit(all_state_agents.average_purchage, operation.unit_cost) ->
        calculte_profit(all_state_agents, operation)
      true -> @zero_tax
    end
  end

  defp calculate_damage(all_state_agents, operation) do
    calculate_damage = Operation.calculate_damage(all_state_agents.average_purchage, operation)
    Operation.change_damage(all_state_agents.damage, calculate_damage, [increment: true])
    @zero_tax
  end

  defp calculte_profit(all_state_agents, operation) do
    cond do
      Operation.total_operation(operation) >= 20_000 ->
        damages_minus_profit = Operation.damages_minus_profit(all_state_agents, operation)
        maybe_pay_tax(all_state_agents.damage, damages_minus_profit)
      true -> @zero_tax
    end
  end

  defp maybe_buy_operation(all_state_agents, operation) when operation.type == "buy" do
    Operation.calculate_weighted_average_purchase_price(
      all_state_agents,
      operation
    )
  end

  defp maybe_buy_operation(_, _), do: nil

  defp maybe_pay_tax(_damage, damages_minus_profit) when damages_minus_profit > 0 do
    damages_minus_profit * @twenty_percent_profit_tax
  end

  defp maybe_pay_tax(damage, damages_minus_profit) do
    Operation.change_damage(damage, damages_minus_profit)
    @zero_tax
  end
end
