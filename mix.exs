defmodule ProxyForKnativeServing.MixProject do
  use Mix.Project

  def project do
    [
      app: :proxy_for_knative_serving,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ProxyForKnativeServing.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:req, "~> 0.4"},
      {:testcontainers, "~> 1.7.0"}
    ]
  end
end
