# https://just.systems

deps:
    mix deps.get

deps_unlock:
    mix deps.clean --unused --unlock

test:
    mix test

run:
    mix run --no-halt

dialyzer:
    mix dialyzer

credo:
    mix credo

iex:
    iex -S mix

format:
    mix format

release:
    MIX_ENV=prod mix release

clean:
    mix clean
    rm -rf _build
