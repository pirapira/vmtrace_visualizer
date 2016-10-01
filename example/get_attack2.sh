#! /bin/bash

# Run a geth node and sync it up to around block 2,300,000.
# Then run this command to get an example vm trace.

# This requires geth on this PR https://github.com/ethereum/go-ethereum/pull/3064

~/src/go-ethereum/build/bin/geth --exec 'console.log(JSON.stringify(debug.traceTransaction("0x7ce2fefac6c92c16c26b69480d16d870c0548dced69eb29f66632f1b7eb02cde", {limit: 1000})))' attach | head -n 1
