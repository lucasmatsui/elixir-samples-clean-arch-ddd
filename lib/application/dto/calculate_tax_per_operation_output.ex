defmodule Application.Dto.CalculateTaxPerOperationOutput do
  @derive {Jason.Encoder, only: [:tax]}

  @required_fields [:tax]
  @enforce_keys @required_fields
  defstruct @required_fields

  @type t :: %__MODULE__{
    tax: number(),
  }

  @spec new(number()) :: t
  def new(tax) do
    %__MODULE__{
      tax: tax
    }
  end
end
