defmodule LeaguesData.LeaguesProtoBufferETS do
  @behaviour LeaguesData.LeaguesDataBehavior  
  @moduledoc """
  This module loads Leagues CSV in the ETS at initialization time in a Protocol Buffer format, and publishes the data.
  """

  import LeaguesData.LeaguesProtoBufferUtils

  @impl LeaguesData.LeaguesDataBehavior  
  def child_spec([path]) do
    :ets.new(:leagues_protobuff, [:named_table, :set, :protected, read_concurrency: true])

    list = LeaguesData.LeaguesCSV.read_file_mem!(path)
    leagues_seasons = process_leagues_buffer(list)

    :ets.insert(:leagues_protobuff, {:leaguesSeasons, leagues_seasons})
    
    list |> Enum.map(fn ({k, l}) -> :ets.insert(:leagues_protobuff, {k, process_matches_buffer(l)}) end)

    # return :ok as it is not a GenServer agent
    :ok
  end
  
  @impl LeaguesData.LeaguesDataBehavior
  def leagues() do
    [{:leaguesSeasons, leagues}] = :ets.lookup(:leagues_protobuff, :leaguesSeasons)
    leagues
  end
  
  @impl LeaguesData.LeaguesDataBehavior  
  def matches(league, season) do
    [{{^league, ^season}, matches}] = :ets.lookup(:leagues_protobuff, {league, season})
    matches
  end

end

  
