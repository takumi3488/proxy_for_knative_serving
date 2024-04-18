FROM elixir:1.16.2-slim

ENV MIX_ENV=prod

WORKDIR /app

COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod && \
    mix compile && \
    mix release

CMD ["mix", "phx.server"]
