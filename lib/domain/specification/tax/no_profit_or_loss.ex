defmodule Domain.Specification.Tax.NoProfitOrLoss do
  @behaviour Domain.Specification.Tax.Contracts.SpecificationTax

  def check(_agents_operation) do
    0
  end
end
