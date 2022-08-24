defmodule Application.UseCases.CalculateTaxPerOperation do
  alias Application.Dto.{
    CalculateTaxPerOperationInput,
    CalculateTaxPerOperationOutput
  }
  alias Domain.Entities.Operation
  alias Domain.Type
  alias Decimal

  @spec execute([[CalculateTaxPerOperationInput.t()]]) :: [[CalculateTaxPerOperationOutput.t()]]
  def execute(lists) do
    Enum.map(lists, &calculate_tax_per_operation/1)
  end

  defp calculate_tax_per_operation(list) do
    list
    |> Enum.map(fn operation ->
      Operation.new(
        Type.new(operation.operation),
        operation.unit_cost,
        operation.quantity
      )
    end)
    |> Operation.weighted_average_price()


    CalculateTaxPerOperationOutput.new(1)
  end
end
