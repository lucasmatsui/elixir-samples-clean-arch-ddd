defmodule Domain.Specification.Tax.HasDamageCalculateDamage do
  @behaviour Domain.Specification.Tax.Contracts.SpecificationTax

  alias Domain.Entities.Operation

  def check(agents_operation) do
    case Operation.has_damage(agents_operation) do
      true ->
        Operation.calculate_damage(agents_operation)
        0
      _ -> nil
    end
  end
end
