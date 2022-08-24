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
    weighted_average_price =
      list
      |> list_operation_entities()
      |> Operation.weighted_average_price()

    Enum.map(list, fn operation ->
      Operation.new(
        Type.validate(operation.operation),
        operation.unit_cost,
        operation.quantity
      )
      |> Operation.calculate_tax(weighted_average_price)
    end)

    CalculateTaxPerOperationOutput.new(1)
  end

  @spec list_operation_entities([CalculateTaxPerOperationInput.t()]) :: [Operation.t()]
  defp list_operation_entities(operations) do
    Enum.map(operations, fn operation ->
      Operation.new(
        Type.validate(operation.operation),
        operation.unit_cost,
        operation.quantity
      )
    end)
  end
end
