defmodule LeaguesWeb.Application do
  @moduledoc "Leagues OTP Application module"
  use Application

  @data_services Application.get_env(:leagues_web, :data_modules)
  
  def start(_type, _args) do
    # Prometheus metrics setup
    Web.Metrics.Setup.setup()
    
    csv_file = Path.join(:code.priv_dir(:leagues_web), Application.get_env(:leagues_web, :leagues_csv_file))
    
    # List all child processes to be supervised
    children = [
      # Use Plug.Cowboy.child_spec/3 to register our endpoint as a plug
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: LeaguesWeb.LeaguesWebEndpoint,
        options: [port: Application.get_env(:leagues_web, :rest_api_port)]
      ),
    ] ++
      # initialize data providers. Some of them may be GenServers (filter removes those that are not GenServers (return :ok))
      Enum.filter((for module <- Map.values(@data_services), do: module.child_spec([csv_file])), fn e -> e != :ok end) 
    
    # Start supervisor (with a :one_for_one ~ if a child process terminates, only that process is restarted.)
    opts = [strategy: :one_for_one, name: LeaguesWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

