defmodule Domain.OperationAgent do
  alias Domain.Entities.Operation

  @required_fields [:agents, :operation]
  @enforce_keys @required_fields
  defstruct @required_fields

  @type agents :: %{
    average_purchage: pid(),
    damage: pid(),
    list_shares_purchased: pid()
  }

  @type t :: %__MODULE__{
    agents: agents(),
    operation: Operation.t(),
  }

  @spec new(Operation.t(), agents()) :: t
  def new(operation, all_states_agents) do
    %__MODULE__{
      agents: all_states_agents,
      operation: operation,
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

  def get_state(agent) do
    Agent.get(agent, fn any -> any end)
  end

  def update_damage_increment(agent, damage) do
    Agent.update(agent, fn number -> (damage + number) end)
  end

  def update_damage(agent, damage) do
    Agent.update(agent, fn _number -> damage end)
  end

  @spec update_list_shares_purchased(t) :: :ok
  def update_list_shares_purchased(agents_operation) do
    Agent.update(agents_operation.agents.list_shares_purchased, fn list -> [agents_operation.operation | list] end)
  end

  def update_average_purchage(agent, average_purchage) do
    Agent.update(agent, fn _number -> average_purchage end)
  end
end
