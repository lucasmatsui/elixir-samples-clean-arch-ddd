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

  @type agents :: %{
    average_purchage: pid(),
    damage: pid(),
    list_shares_purchased: pid()
  }

  @spec new(Type.t(), float(), integer()) :: t
  def new(type, unit_cost, quantity) do
    %__MODULE__{
      type: type,
      unit_cost: unit_cost,
      quantity: quantity
    }
  end

  @spec start_all_agents_links :: agents
  def start_all_agents_links do
    {:ok, damage} = Agent.start_link(fn -> 0 end)
    {:ok, average_purchage} = Agent.start_link(fn -> 0 end)
    {:ok, list_shares_purchased} = Agent.start_link(fn -> [] end)

    %{
      damage: damage,
      average_purchage: average_purchage,
      list_shares_purchased: list_shares_purchased
    }
  end

  @spec total_operation(t) :: number()
  def total_operation(%__MODULE__{} = operation) do
    operation.unit_cost * operation.quantity
  end

  @spec profit_after_damages(map()) :: number()
  def profit_after_damages(agents_operation) do
    damage = agents_operation.agents.damage
    average_purchage = agents_operation.agents.average_purchage

    damages_to_pay(damage) + calculate_profit(average_purchage, agents_operation.operation)
  end

  defp damages_to_pay(agent) do
    get_state(agent)
  end

  @spec has_damage(pid(), float()) :: boolean
  def has_damage(agent, unit_cost) do
    unit_cost < get_state(agent)
  end

  def has_profit(agents_operation) do
    agents_operation.operation.unit_cost > get_state(agents_operation.agents.average_purchage)
  end

  def calculate_damage(agent, operation) do
    (operation.unit_cost - get_state(agent)) * operation.quantity
  end

  defp calculate_profit(agent, operation) do
    ((operation.unit_cost - get_state(agent)) * operation.quantity)
  end

  def update_damage(agent, damage, opts \\ [increment: false]) do
    cond do
      opts[:increment] == true ->
        Agent.update(agent, fn number -> (damage + number) end)
      true ->
        Agent.update(agent, fn _number -> damage end)
    end
  end

  def calculate_weighted_average_purchase_price(agents_operation) do
    list_shares_purchased = agents_operation.agents.list_shares_purchased
    average_purchage = agents_operation.agents.average_purchage

    Agent.update(list_shares_purchased, fn list -> [agents_operation.operation | list] end)
    operations_list = Agent.get(list_shares_purchased, fn list -> list end)
    Agent.update(average_purchage, fn _number ->
      result = mult_shares_unit_cost_and_sum(operations_list) / all_buy_shares(operations_list)

      result
      |> Decimal.from_float()
      |> Decimal.round(2, :ceiling)
      |> Decimal.to_float()
    end)
  end

  defp get_state(agent) do
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
