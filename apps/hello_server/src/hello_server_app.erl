%%%-------------------------------------------------------------------
%% @doc hello_server public API
%% @end
%%%-------------------------------------------------------------------

-module(hello_server_app).

-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_StartType, _StartArgs) ->
    Attributes = #{key => val},
    ExtraMetadata = otel_resource:create(otel_resource_app_env:parse(Attributes), <<"https://opentelemetry.io/schemas/1.8.0">>),

    otel_resource:merge(otel_tracer_provider:resource(), ExtraMetadata),

    Dispatch = cowboy_router:compile([
        { '_', [{<<"/">>, hello_handler, [] }]}
    ]),
    {ok, _} = cowboy:start_clear(
        hello_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    hello_server_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
