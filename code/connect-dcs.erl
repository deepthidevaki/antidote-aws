#!/usr/bin/env escript
%%! -smp enable -name erlshell -setcookie antidote
main([NumDCs]) ->

  % Node1 = 'antidote@antidote-dc-1-0.antidote-dc-1.default.svc.cluster.local',
  % Node2 = 'antidote@antidote-dc-2-0.antidote-dc-2.default.svc.cluster.local',
  Suffix=".default.svc.cluster.local",
  Nodes=lists:map(
                    fun(N) ->
                      list_to_atom("antidote@antidote-dc-" ++ integer_to_list(N) ++ "-0.antidote-dc-"++ integer_to_list(N) ++ Suffix)
                    end, lists:seq(1, list_to_integer(NumDCs))
                   ),
  io:format("Cluster Heads ~p~n", [Nodes]),
  Node1=hd(Nodes),
  Res = net_adm:ping(Node1),
  io:format("Ping ~p from node ~p ~n", [Res, Node1]),
  lists:foreach(fun(Node) ->
                  rpc:call(Node, inter_dc_manager, start_bg_processes, [stable]),
                  ok = rpc:call(Node, application, set_env, [antidote, txn_cert, false])
                end, Nodes),
  Descriptors=lists:map(fun(Node)->
                          {ok, Desc} = rpc:call(Node, inter_dc_manager, get_descriptor, []),
                          Desc
                        end, Nodes),
  %io:format("Descriptors ~p ~n",[Descriptors]),
  lists:foreach(fun(Node) ->
                  rpc:call(Node, inter_dc_manager, observe_dcs_sync, [Descriptors])
                end, Nodes),
  io:format("Connection setup!~n"),
  [Node1, Node2 | _] = Nodes,
  dummy_test(Node1, Node2).

dummy_test(Node1, Node2) ->
    Key = antidote_key,
    Type = antidote_crdt_counter,
    Bucket = antidote_bucket,
    Object = {Key, Type, Bucket},
    Update = {Object, increment, 1},

    {ok, _} = rpc:call(Node1, antidote, update_objects, [ignore, [], [Update]]),
    {ok, CT} = rpc:call(Node1, antidote, update_objects, [ignore, [], [Update]]),
    {ok, _} = rpc:call(Node2, antidote, update_objects, [CT, [], [Update]]),
    %% Propagation of updates
    F = fun() ->
                {ok, [Val], _CommitTime} = rpc:call(Node2, antidote, read_objects, [ignore, [], [Object]]),
                Val
        end,
    Res = F(),
    io:format("Read after update res ~p ~n", [Res]),
    ok.
