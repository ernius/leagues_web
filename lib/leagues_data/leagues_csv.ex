defmodule LeaguesData.LeaguesCSV do
  @moduledoc """
  This Service loads Leagues CSV file.
  """
  
  @doc """
  Reads a CSV file at a given *path*, and loads it into an association list in memory. 
  Each pair in the list is composed by another pair of {League, Season}, and its matches list.

  ## Parameters
  
  - path: the CSV file path to be loaded
  
  ## Examples

      iex> res = LeaguesData.LeaguesCSV.read_file_mem!("test/leagues_data/test_data.csv")
      iex> hd(res)
      {{"SP2", "201516"}, [{"22/08/2015", "Alcorcon", "Mallorca", "2", "0", "H", "1", "0", "H"}, {"22/08/2015", "Cordoba", "Valladolid", "1", "0", "H", "0", "0", "D"}]}
      iex> List.keyfind(res,{"SP1", "201516"}, 0)
      {{"SP1", "201516"}, [{"21/08/2015", "Malaga", "Sevilla", "0", "0", "D", "0", "0", "D"}]}	
  
  """
  @type match :: { date :: String.t, team1 :: String.t, team2 :: String.t, String.t, String.t, String.t, String.t, String.t }
  
  @spec read_file_mem!(path :: String.t) :: [{{league :: String.t, season :: String.t}, [match]}]
  def read_file_mem!(path) do
    path
    |> File.stream!
    |> Stream.drop(1) # drop csv header
    |> Stream.map(&String.replace(&1, "\n", ""))    
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&List.to_tuple(&1))
    |> Stream.chunk_by(&elem(&1,1)) # aggregates by league (assuming data of each league is stored consecutive)
    |> Stream.map(fn l -> Enum.chunk_by(l,&elem(&1,2)) end)  # within each league aggregates by season (assuming seasons are stored consecutive)
    |> Enum.reduce([], &read_league/2) # lazy up to here, now all CSV content is loaded in a list in memory
  end

  defp read_league(l, acc) do
    liga = elem(hd(hd(l)),1)
    Enum.reduce(l, acc, 
      fn (s, acc2) ->  # each Season
	season = elem(hd(s),2)			   
	[ { {liga , season},
	    Enum.map(s,fn ({_,_,_,date,ht,at,a,b,c,d,e,f}) -> {date,ht,at,a,b,c,d,e,f} end)} # remove counter, league and season
	  | acc2 ]
      end)
  end
  
end
