#! /bin/bash

# Run a geth node and sync it up to around block 2,300,000.
# Then run this command to get an example vm trace.

# This requires geth on this PR https://github.com/ethereum/go-ethereum/pull/3064

~/src/go-ethereum/build/bin/geth --exec 'console.log(JSON.stringify(debug.traceTransaction("0x88a7fe25b04a0e5c245e102d0a5d17300cf7d840fd4d09328d88c35b200550fa", {limit: 1000})))' attach | head -n 1
