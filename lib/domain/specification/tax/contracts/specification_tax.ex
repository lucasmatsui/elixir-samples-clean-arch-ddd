defmodule Domain.Specification.Tax.Contracts.SpecificationTax do
  @callback check(any()) :: number() | nil
end
