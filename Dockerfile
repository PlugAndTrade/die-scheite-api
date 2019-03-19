FROM elixir:1.6-alpine

ENV APP_NAME die_scheite_api
ENV SRC_DIR /src/$APP_NAME

RUN apk add --no-cache git

RUN mkdir -p $SRC_DIR
WORKDIR $SRC_DIR

ADD mix.exs $SRC_DIR
ADD mix.lock $SRC_DIR
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile

ADD . $SRC_DIR/
RUN MIX_ENV=prod mix compile --env=prod
RUN MIX_ENV=prod mix release --env=prod

FROM alpine:3.8

ENV APP_NAME die_scheite_api
ENV SRC_DIR /src/$APP_NAME

RUN apk add --no-cache ncurses-libs libcrypto1.0 bash tzdata

RUN mkdir -p /$APP_NAME /tmp
WORKDIR /$APP_NAME

COPY --from=0 $SRC_DIR/_build/prod/rel/$APP_NAME/releases/latest/$APP_NAME.tar.gz /tmp/
RUN tar xvzf /tmp/$APP_NAME.tar.gz
RUN rm -f /tmp/$APP_NAME.tar.gz

ENV PORT 4000
ENV REPLACE_OS_VARS true

CMD /$APP_NAME/bin/$APP_NAME foreground
