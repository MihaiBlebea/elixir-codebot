FROM elixir:latest

WORKDIR /codebot

COPY . .

RUN mix local.hex --force

RUN export MIX_ENV=prod && \
    mix deps.get

CMD ["mix", "run", "--no-halt"]

