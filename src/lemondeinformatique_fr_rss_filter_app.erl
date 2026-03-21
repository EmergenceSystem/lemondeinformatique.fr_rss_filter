%%%-------------------------------------------------------------------
%%% @doc Le Monde Informatique RSS filter.
%%%
%%% Copies priv/rss_config.json to the working directory then starts
%%% an rss_filter agent under its own name with specific capabilities.
%%% @end
%%%-------------------------------------------------------------------
-module(lemondeinformatique_fr_rss_filter_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    copy_config(),
    application:ensure_all_started(rss_filter),
    em_filter:start_agent(lemondeinformatique_fr_filter, rss_filter_app, #{
        capabilities => rss_filter_app:base_capabilities()
                        ++ [<<"lemondeinformatique">>, <<"french">>,
                            <<"it">>, <<"enterprise">>]
    }),
    {ok, self()}.

stop(_State) ->
    em_filter:stop_agent(lemondeinformatique_fr_filter).

copy_config() ->
    case code:priv_dir(lemondeinformatique_fr_rss_filter) of
        PrivDir when is_list(PrivDir) ->
            Src = filename:join(PrivDir, "rss_config.json"),
            file:copy(Src, "rss_config.json"),
            ok;
        {error, bad_name} ->
            ok
    end.
