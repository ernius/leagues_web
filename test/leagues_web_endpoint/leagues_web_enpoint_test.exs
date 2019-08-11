defmodule LeaguesWebTest.WebEndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts LeaguesWeb.LeaguesWebEndpoint.init([])

  test "it returns pong" do
    # Create a test connection
    conn = conn(:get, "/ping")

    # Invoke the plug
    conn = LeaguesWeb.LeaguesWebEndpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    resp = "pong in "
    assert String.slice(conn.resp_body,0,String.length(resp)) == resp
  end

  test "it returns 200 and all leagues and seasons pairs (assuming order is not relevant)" do
    conn = conn(:get, "/leagues?format=json")
    conn = LeaguesWeb.LeaguesWebEndpoint.call(conn, @opts)
    assert conn.state == :sent    
    assert conn.status == 200
    assert Enum.sort(Poison.decode!(conn.resp_body)) ==
           Enum.sort(Poison.decode!("""
	      [{"season":"201617","league":"D1"},
	      {"season":"201617","league":"E0"},
	      {"season":"201516","league":"SP1"},
	      {"season":"201617","league":"SP1"},
	      {"season":"201516","league":"SP2"},
	      {"season":"201617","league":"SP2"}]
	      """))
  end
  
  test "it returns 200 and all leagues and seasons pairs as a buffer (assuming matches order is not relevant)" do
    conn = conn(:get, "/leagues?format=protobuff")
    conn = LeaguesWeb.LeaguesWebEndpoint.call(conn, @opts)
    assert conn.state == :sent    
    assert conn.status == 200
    assert Enum.sort(LeaguesData.LeaguesMessages.LeaguesSeasons.decode(conn.resp_body).leaguesSeasons) ==
           Enum.sort([
	       %LeaguesData.LeaguesMessages.LeagueSeason{league: "D1", season: "201617"},
	       %LeaguesData.LeaguesMessages.LeagueSeason{league: "E0", season: "201617"},
	       %LeaguesData.LeaguesMessages.LeagueSeason{league: "SP1", season: "201516"},
	       %LeaguesData.LeaguesMessages.LeagueSeason{league: "SP1", season: "201617"},
	       %LeaguesData.LeaguesMessages.LeagueSeason{league: "SP2", season: "201516"},
	       %LeaguesData.LeaguesMessages.LeagueSeason{league: "SP2", season: "201617"}
	      ])
  end

  test "it returns 200 and some random match form league SP1 and season 201617 from CSV file is correclty listed in JSON format" do
    conn = conn(:get, "/leagues/SP1/201617?format=json")
    conn = LeaguesWeb.LeaguesWebEndpoint.call(conn, @opts)
    assert conn.state == :sent    
    assert conn.status == 200
    assert Enum.any?(Poison.decode!(conn.resp_body),
      fn m -> 
	m == %{ "date"	=> "21/08/2016",
		"homeTeam" => "Sociedad" ,
		"awayTeam" => "Real Madrid",
		"FTHG"	=> "0",
		"FTAG"	=> "3",
		"FTR"	=> "A",
		"HTHG"	=> "0",
		"HTAG"	=> "2",
		"HTR"	=> "A" }
      end)
  end

  test "it returns 200 and some random match form league SP1 and season 201617 from CSV file is correclty listed in Protocol Buffers format" do
    conn = conn(:get, "/leagues/SP1/201617?format=protobuff")
    conn = LeaguesWeb.LeaguesWebEndpoint.call(conn, @opts)
    assert conn.state == :sent    
    assert conn.status == 200
    assert Enum.any?(LeaguesData.LeaguesMessages.Matches.decode(conn.resp_body).matches,
      fn m -> 
	m == LeaguesData.LeaguesMessages.Match.new(date: "21/08/2016",
	               homeTeam: "Sociedad",
		       awayTeam: "Real Madrid",
		       fthg: 0,
		       ftag: 3,
		       ftr: "A",
		       hthg: 0,
		       htag: 2,
		       htr: "A")
      end)
  end

  test "it returns 400 when format is incorrect" do
    conn = conn(:get, "/leagues?format=wrongformat")
    conn = LeaguesWeb.LeaguesWebEndpoint.call(conn, @opts)
    assert conn.status == 400
  end
  
  test "it returns 400 when format is missing" do
    conn = conn(:get, "/leagues/SP1/201617")
    conn = LeaguesWeb.LeaguesWebEndpoint.call(conn, @opts)
    assert conn.status == 400
  end

  test "it returns 400 when the season is missing" do
    conn = conn(:get, "/leagues/SP1")
    conn = LeaguesWeb.LeaguesWebEndpoint.call(conn, @opts)
    assert conn.status == 400
  end
  
  test "it returns 404 when no route matches" do
    conn = conn(:get, "/fail")
    conn = LeaguesWeb.LeaguesWebEndpoint.call(conn, @opts)
    assert conn.status == 404
  end
end
