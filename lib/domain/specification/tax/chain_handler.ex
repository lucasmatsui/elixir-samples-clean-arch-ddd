defmodule Domain.Specification.Tax.ChainHandler do
  alias Domain.OperationAgent

  @spec execute(list(), OperationAgent.t()) :: any
  def execute(rules, agents_operation) do
    Enum.reduce_while(rules, 0, fn rule, acc ->
      result = rule.check(agents_operation)

      if is_nil(result), do: {:cont, acc}, else: {:halt, result}
    end)
  end
end
