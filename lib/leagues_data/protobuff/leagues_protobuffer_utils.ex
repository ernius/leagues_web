defmodule LeaguesData.LeaguesProtoBufferUtils do
  @moduledoc """
  This module contains utility functions for leagues data conversion.
  """
  
  def process_leagues_buffer(l) do
    l
    |> Enum.map(fn ({{l,s},_}) -> LeaguesData.LeaguesMessages.LeagueSeason.new(league: l, season: s) end)
    |> (&(LeaguesData.LeaguesMessages.LeaguesSeasons.new(leaguesSeasons: &1))).()
    |> LeaguesData.LeaguesMessages.LeaguesSeasons.encode
  end

  def process_matches_buffer(l) do
    l
    |> Enum.map(&matchTupleToProtoBuffer(&1))
    |> (&(LeaguesData.LeaguesMessages.Matches.new(matches: &1))).()
    |> LeaguesData.LeaguesMessages.Matches.encode
  end

  def matchTupleToProtoBuffer({d, ht, at, fthg, ftag, ftr, hthg, htag, htr}) do
    LeaguesData.LeaguesMessages.Match.new(
      date: d,
      homeTeam: ht,
      awayTeam: at,
      fthg: String.to_integer(fthg),
      ftag: String.to_integer(ftag),
      ftr: ftr,
      hthg: String.to_integer(hthg),
      htag: String.to_integer(htag),
      htr: htr)   
   end
end
