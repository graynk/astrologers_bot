# https://just.systems

deps:
    mix deps.get

test:
    mix test

run:
    mix run --no-halt

format:
    mix format

release:
    MIX_ENV=prod mix release

clean:
    mix clean
    rm -rf _build
