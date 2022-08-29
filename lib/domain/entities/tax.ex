defmodule Domain.Entities.Tax do
  alias Domain.Entities.Operation
  alias Domain.OperationAgent
  alias Domain.Specification.Tax.ChainHandler
  alias Domain.Specification.Tax.{
    IsBuyOperation,
    HasDamageCalculateDamage,
    HasProfitCalculateProfit,
    NoProfitOrLoss
  }

  @required_fields [:tax]
  @enforce_keys @required_fields
  defstruct @required_fields

  @rules [
    IsBuyOperation,
    HasDamageCalculateDamage,
    HasProfitCalculateProfit,
    NoProfitOrLoss
  ]

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
    ChainHandler.execute(@rules, agents_operation)
  end
end
