defmodule ProxyForKnativeServing.ProxyPlug do
  import Plug.Conn
  use Plug.ErrorHandler

  @host_ptn Regex.compile!("^(?<service>[a-z0-9\\-]+)(\\.[a-zA-Z0-9\\-_]+){2,3}")

  def init(options), do: options

  def call(conn, _opts) do
    # Convert the host to a Knative URL
    port = System.get_env("KNATIVE_PORT", "80") |> Integer.parse() |> elem(0)
    uri = request_url(conn) |> URI.parse() |> Map.replace(:port, port)

    case Map.get(uri, :host) |> convert_host_to_knative_url() do
      {401, msg} ->
        send_resp(conn, 401, msg)

      {404, msg} ->
        send_resp(conn, 404, msg)

      {200, host} ->
        uri =
          Map.replace(uri, :host, host)
          |> Map.replace(:authority, host)
          |> Map.replace(:scheme, "http")
          |> URI.to_string()

        # Replace the host header
        headers =
          conn.req_headers
          |> Enum.map(fn {k, v} ->
            if k == "host" do
              {"Host", host}
            else
              {k, v}
            end
          end)

        # Forward the request to the Knative service
        req =
          Req.new(
            body: read_body(conn) |> elem(1),
            headers: headers,
            method: conn.method,
            url: uri
          )

        {_, response} = Req.Request.run_request(req)

        # Put headers to the response
        conn =
          Enum.reduce(response.headers, conn, fn {k, v}, conn ->
            put_resp_header(conn, k, hd v)
          end)

        send_resp(conn, response.status, response.body)
    end
  end

  @spec is_allowed_service?(String.t()) :: boolean()
  defp is_allowed_service?(service) do
    allow_services = System.get_env("ALLOW_SERVICES", "*")
    disallow_services = System.get_env("DISALLOW_SERVICES", "")

    case allow_services do
      "*" ->
        disallow_services
        |> String.split(",")
        |> Enum.all?(fn s -> String.trim(s) !== service end)

      _ ->
        String.split(allow_services, ",") |> Enum.member?(service)
    end
  end

  @spec convert_host_to_knative_url(String.t()) :: {Integer.t(), String.t()}
  defp convert_host_to_knative_url(host) do
    domain = System.get_env("KNATIVE_DOMAIN", "default.svc.cluster.local")
    without_service_name = System.get_env("WITHOUT_SERVICE_NAME", "false")

    m = Regex.named_captures(@host_ptn, host)

    if without_service_name === "true" do
      {200, domain}
    else
      case m do
        %{"service" => service} ->
          if is_allowed_service?(service) do
            {200, "#{service}.#{domain}"}
          else
            {401, "Service not allowed"}
          end

        _ ->
          {404, "Subdomain not specified from #{host}"}
      end
    end
  end
end
