#================
# 1st Build Stage build
#================

FROM elixir:1.7.3 AS build
ENV DEBIAN_FRONTEND=noninteractive

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod REPLACE_OS_VARS=true

# Cache elixir deps
COPY mix.exs mix.lock ./
RUN mix deps.get
COPY config ./config
RUN mix deps.compile

COPY . .
RUN mix release --env=prod

#Extract Release archive to /rel for copying in next stage
RUN APP_NAME="leagues_web" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export


#================
# 2nd Build Stage release
#================

FROM elixir:1.7.3
ENV DEBIAN_FRONTEND=noninteractive

EXPOSE 4001

ENV PORT=4001 MIX_ENV=prod REPLACE_OS_VARS=true SHELL=/bin/bash

#Copy and extract .tar.gz Release file from the previous stage
COPY --from=build /export/ .

#Set default entrypoint and command
ENTRYPOINT ["./bin/leagues_web"]
CMD ["foreground"]






