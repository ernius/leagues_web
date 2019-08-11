defmodule LeaguesData.LeaguesDataBehavior do
  @moduledoc """
  `Behavior` of leagues data provider in some format.

  All available data providers should be added in data_modules: map in the file config.exs
  """
  
  @doc """
  Initialization

  ## Parameters
  It receives the path of the CSV file.

  ## Returns
  If it is a GenServer it also should returns it specification to be passed as a child to the Supervisor in application.ex.
  If it is not a GenServer it should return :ok atom.
  """
  @callback child_spec([csv_file_path :: String.t]) :: :ok | child_spec :: any()
  
  @doc """
  Returns a list of all leagues-season pairs.
  """
  @callback leagues() :: any()

  @doc """
  Returns all matches for a given pair of `league` and `season`.

  ## Parameters
  
  league and season
  """
  @callback matches(league :: String.t, season :: String.t) :: any()
end
