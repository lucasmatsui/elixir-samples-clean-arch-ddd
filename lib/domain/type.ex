defmodule Domain.Type do
  defstruct [:type]

  @type t :: String.t()

  @spec validate(String.t()) :: t | Exception.t()
  def validate(type) when type in ["buy", "sell"], do: type
  def validate(_type), do: raise "Operation type not supported"
end
