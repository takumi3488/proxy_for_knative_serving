defmodule ProxyForKnativeServing.Application do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: ProxyForKnativeServing.ProxyPlug, options: [port: 8080]},
    ]
    opts = [strategy: :one_for_one, name: ProxyForKnativeServing.Supervisor]
    Logger.info("Starting application...")
    Supervisor.start_link(children, opts)
  end
end
