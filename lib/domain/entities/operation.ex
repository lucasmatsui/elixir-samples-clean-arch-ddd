defmodule Domain.Entities.Operation do
  alias Domain.Type
  alias Domain.OperationAgent

  @required_fields [:type, :unit_cost, :quantity]
  @enforce_keys @required_fields
  defstruct @required_fields

  @type t :: %__MODULE__{
    type: Type.t(),
    unit_cost: float(),
    quantity: integer()
  }

  @spec new(Type.t(), float(), integer()) :: t
  def new(type, unit_cost, quantity) do
    %__MODULE__{
      type: type,
      unit_cost: unit_cost,
      quantity: quantity
    }
  end

  @spec total_operation(t) :: number()
  def total_operation(%__MODULE__{} = operation) do
    operation.unit_cost * operation.quantity
  end

  @spec calculate_profit_after_damages(map()) :: number()
  def calculate_profit_after_damages(agents_operation) do
    damage = agents_operation.agents.damage
    average_purchage = agents_operation.agents.average_purchage

    damages_to_pay(damage) + calculate_profit(average_purchage, agents_operation.operation)
  end

  defp damages_to_pay(agent) do
    OperationAgent.get_state(agent)
  end

  @spec has_damage(map()) :: boolean
  def has_damage(agents_operation) do
    agents_operation.operation.unit_cost < OperationAgent.get_state(agents_operation.agents.average_purchage)
  end

  def has_profit(agents_operation) do
    agents_operation.operation.unit_cost > OperationAgent.get_state(agents_operation.agents.average_purchage)
  end

  def calculate_damage(agents_operation) do
    average_purchage = agents_operation.agents.average_purchage
    damage = agents_operation.agents.damage

    calculated_damage = (agents_operation.operation.unit_cost - OperationAgent.get_state(average_purchage)) * agents_operation.operation.quantity
    change_damage(damage, calculated_damage, [increment: true])

    calculated_damage
  end

  defp calculate_profit(agent, operation) do
    ((operation.unit_cost - OperationAgent.get_state(agent)) * operation.quantity)
  end

  def change_damage(agent, damage, opts \\ [increment: false]) do
    cond do
      opts[:increment] == true ->
        OperationAgent.update_damage_increment(agent, damage)
      true ->
        OperationAgent.update_damage(agent, damage)
    end
  end

  def calculate_weighted_average_purchase_price(agents_operation) when agents_operation.operation.type == "buy" do
    list_shares_purchased = agents_operation.agents.list_shares_purchased
    average_purchage = agents_operation.agents.average_purchage

    OperationAgent.update_list_shares_purchased(agents_operation)
    operations_list = OperationAgent.get_state(list_shares_purchased)

    result =
      (mult_shares_unit_cost_and_sum(operations_list) / all_buy_shares(operations_list))
      |> Decimal.from_float()
      |> Decimal.round(2, :ceiling)
      |> Decimal.to_float()

    OperationAgent.update_average_purchage(average_purchage, result)
  end

  def calculate_weighted_average_purchase_price(_), do: :ok

  defp mult_shares_unit_cost_and_sum(operations) do
    Enum.reduce(operations, 0, &mult_only_buy_shares(&1, &2))
  end

  defp mult_only_buy_shares(operation, acc) when operation.type == "buy" do
    (operation.quantity * operation.unit_cost) + acc
  end
  defp mult_only_buy_shares(_operation, acc), do: acc

  defp all_buy_shares(operations) do
    Enum.reduce(operations, 0, &sum_only_buy_shares(&1, &2))
  end

  defp sum_only_buy_shares(operation, acc) when operation.type == "buy" do
    operation.quantity + acc
  end
  defp sum_only_buy_shares(_operation, acc), do: acc
end
