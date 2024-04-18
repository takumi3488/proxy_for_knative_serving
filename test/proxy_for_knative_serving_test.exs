defmodule ProxyForKnativeServingTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts ProxyForKnativeServing.ProxyPlug.init([])

  test "e2e" do
    {:ok, _} = Testcontainers.start_link()

    config = %Testcontainers.Container{
      image: "gcr.io/knative-samples/helloworld-go",
      exposed_ports: [8080],
      environment: %{"TARGET" => "Knative"}
    }

    {:ok, container} = Testcontainers.start_container(config)

    System.put_env(
      "KNATIVE_DOMAIN",
      container.ip_address
    )

    System.put_env(
      "KNATIVE_PORT",
      "8080"
    )

    System.put_env("WITHOUT_SERVICE_NAME", "true")

    conn =
      conn(:get, "/")
      |> ProxyForKnativeServing.ProxyPlug.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "Hello Knative!"
  end
end
