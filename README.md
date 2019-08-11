# Leagues

 Elixir application that serves through a REST API football results loaded from a CSV file.

## HTTP Endpoints

This application provides the following **HTTP** endpoints:

### /ping

**HTTP method**: GET

Dummy endpoint that returns "pong in" followed by the hostname. Useful to test load balancing.

```
> curl http://localhost/ping
pong in hostname
```

### /metrics

**HTTP method**: GET 

Returns a collection of metrics used for **Prometheus**


### /leagues?format={output_format} 

**HTTP method**: GET 

Returns existing leagues and seasons pairs.

The result is a *JSON* string if **output_format=json**, or a *Protocol Buffers* binary format if **output_format=protobuff**.

Examples: 
  
```
> curl http://localhost/leagues?format=json
[{"season":"201617","league":"D1"},{"season":"201617","league":"E0"},{"season":"201516","league":"SP2"},{"season":"201617","league":"SP2"},{"season":"201516","league":"SP1"},{"season":"201617","league":"SP1"}]

> curl http://localhost/leagues?format=protobuff
...
```

### /leagues/{league_id}/{season_id}/?format={output_format} 

**HTTP method**: GET 

Returns the matches for a given *league_id* and *season_id* pair in the specified *output_format*.

The result is a *JSON* string if **output_format**=**json**, or a *Protocol Buffers* binary format if **output_format**=**protobuff**.

Examples: 
  
```
> curl http://localhost/leagues/SP1/201617?format=json
...
> curl http://localhost/leagues/SP1/201617?format=protobuff
...
```

## Local and Dockerized Deploy (using Distillery)

Pack release

```
> mix deps.get
```

```
> mix release
```

Start the application in port 4001 in the foreground, like `mix run --no-halt` or `iex -S mix`

```
> _build/dev/rel/leagues_web/bin/leagues_web foreground

```

## Docker 

Build docker application image

```
> docker build -t leagues-web-docker .
```

Run one dockerized application instance 

```
> docker run --rm  leagues-web-docker 
```

Test call

```
> curl http://172.17.0.2:4001/leagues?format=json
```

Stop

```
> docker container stop container-id
```

## Docker Compose

Starts: **3 application instances**, a **HAProxy** load balancer, a **Prometheus** application that pulls metrics from the 3 application instances, and a **Grafana** viewer for the collected metrics.

```
> docker-compose up
```

Tests that the 3 applications instances are working by pinging 3 times, and checking that 3 different hostnames are returned with the following command:

```
> for i in {1..3}; do curl  http://localhost/ping;echo ""; done
```

Each application instance can be directly accessed (bypassing the haproxy at port 80) at the following urls:
     - [http://localhost:81/ping](http://localhost:81/ping)
     - [http://localhost:82/ping](http://localhost:81/ping)
     - [http://localhost:83/ping](http://localhost:81/ping)     

**Grafana** metrics viewer can be accessed at [http://localhost:3000](http://localhost:3000) (user: admin, password:leagues-web)

**Prometheus** scraper instance is at [http://localhost:9090](http://localhost:9090). In [http://localhost:9090/targets](http://localhost:9090/targets) we can see the 3 scraped application instances.

## Kubernetes

Start `minikube`

```
> minikube start
```

Deploy

Run eval $(minikube docker-env) before building your image.
Full answer here: https://stackoverflow.com/a/40150867


```
> eval $(minikube docker-env)
> cd config/kubernetes/
> kubectl create -f leagues-web-deployment.yaml
> kubectl create -f leagues-web-service.yaml

```

Starts application

```
> minikube service leagues-web-service
```

## API Documentation

[Documentation](./doc/index.html)

Generation `mix docs`

## Testing

Run `mix test` to run tests.

## Configuration [config.exs](./config/config.exs).

The *port*, and the name of the *CSV file name* can be configured through `rest_api_port:` and `leagues_csv_file:`.

The CSV file is loaded from the application's `priv` directory.

The available modules for the different output formats are configured in the `data_modules:` map entry.

## Stack of technologies

- *Plug* for HTTP requests routing.

- *Cowboy* for the HTTP server.

- *Poison* for JSON encoding.

- *exprotobuf* for Protocol Buffers encoding.

- *StreamData* for data generation and property-based testing.

- *Ex-doc* for API documentation generation.

- *Distillery* for application packaging.

- *Prometheus* stack for metrics.
	
Why not Webmachine insted of Plug? Webmachine allows you not to have to manually set status codes or supply response headers. This leads to a very declarative style. However, it is only compatible with mochiweb, and not updated for more modern HTTP server libraries as Cowboy.
  
## Solution description

HTTP requests are served by a Cowboy HTTP server, and routed via the Plug module [LeaguesWeb.LeaguesWebEndpoint](./lib/leagues_web/leagues_web_endpoint.ex). Information requests are directly derived to the module [LeaguesData.LeaguesData](./lib/leagues_data/leagues_data.ex), which depending on the requested format (*json* or *protobuff*) pulls information with the specified format.

### Plug Routes

Routes are handled in the Plug module [LeaguesWeb.LeaguesWebEndpoint](./lib/leagues_web/leagues_web_endpoint.ex).

### Data Providers

Data providers must implement the **behavior** specified in module [LeaguesData.LeaguesDataBehavior](lib/leagues_data/leagues_data_behavior.ex)

New data providers could be easily added in the config file [confix.exs](./config/config.exs).

[LeaguesData.LeaguesData](./lib/leagues_data/leagues_data.ex) is the entry point to the following four implementations:

Using a **GenServer** agent:

- [LeaguesData.LeaguesJSON](./lib/leagues_data/json/leagues_json.ex)) for JSON format

- [LeaguesData.LeaguesProtoBuffer](./lib/leagues_data/protobuff/leagues_protobuffer.ex) for Protocol Buffers format

Using the **Erlang Term Storage (ETS)**:

- [LeaguesData.LeaguesJSONETS](./lib/leagues_data/json/leagues_json_ets.ex)) for JSON format

- [LeaguesData.LeaguesProtoBufferETS](./lib/leagues_data/protobuff/leagues_protobuffer_ets.ex) for Protocol Buffers format

These modules *load* the CSV, and *encode* it in the expected output format in memory at application's *initialization time*. Thus no data transformation is done when requests are handled.

The first two implementations are isolated through `GenServer` agents, from which data can be pulled through synchronous messages.

The second two are just module calls that use the ETS to store and retrieve the data.

The `GenServer` are added to the application's children specification in [LeaguesWeb.Application](./lib/leagues_web/application.ex). In this way they are supervised, and so automatically restarted in case of fail. In the case of plain modules, they are just initialized and then filtered from the application's children list.

The following lines show that the ETS implementation is more performant than the `GenServer` implementation, thus ETS implementation is used.

```
iex(12)> :timer.tc(fn -> LeaguesData.LeaguesJSON.leagues() end)
{46,
 "[{\"season\":\"201617\",\"league\":\"D1\"},{\"season\":\"201617\",\"league\":\"E0\"},{\"season\":\"201516\",\"league\":\"SP2\"},{\"season\":\"201617\",\"league\":\"SP2\"},{\"season\":\"201516\",\"league\":\"SP1\"},{\"season\":\"201617\",\"league\":\"SP1\"}]"}
 
iex(13)> :timer.tc(fn -> LeaguesData.LeaguesJSONETS.leagues() end)
{13,
 "[{\"season\":\"201617\",\"league\":\"D1\"},{\"season\":\"201617\",\"league\":\"E0\"},{\"season\":\"201516\",\"league\":\"SP2\"},{\"season\":\"201617\",\"league\":\"SP2\"},{\"season\":\"201516\",\"league\":\"SP1\"},{\"season\":\"201617\",\"league\":\"SP1\"}]"}    
```

However, `GenServer` option can be used by just un-commenting it from *config.ex*, and commenting the ETS entry. Also, the two implementations can coexist by just adding more formats to the `data_modules:` map (as the commented "json2" and "protobuff2" entries) in file *config.ex*.

Protocol Buffer messages are specified in the module [LeaguesData.LeaguesMessages](./lib/leagues_data/protobuff/leagues_messages.ex).

## HAProxy

The *HAProxy* configuration file can be found at [haproxy.cfg](./config/haproxy/haproxy.cfg). The essential fragment is:

```
backend app  
        balance roundrobin  
        mode http  
        server srv1 leagues1:4001
        server srv2 leagues2:4001
        server srv3 leagues3:4001
```

The above lines configure the HTTP load balancer to serve our 3 three application instances `leagues1:4001`, `leagues2:4001`, and `leagues1:4001`. The `leaguesX` names come from the [docker-compose.yml](docker-compose.yml), where the service applications instances are defined.

## Metrics

**Prometheus** and **Grafana** are a common combination of tools to monitor systems. Prometheus pulls metrics from endpoint [http://localhost/metrics](http://localhost/metrics), and using Grafana we can view the pulled metrics, configure custom dashboards, and add notifications via Slack, PagerDuty, etc. Prometheus pulling application is external to this web application, so it can be easily stopped, and the potential application's overload caused by metrics will automatically end. We can also tune in Prometheus' pulling /scrape interval/.

The file [prometheus.yml](./config/prometheus/prometheus.yml) configures Prometheus to pull from the 3 application instances.

```
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "leagues"
    scrape_interval: "15s"
    static_configs:
      - targets: ['leagues1:4001', 'leagues2:4001', 'leagues3:4001']
```

We use the same endpoints names used in HAProxy configuration. We do not pull metrics through the HAProxy, as metrics contains information from the running OS, thus should be collected for each application instance.

By default Prometheus collects several metrics and it can be customized. I implemented a basic custom counter in module [Web.Metrics.CommandInstrumenter](./lib/leagues_web/leagues_metrics/leagues_metrics_command_instrumenter.ex). This counter simply counts the number of hits to "http://localhost/leagues?format={format_output}".

Previous counter information is shown in a "Leagues Command" custom dashboard added to **Grafana**. 

Previous custom dashboard and Prometheus datasource location is loaded from files: [dashboard.yaml](./config/grafana/provisioning/dashboards/dashboard.yaml) and [datasource.yaml](./config/grafana/provisioning/datasources/datasource.yaml), as it can be seen in docker-compose file [docker-compose.yml](docker-compose.yml).


