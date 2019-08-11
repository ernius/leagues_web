defmodule LeaguesWeb.LeaguesWebEndpoint do
  @moduledoc """
  A Plug Router responsible for routing HTTP requests.
  """
  use Plug.Router

  @data_services Application.get_env(:leagues_web, :data_modules)
  
  if Mix.env == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  # Using Plug.Logger for logging request information
  plug(Plug.Logger)

  # Prometheus Metrics 
  plug Web.Metrics.Exporter
  plug Web.Metrics.PipelineInstrumenter
  
  # responsible for matching routes
  plug :match

  # responsible for dispatching responses
  plug :dispatch

  #A simple route to test that the server is up, and in which hostname to see balance is working
  get "/ping" do
    {:ok, hostname} = :inet.gethostname
    send_resp(conn, 200, "pong in " <> to_string(hostname))
  end

  # Returns a JSON string or Protocol Buffers binary with a list of all leagues-season pairs.

  ## Required query parameters
  #   - format: "json" | "protobuff"

  ## Example url: /leagues?format=json
  get "/leagues" do
    # count /leagues hit with my own counter :)
    {:ok, hostname} = :inet.gethostname
    Web.Metrics.CommandInstrumenter.inc_command(hostname)
     
    conn = fetch_query_params(conn) # populates conn.params
    case conn.params do
      %{"format" => format} ->
	downcase_format = String.downcase(format)
	if Map.has_key?(@data_services, downcase_format) do
	  send_resp(conn, 200, LeaguesData.LeaguesData.leagues(downcase_format))
	else
	  send_resp(conn, 400, "not supported format type") 
	end
      _                     -> send_resp(conn, 400, "missing format") # format is mandatory
    end
  end


  # Returns a JSON string or Protocol Buffers binary with all matches for the given pair of `league` and `season`

  ## Required query parameters
  #   - format: "json" | "protobuff"

  ## Example url: /leagues/league-id/season-id?format=json
  get "/leagues/:league/:season" do
    conn = fetch_query_params(conn)
    case conn.params do
      %{"format" => format} ->
	downcase_format = String.downcase(format)
	if Map.has_key?(@data_services, downcase_format) do
	  send_resp(conn, 200, LeaguesData.LeaguesData.matches(String.downcase(format), String.upcase(league), season))
	else
	  send_resp(conn, 400, "not supported format type") 
	end
      _                     -> send_resp(conn, 400, "missing format") # format is mandatory      
    end
  end

  get "/leagues/:league" do
    send_resp(conn, 400, "missing season") 
  end

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    send_resp(conn, 404, "Nothing here")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end  
end
