-module(hello_handler).
-behaviour(cowboy_handler).
-export([init/2]).

-include_lib("opentelemetry_api/include/opentelemetry.hrl").
-include_lib("opentelemetry_api/include/otel_tracer.hrl").
-include_lib("opentelemetry/include/otel_resource.hrl").

init( Req, State ) ->
    ?with_span(<<"hello-span">>, #{attributes => [{<<"span_attribute_key_1">>, <<"span_attribute_value_1">>}]}, fun child_call/1),
    Req_1 = cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/plain">>},
        <<"Hello world from Erlang (Cowboy)">>,
        Req
    ),
    {ok, Req_1, State}.

child_call(_SpanCtx) ->
    %% add event, attributes and set status to the active span
    ?add_event(<<"event_message">>, [{<<"event_attribute_key">>, <<"event_attribute_value">>}]),
    ?set_attributes([{late_attribute_key, <<"late_attribute_value">>}]),
    ?set_status(opentelemetry:status(?OTEL_STATUS_OK, [])),

    %% start a child span with attribute and event
    ?with_span(<<"child-span">>, #{},
               fun(_ChildSpanCtx) ->
                       ?set_attributes([{child_attribute_key, <<"child_attribute_value">>}]),
                       ?add_event(<<"child_event_message">>, [])
               end).
