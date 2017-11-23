#!/bin/bash
numdcs=$1
numnodes=$2
echo "waiting..."
sleep 10
echo "linking..."
#escript /code/join_cluster_script.erl
for i in `seq 1 ${numdcs}`; do
    dcnum=$i
    escript /code/join_cluster_script.erl $numnodes antidote-dc-$i- antidote-dc-$i.default.svc.cluster.local
done
escript /code/connect-dcs.erl $numdcs
echo "done.."
sleep 60m
