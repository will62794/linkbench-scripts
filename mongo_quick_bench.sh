#!/bin/bash
set -o nounset # Don't reference undefined variables.
set -o errexit # Don't ignore failing commands.

#
# A helper script for running a scaled down linkbench benchmark against MongoDB running on a local
# machine. It will run the benchmark against a MongoDB server running on localhost:27017. It will
# optionally run the load phase and/or request phase automatically and output the relevant metrics for
# each into a given stats directory.
#
# Usage:
#
#	./mongo_quick_bench.sh <loaders> <requesters> <maxid1> <maxtime> <warmup> <stats_directory> [load|request|all]
#
#

# Load the benchmark parameters.

LOADERS=$1 # number of requester threads for the 'load' phase.
REQUESTERS=$2 # number of requester threads for the 'request' phase.
MAXID1=$3 # number of graph nodes for the load phase.
MAXTIME=$4 # maximum number of time (seconds) to run the benchmark.
WARMUP=$5 # amount of time to do requests before gathering benchmark stats.
STATSDIR=$6 # directory to output stats from test runs.

# Parse the load/request phase option.
if [ $7 == "load" ]
  then
    PHASE="load"
    echo "Running only the LOAD phase."
  elif [ $7 == "request" ]
  then
  	PHASE="request"
  	echo "Running only the REQUEST phase."
  else
  	PHASE="all"
  	echo "Running both the LOAD and REQUEST phase."
fi

HOST="localhost"
REQUESTS=500000000 # maximum number of requests done by each thread.

DATESTR=$(date +"%Y_%m_%d_%I_%M_%p")
STATS_SUBDIR="$STATSDIR"

# Create the appropriate stats directories.
mkdir -p "$STATSDIR"
mkdir -p "$STATS_SUBDIR"

# Save the benchmark parameters used for this test.
PARAMS_FILE="$STATS_SUBDIR/benchmark-params.txt"
echo "requesters $REQUESTERS" > "$PARAMS_FILE"
echo "loaders $LOADERS" >> "$PARAMS_FILE"
echo "maxid1 $MAXID1" >> "$PARAMS_FILE"
echo "requests $REQUESTS" >> "$PARAMS_FILE"
echo "warmup $WARMUP" >> "$PARAMS_FILE"
echo "maxtime $MAXTIME" >> "$PARAMS_FILE"

echo "Provided benchmark parameters:"
cat $PARAMS_FILE

echo "Saving stats to '$STATSDIR' directory."

if [ $PHASE == "load" ] || [ $PHASE == "all" ]
	then

# Run the LOAD phase. The load phase generates a graph and stores it in the database.
LOAD_PHASE_LOG="$STATS_SUBDIR/load-phase.log"
echo "Going to run the LOAD phase. Saving load phase log to $LOAD_PHASE_LOG"
./bin/linkbench -c config/LinkConfigMongoDb.properties \
				-csvstats "$STATS_SUBDIR/load-phase-stats.csv" \
				-csvstream "$STATS_SUBDIR/load-phase-stream-stats.csv" \
				-L $LOAD_PHASE_LOG \
				-D host="$HOST" \
				-D loaders=$LOADERS \
				-D requesters=$REQUESTERS \
				-D maxid1=$MAXID1 \
				-D requests=$REQUESTS \
				-D maxtime=$MAXTIME \
				-l #load phase flag.
fi


if [ $PHASE == "request" ] || [ $PHASE == "all" ]
	then

# Run the REQUEST phase. The request phase runs operations on the loaded graph.
REQUEST_PHASE_LOG="$STATS_SUBDIR/request-phase.log"
echo "Going to run the REQUEST phase. Saving request phase log to $REQUEST_PHASE_LOG"
./bin/linkbench -c config/LinkConfigMongoDb.properties \
				-csvstats "$STATS_SUBDIR/request-phase-stats.csv" \
				-csvstream "$STATS_SUBDIR/request-phase-stream-stats.csv" \
				-L $REQUEST_PHASE_LOG \
				-D host="$HOST" \
				-D loaders=$LOADERS \
				-D requesters=$REQUESTERS \
				-D maxid1=$MAXID1 \
				-D requests=$REQUESTS \
				-D maxtime=$MAXTIME \
				-r # request phase flag.
fi
