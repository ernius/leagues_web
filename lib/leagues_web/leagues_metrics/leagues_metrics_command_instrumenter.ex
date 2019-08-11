defmodule Web.Metrics.CommandInstrumenter do
  @moduledoc """
  This module implements a Prometheus' simple metric counter.
  """
  
  use Prometheus.Metric

  def setup() do
    Counter.declare(
      name: :leagues_command_total,
      help: "Leagues Command Count",
      labels: [:command]
    )
  end

  @doc """
  Increments the counter and records the hostname.
  """
  @spec inc_command(host :: String.t) :: [byte()]
  def inc_command(host) do
    Counter.inc(
      name: :leagues_command_total,
      labels: [host]
    )
  end  
end
