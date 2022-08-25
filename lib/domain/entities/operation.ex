defmodule Domain.Entities.Operation do
  alias Domain.Type

  @required_fields [:type, :unit_cost, :quantity]
  @enforce_keys @required_fields
  defstruct @required_fields
  @type t :: %__MODULE__{
    type: Type.t(),
    unit_cost: float(),
    quantity: integer()
  }

  @spec new(Type.t(), float(), integer()) :: t
  def new(type, unit_cost, quantity) do
    %__MODULE__{
      type: type,
      unit_cost: unit_cost,
      quantity: quantity
    }
  end

  @spec weighted_average_purchase_price([t]) :: number()
  def weighted_average_purchase_price(operations) do
    result = mult_shares_unit_cost_and_sum(operations) / all_buy_shares(operations)

    result
    |> Decimal.from_float()
    |> Decimal.round(2, :ceiling)
    |> Decimal.to_float()
  end

  defp mult_shares_unit_cost_and_sum(operations) do
    Enum.reduce(operations, 0, &mult_only_buy_shares(&1, &2))
  end

  defp mult_only_buy_shares(operation, acc) when operation.type == "buy" do
    (operation.quantity * operation.unit_cost) + acc
  end
  defp mult_only_buy_shares(_operation, acc), do: acc

  defp all_buy_shares(operations) do
    Enum.reduce(operations, 0, &sum_only_buy_shares(&1, &2))
  end

  defp sum_only_buy_shares(operation, acc) when operation.type == "buy" do
    operation.quantity + acc
  end
  defp sum_only_buy_shares(_operation, acc), do: acc
end
