FROM elixir:1.16.2-slim AS build
ENV MIX_ENV=prod
WORKDIR /app
COPY . .
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod && \
    mix compile && \
    mix release

FROM elixir:1.16.2-slim
ENV MIX_ENV=prod
WORKDIR /app
COPY --from=build /app/_build/prod/rel/ /app
CMD ["/app/proxy_for_knative_serving/bin/proxy_for_knative_serving", "start"]
