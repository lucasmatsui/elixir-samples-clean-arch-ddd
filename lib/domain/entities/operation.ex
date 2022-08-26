defmodule Domain.Entities.Operation do
  alias Domain.Type

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

  def start_all_agents_links() do
    {:ok, damage} = Agent.start_link(fn -> 0 end)
    {:ok, average_purchage} = Agent.start_link(fn -> 0 end)
    {:ok, list_shares_purchased} = Agent.start_link(fn -> [] end)

    %{
      damage: damage,
      average_purchage: average_purchage,
      list_shares_purchased: list_shares_purchased
    }
  end

  def total_operation(operation) do
    operation.unit_cost * operation.quantity
  end

  def damages_minus_profit(all_state_agents, operation) do
   damages_to_pay(all_state_agents.damage) + calculate_profit(all_state_agents.average_purchage, operation)
  end

  def damages_to_pay(agent) do
    get_state(agent)
  end

  def has_damage(agent, unit_cost) do
    unit_cost < get_state(agent)
  end

  def has_profit(agent, unit_cost) do
    unit_cost > get_state(agent)
  end

  def calculate_damage(agent, operation) do
    (operation.unit_cost - get_state(agent)) * operation.quantity
  end

  def calculate_profit(agent, operation) do
    ((operation.unit_cost - get_state(agent)) * operation.quantity)
  end

  def change_damage(agent, damage, opts \\ [increment: false]) do
    cond do
      opts[:increment] == true ->
        Agent.update(agent, fn number -> (damage + number) end)
      true ->
        Agent.update(agent, fn _number -> damage end)
    end
  end
  def calculate_weighted_average_purchase_price(all_state_agents, operation) do
    Agent.update(all_state_agents.list_shares_purchased, fn list -> [operation | list] end)
    operations_list = Agent.get(all_state_agents.list_shares_purchased, fn list -> list end)
    Agent.update(all_state_agents.average_purchage, fn _number ->
      result = mult_shares_unit_cost_and_sum(operations_list) / all_buy_shares(operations_list)

      result
      |> Decimal.from_float()
      |> Decimal.round(2, :ceiling)
      |> Decimal.to_float()
    end)
  end

  def get_state(agent) do
    Agent.get(agent, fn number -> number end)
  end

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
