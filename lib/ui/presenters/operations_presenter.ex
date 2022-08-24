defmodule Ui.Presenters.OperationsPresenter do
  @spec to_json(any) :: binary
  def to_json(operations) do
    Jason.encode!(operations)
  end
end
