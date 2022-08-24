defmodule Application.Dto.CalculateTaxPerOperationInput do
  @required_fields [:operation, :unit_cost, :quantity]
  @enforce_keys @required_fields
  defstruct @required_fields

  @type t :: %__MODULE__{
    operation: String.t(),
    unit_cost: number(),
    quantity: Integer.t()
  }

  @spec new(String.t(), number(), Integer.t()) :: t
  def new(operation, unit_cost, quantity) do
    %__MODULE__{
      operation: operation,
      unit_cost: unit_cost,
      quantity: quantity
    }
  end
end
