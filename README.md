# Linkbench Helper Scripts

These are some helper scripts to more easily run linkbench on a local or remote machine.

## Examples

Run only the LOAD phase of a linkbench benchmark against a MongoDB server running on `localhost:27017`, with
1 million graph nodes, 1 loader thread, 2 requester threads, for a maximum time of 360 seconds and a warmup time
of 60 seconds:

```
./mongo_quick_bench.sh 1 2 100001 360 60 "/path/to/stats/dir" load
```

Run only the REQUEST phase:

```
./mongo_quick_bench.sh 1 2 100001 360 60 "/path/to/stats/dir" request
```

Run the LOAD and REQUEST phase:

```
./mongo_quick_bench.sh 1 2 100001 360 60 "/path/to/stats/dir" all
```