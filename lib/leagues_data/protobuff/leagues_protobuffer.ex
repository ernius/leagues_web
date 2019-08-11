defmodule LeaguesData.LeaguesProtoBuffer do
  @behaviour LeaguesData.LeaguesDataBehavior  
  use GenServer
  @moduledoc """
  This `GenServer` agent service loads a given Leagues CSV file in memory at initialization time in Protocol Buffer format, and publishes the data.
  """

  import LeaguesData.LeaguesProtoBufferUtils
  
  @impl LeaguesData.LeaguesDataBehavior
  def leagues(), do: GenServer.call(LeaguesData.LeaguesProtoBuffer, :leagues)
  
  @impl LeaguesData.LeaguesDataBehavior  
  def matches(league, season), do: GenServer.call(LeaguesData.LeaguesProtoBuffer, {:matches, league, season})
  
  # GenServer behaviour
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  #*** Callbacks ***
  @doc "Init Service given the path of the CSV to load it in memory"
  @impl true
  def init(path) do
    list = LeaguesData.LeaguesCSV.read_file_mem!(path)
    leagues_seasons = process_leagues_buffer(list)
    matches_map =
      list
      |> Enum.map(fn ({k, l}) -> {k, process_matches_buffer(l)} end)
      |> Map.new  

    {:ok, {leagues_seasons, matches_map}}    
  end

  @doc """
  Synchronous. Returns leagues and season pairs in Protocol Buffers format

    ## Example

      iex> GenServer.call(LeaguesData.LeaguesProtoBuffer, :leagues)

  """
  @impl true
  def handle_call(:leagues, _from, t = {leagues_seasons, _}) do
    {:reply, leagues_seasons, t}
  end

  # "Synchronous. Given a league and season pair returns its lists of matches in Protocol Buffers format. Returns empty if league or season do not exist."
  @impl true
  def handle_call({:matches, league, season}, _from, t = {_, matches_map}) do
    {:reply , Map.get(matches_map, {league, season}, []), t}
  end

end

  
