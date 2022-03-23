-module(extra_metadata).
-behaviour(otel_resource_detector).
-export([get_resource/1]).

get_resource(_) ->
    Resource1 = otel_resource:create(otel_resource_app_env:parse(get_metadata("/data/extrametadata.properties")), []),
    {ok, HiddenMetadataFile} = file:read_file("/data/hiddenpath.properties"),
    Resource2 = otel_resource:create(otel_resource_app_env:parse(get_metadata(HiddenMetadataFile)), []),
    otel_resource:merge(Resource1, Resource2).

get_metadata(FileName) ->
try
    %% io:format(FileName),
    {ok, MetadataFile} = file:read_file(FileName),
    %% io:format(MetadataFile),
    Lines = binary:split(MetadataFile, <<"\n">>, [trim, global]),
    make_tuples(Lines, [])
catch _:_ -> "Extra Metadata not found"
end.

make_tuples([Line|Lines], Acc) ->
    [Key, Value] = binary:split(Line, <<"=">>),
    make_tuples(Lines, [{Key, Value}|Acc]);
make_tuples([], Acc) -> Acc.