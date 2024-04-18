defmodule ProxyForKnativeServingTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts ProxyForKnativeServing.ProxyPlug.init([])

  test "200" do
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

  test "401 (not included allowed service)" do
    System.put_env("ALLOW_SERVICES", "public")
    System.put_env("WITHOUT_SERVICE_NAME", "false")

    conn = %Plug.Conn{conn(:get, "/") | host: "private.example.com"}
      |> ProxyForKnativeServing.ProxyPlug.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body =~ "not allowed"
  end

  test "401 (included disallowed service)" do
    System.put_env("ALLOW_SERVICES", "*")
    System.put_env("DISALLOW_SERVICES", "private")
    System.put_env("WITHOUT_SERVICE_NAME", "false")

    conn = %Plug.Conn{conn(:get, "/") | host: "private.example.com"}
      |> ProxyForKnativeServing.ProxyPlug.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body =~ "not allowed"
  end

  test "404" do
    System.put_env("WITHOUT_SERVICE_NAME", "false")

    conn = %Plug.Conn{conn(:get, "/") | host: "example.com"}
      |> ProxyForKnativeServing.ProxyPlug.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body =~ "Subdomain not specified"
  end
end
