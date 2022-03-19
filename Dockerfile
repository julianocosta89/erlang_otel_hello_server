FROM erlang:24.3-alpine as build

RUN mkdir /data
WORKDIR /data

COPY . .

RUN rebar3 upgrade --all

EXPOSE 8080

RUN rebar3 as prod release

CMD ["/data/_build/prod/rel/hello_server/bin/hello_server", "foreground"]
