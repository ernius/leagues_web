defmodule LeaguesDataTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest LeaguesData.LeaguesData
  doctest LeaguesData.LeaguesCSV
  doctest LeaguesData.LeaguesMessages
  
  property "check no random pair of league-season is loaded" do
    check all league <- string(:ascii),
              season <- string(?0..?9),
              not Enum.member?([{"SP1", "201617"}, {"SP1", "201516"}, {"SP2", "201617"}, {"SP2", "201516"}], {league, season}) do
      assert not List.keymember?(LeaguesData.LeaguesCSV.read_file_mem!("test/leagues_data/test_data.csv"), {league, season}, 0)
    end    
  end
  
end
