defmodule LeaguesData.LeaguesJSONETS do
  @behaviour LeaguesData.LeaguesDataBehavior
  @moduledoc """
  This module loads Leagues CSV file in the ETS at initialization time in JSON format, and has methods to retrieve this data from ETS.
  """

  import LeaguesData.LeaguesJSONETSUtils
  
  @impl LeaguesData.LeaguesDataBehavior  
  def child_spec([path]) do
    :ets.new(:leagues_json, [:named_table, :set, :protected, read_concurrency: true])

    list = LeaguesData.LeaguesCSV.read_file_mem!(path)
    leagues_seasons = process_leagues_json(list)

    :ets.insert(:leagues_json, {:leaguesSeasons, leagues_seasons})
    
    list |> Enum.map(fn ({k, l}) -> :ets.insert(:leagues_json, {k, process_matches_json(l)}) end)

    # return :ok as it is not a GenServer agent
    :ok
  end
  
  @impl LeaguesData.LeaguesDataBehavior
  def leagues() do
    [{:leaguesSeasons, leagues}] = :ets.lookup(:leagues_json, :leaguesSeasons)
    leagues
  end
  
  @impl LeaguesData.LeaguesDataBehavior  
  def matches(league, season) do
    [{{^league, ^season}, matches}] = :ets.lookup(:leagues_json, {league, season})
    matches
  end

end

  
