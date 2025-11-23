FROM elixir:1.19 as builder
WORKDIR /app

RUN apt-get update && apt-get install -y curl build-essential

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

ENV MIX_ENV="prod"

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY lib lib

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

RUN mix release

FROM debian:bookworm

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates fontconfig \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

RUN mkdir -p /var/cache/fontconfig \
    && chmod -R 777 /var/cache/fontconfig

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

ENV MIX_ENV="prod"

COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/astrologers_bot ./
COPY --chown=nobody:root static static

USER nobody

CMD ["bin/astrologers_bot", "start"]
