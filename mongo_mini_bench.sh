#!/bin/bash

#
# A helper script for running a scaled down linkbench benchmark against MongoDB running on the local machine.
#
# Usage: ./mongo_mini_bench.sh [load|request]
#

set -o nounset # Don't reference undefined variables.
set -o errexit # Don't ignore failing commands.


# Benchmark configuration options.

HOST="localhost"
LOADERS=1 # number of requester threads for the 'load' phase.
REQUESTERS=1 # number of requester threads for the 'request' phase.
MAXID1=1000001 # number of graph nodes for the load phase.
REQUESTS=500000000 # maximum number of requests done by each thread.
MAXTIME=480 # maximum number of time (seconds) to run the benchmark.
WARMUP=120 # amount of time to do requests before gathering benchmark stats.
LOOPS=1
STATSDIR="stats"

LOAD_PHASE_FLAG="-l" # load phase generates a graph and stores it in the database.
REQUEST_PHASE_FLAG="-r" # request phase runs operations on the loaded graph.

if [ -z "$1" ]
  then
    echo "Must supply phase argument: either 'request' or 'load'."
     exit 1
fi

if [[ $1 = "load" ]]; then
	PHASE_FLAG="$LOAD_PHASE_FLAG"
	echo "Doing LOAD phase, with $MAXID1 graph nodes and $LOADERS loader threads."
fi

if [[ $1 = "request" ]]; then
	PHASE_FLAG="$REQUEST_PHASE_FLAG"
	echo "Doing REQUEST phase."
fi

RequestPhase (){
	local STATSFILE="$STATSDIR/mdb-request-stats-$1.csv"
	./bin/linkbench -c config/LinkConfigMongodb.properties -csvstats $STATSFILE \
					-D host="$HOST" -D user=linkbench -D password=linkbench \
					-D loaders=$LOADERS \
					-D requesters=$REQUESTERS \
					-D maxid1=$MAXID1 \
					-D requests=$REQUESTS \
					-D maxtime=$MAXTIME \
					$PHASE_FLAG
}

mkdir -p "$STATSDIR"

for i in $(seq 1 $LOOPS); do
	RequestPhase $i
done


