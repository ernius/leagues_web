defmodule LeaguesData.LeaguesData do
  @moduledoc """
  Routes data requests to data provider agents depending on the requested output format 

  Data services with different output formats can be easily added, only requiring the module implements the behaviour LeaguesData.LeaguesDataBehavior and added to the `data_modules:` map in the file config.exs.
  """

  @data_services Application.get_env(:leagues_web, :data_modules)

  @doc """
  Returns a JSON string with a list of all leagues-season pairs.

  ## Parameters
    - format: could be `"json"` or `"protobuff"`, but easily extensible adding more agents and registering them in `data_modules:` map.

  ## Example

      iex> LeaguesData.LeaguesData.leagues("json")
      ~s([{"season":"201617","league":"D1"},{"season":"201617","league":"E0"},{"season":"201516","league":"SP2"},{"season":"201617","league":"SP2"},{"season":"201516","league":"SP1"},{"season":"201617","league":"SP1"}])
  
  """
  @spec leagues(format :: String.t) :: leagues_season :: any()
  def leagues(format), do: @data_services[format].leagues()

  @doc """
  Returns a JSON string with all the results for a given pair of `league` and `season`.

  ## Parameters
    - format: could be `"json"` or `"protobuff"` string, but easily extensible adding more agents and registering them in `@data_services`
    - league: string
    - season: string

  ## Example

      iex> res = LeaguesData.LeaguesData.matches("json", "SP1", "201617")
      iex> String.slice(res,0,129)
      ~s([{"homeTeam":"La Coruna","date":"19/08/2016","awayTeam":"Eibar","HTR":"D","HTHG":"0","HTAG":"0","FTR":"H","FTHG":"2","FTAG":"1"},)

  """
  @spec matches(format :: String.t, league :: String.t, season :: String.t) :: matches :: any()
  def matches(format, league, season), do: @data_services[format].matches(league, season)
  
end
