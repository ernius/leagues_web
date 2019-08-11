defmodule LeaguesData.LeaguesJSONETSUtils do
  
  def process_leagues_json(l) do
    l
    |> Enum.map(fn ({{l,s},_}) -> %{ "season" => s, "league" => l} end)    
    |> Poison.encode!
  end

  def process_matches_json(matches) do
    matches
    |> Enum.map(&match_tuple2map(&1))
    |> Poison.encode!
  end
  
  def match_tuple2map({d, ht, at, fthg, ftag, ftr, hthg, htag, htr}) do
    %{ "date"	=> d,
       "homeTeam" => ht ,
       "awayTeam" => at,
       "FTHG"	=> fthg,
       "FTAG"	=> ftag,
       "FTR"	=> ftr,
       "HTHG"	=> hthg,
       "HTAG"	=> htag,
       "HTR"	=> htr }
  end
  
end
