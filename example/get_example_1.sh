#! /bin/bash

# Run a geth node and sync it up to around block 1,000,000.
# Then run this command to get an example vm trace.

geth --exec 'console.log(JSON.stringify(debug.traceTransaction("f682a82e7e1d1410f4f3ff208746dc0cd447a14a0afc575976e9949499175fc5")))' attach | head -n 1
