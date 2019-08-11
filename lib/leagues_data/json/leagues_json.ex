defmodule LeaguesData.LeaguesJSON do
  @behaviour LeaguesData.LeaguesDataBehavior
  use GenServer
  @moduledoc """
  This `GenServer` agent loads Leagues CSV file in memory at initialization time in JSON format, and publishes the data.
  """
  
  import LeaguesData.LeaguesJSONETSUtils
  
  @impl LeaguesData.LeaguesDataBehavior
  def leagues(), do: GenServer.call(LeaguesData.LeaguesJSON, :leagues)
  
  @impl LeaguesData.LeaguesDataBehavior  
  def matches(league, season), do: GenServer.call(LeaguesData.LeaguesJSON, {:matches, league, season})
  
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  #*** Callbacks ***
  @doc "Init Service given the path of the CSV to load it in memory"
  @impl true
  def init(path) do
    list = LeaguesData.LeaguesCSV.read_file_mem!(path)
    leagues_seasons = process_leagues_json(list)
    matches_map =
      list
      |> Enum.map(fn ({k, l}) -> {k, process_matches_json(l)} end)
      |> Map.new  
    
    {:ok, {leagues_seasons, matches_map}}
  end

  @doc """
  Synchronous. Returns leagues and season pairs as a JSON string

    ## Example

      iex> GenServer.call(LeaguesData.LeaguesJSON, :leagues)
      ~s([{"season":"201617","league":"D1"},{"season":"201617","league":"E0"},{"season":"201516","league":"SP2"},{"season":"201617","league":"SP2"},{"season":"201516","league":"SP1"},{"season":"201617","league":"SP1"}])

  """
  @impl true
  def handle_call(:leagues, _from, t = {leagues_seasons, _}) do
    {:reply, leagues_seasons, t}
  end

  # "Synchronous. Given a league and season returns its lists of matches as a JSON string. Returns empty list if league or season do not exist"
  @impl true
  def handle_call({:matches, league, season}, _from, t = {_, matches_map}) do
    {:reply , Map.get(matches_map, {league, season}, []), t}
  end

end

  
