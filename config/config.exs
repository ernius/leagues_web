# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config
                                                  # if we want to read these parameters from runtime environment variables
config :leagues_web, rest_api_port: 4001          #System.get_env("LEAGUES_PORT") || "${LEAGUES_PORT}",

config :leagues_web, leagues_csv_file: "Data.csv" #System.get_env("CSV_FILE") || "${CSV_FILE}",


# More data endpoints can be added here
# Data providers implemented as modules using ETS are enabled 
config :leagues_web, data_modules: %{"json"      => LeaguesData.LeaguesJSONETS,
			             "protobuff" => LeaguesData.LeaguesProtoBufferETS,
				     #"json2"      => LeaguesData.LeaguesJSON,    # the two options can be used in conjunction also (json and json2 formats available at the same time)
				     #"protobuff2" => LeaguesData.LeaguesProtoBuffer
                                    }


# Data providers implemented as GenServer agents

# config :leagues_web, data_modules: %{"json"      => LeaguesData.LeaguesJSON,
# 			               "protobuff" => LeaguesData.LeaguesProtoBuffer
#                                     }


#     config :logger, level: :info


# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"
