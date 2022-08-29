defmodule Domain.Specification.Tax.IsBuyOperation do
  @behaviour Domain.Specification.Tax.Contracts.SpecificationTax

  def check(agents_operation) when agents_operation.operation.type == "buy" do
    0
  end

  def check(_) do
    nil
  end
end
