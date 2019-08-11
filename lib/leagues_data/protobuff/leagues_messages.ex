defmodule LeaguesData.LeaguesMessages do
  @moduledoc """
  Messages format specification in Protocol Buffers syntax.
  """

  use Protobuf, """
      message Match {
       required string date = 1;
       required string homeTeam = 2;
       required string awayTeam = 3;	
       required uint32 fthg = 4;
       required uint32 ftag = 5;
       required string ftr  = 6;
       required uint32 hthg = 7;
       required uint32 htag = 8;
       required string htr  = 9;
      }
      message LeagueSeason {
       required string league = 1;
       required string season = 2;
      }
      message Matches {
       repeated Match matches = 1;
      }
      message LeaguesSeasons {
       repeated LeagueSeason leaguesSeasons = 1;
      }
  """
  @doc """
  Protocol Buffers
  
  ## Examples
  
      iex> msg = LeaguesData.LeaguesMessages.LeagueSeason.new(league: "league name", season: "season name")
      %LeaguesData.LeaguesMessages.LeagueSeason{league: "league name", season: "season name"}
      iex> encode = LeaguesData.LeaguesMessages.LeagueSeason.encode(msg)
      <<10, 11, 108, 101, 97, 103, 117, 101, 32, 110, 97, 109, 101, 18, 11, 115, 101, 97, 115, 111, 110, 32, 110, 97, 109, 101>>
      iex> ^msg = LeaguesData.LeaguesMessages.LeagueSeason.decode(encode)
      %LeaguesData.LeaguesMessages.LeagueSeason{league: "league name", season: "season name"}
      
  """
  
end
