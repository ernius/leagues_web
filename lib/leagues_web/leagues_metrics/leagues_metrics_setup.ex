defmodule Web.Metrics.Setup do
  @moduledoc """
  Prometheus metrics setup
  """
  
  @doc """
  This method should be called at application's initialization.
  """
  def setup do
    require Prometheus.Registry
    Web.Metrics.PipelineInstrumenter.setup()
    Web.Metrics.CommandInstrumenter.setup()
    if :os.type() == {:unix, :linux} do
      Prometheus.Registry.register_collector(:prometheus_process_collector)
    end
    Web.Metrics.Exporter.setup()
  end
end
