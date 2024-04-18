# ProxyForKnativeServing

This is designed to free users from the hassles of Knative load balancing by converting simple URLs containing only one-level subdomains to Knative's private services specification URLs.

ProxyForKnativeServing has the following features:

  1. The subdomain is interpreted and proxied as it is as a Knative service name. Therefore, the user only needs to configure the minimum settings to connect to ProxyForKnativeServing.
  2. ProxyForKnativeServing can be used as a white list or black list to restrict the Knative services to which the user can connect. This allows you to securely protect services that you want to keep truly private.
  3. Written in Elixir, which has excellent parallel processing capabilities, ProxyForKnativeServing can manage access to a large number of Knative services.

## Specifications

* Only private Knative services are supported.
* Knative service names may only consist of lowercase letters, numbers and `-`. `.` is not supported.

## Environment variables

#### `KNATIVE_DOMAIN`

Default: `default.svc.cluster.local`

`{subdomain}.{KNATIVE_DOMAIN}` is used to access Knative services.

#### `ALLOW_SERVICES`

Default: `*`

Specify comma separated service names to which access is allowed.
If `*` is specified, access to all services is allowed.

#### `DISALLOW_SERVICES`

Default: `""`

Specify comma separated service names to which access is prohibited.
Valid only when `ALLOW_SERVICES` is `*`.

#### `WITHOUT_SERVICE_NAME`

Default: `false`

If true, only `KNATIVE_DOMAIN` is used as the Host name when accessing Knative services.
