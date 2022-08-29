defmodule Domain.Specification.Tax.HasProfitCalculateProfit do
  @behaviour Domain.Specification.Tax.Contracts.SpecificationTax

  alias Domain.Entities.Operation

  @zero_tax 0
  @twenty_percent_profit_tax 0.2

  def check(agents_operation) do
    case Operation.has_profit(agents_operation) do
      true -> calculate_profit(agents_operation)
      _ -> nil
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
