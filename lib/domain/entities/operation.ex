defmodule Domain.Entities.Operation do
  alias Domain.Type

  @required_fields [:type, :unit_cost, :quantity]
  @enforce_keys @required_fields
  defstruct @required_fields

  @type t :: %__MODULE__{
    type: Type.t(),
    unit_cost: number(),
    quantity: Float.t(),
  }

  @spec new(Type.t(), number(), Float.t()) :: t
  def new(type, unit_cost, quantity) do
    %__MODULE__{
      type: type,
      unit_cost: unit_cost,
      quantity: quantity
    }
  end

  @spec weighted_average_price([t]) :: number()
  def weighted_average_price(operations) do
    mult_shares_unit_cost_and_sum(operations) / all_shares(operations)
  end

  @spec mult_shares_unit_cost_and_sum([t]) :: number()
  def mult_shares_unit_cost_and_sum(operations) do
    Enum.reduce(operations, 0, fn operation, acc ->
      (operation.quantity * operation.unit_cost) + acc
    end)
  end

  @spec all_shares([t]) :: number()
  def all_shares(operations) do
    Enum.reduce(operations, 0, fn operation, acc ->
      operation.quantity + acc
    end)
  end
end
