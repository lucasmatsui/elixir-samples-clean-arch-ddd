defmodule Domain.Type do
  defstruct [:type]

  @type t :: %__MODULE__{
    type: String.t()
  }

  @spec new(String.t()) :: t | Exception.t()
  def new(type) when type == "buy" do
    %__MODULE__{
      type: type
    }
  end

  def new(type) when type == "sell" do
    %__MODULE__{
      type: type
    }
  end

  def new(_type) do
    raise "Operation type not supported"
  end

end
