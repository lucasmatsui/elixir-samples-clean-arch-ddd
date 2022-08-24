defmodule Ui.CLI.Client do
  alias Application.UseCases.CalculateTaxPerOperation
  alias Application.Dto.CalculateTaxPerOperationInput
  alias Ui.Presenters.OperationsPresenter

  def main(_) do
    lists_operations_dto()
    |> CalculateTaxPerOperation.execute()
    |> build_response()
  rescue
    err ->
      IO.puts("\n")

      %{error: err.message}
      |> Jason.encode!()
      |> IO.puts()
  end

  defp build_response(output) do
    IO.puts("\n")
    Enum.map(output, &build_operations_output/1)
  end

  defp build_operations_output(list) do
    list
    |> Enum.map(& %{tax: &1.tax})
    |> OperationsPresenter.to_json()
    |> IO.puts()
  end

  defp lists_operations_dto() do
    Enum.map(read_lines(), &list_to_dto/1)
  end

  defp list_to_dto(list) do
    Enum.map(Jason.decode!(list), fn operation ->
      CalculateTaxPerOperationInput.new(
        operation["operation"],
        operation["unit-cost"],
        operation["quantity"]
      )
    end)
  end

  defp read_lines, do: String.split(IO.read(:stdio, :eof), ~r{[\r\n]+}, trim: true)
end
