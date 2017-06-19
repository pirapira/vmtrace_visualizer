# Ethereum VM trace visualizer

![Dataflow visualized](https://yoichihirai.com/spam.png)

[geth](https://github.com/ethereum/go-ethereum) outputs a VM trace for an Ethereum
 transaction, by [`debug.traceTransaction()` function](https://github.com/ethereum/go-ethereum/wiki/Management-APIs#debug_tracetransaction).
This repository contains a small ruby program that annotates the traces with the original steps that produced the operands.

The enricher tries to answer questions like

* how does this contract calculate the value it sends?
* how does this contract determine the address it calls?

on concrete transaction logs.

Currently the enricher keeps track of the origins of values on the stack.

## Usage

After checking out this repository:
```
ruby src/enricher.rb example/example_1.json | less
```
is a way to use it.

## Example

Before the transformation
```
{
	"depth":1,
	"error":null,
	"gas":977788,
	"gasCost":20,
	"memory":[
		"0000000000000000000000000000000000000000000000000000000000000000",
		"0000000000000000000000000000000000000000000000000000000000000000",
		"0000000000000000000000000000000000000000000000000000000000000060"
	],
	"op":"EXP",
	"pc":9,
	"stack":[
		"00000000000000000000000000000000000000000000000000000000000000e0",
		"0000000000000000000000000000000000000000000000000000000000000002"
	],
	"storage":{}
},
```

After the transformation
```diff
{
	"depth":1,
	"error":null,
	"gas":977788,
	"gasCost":20,
	"memory":[
		"0000000000000000000000000000000000000000000000000000000000000000",
		"0000000000000000000000000000000000000000000000000000000000000000",
		"0000000000000000000000000000000000000000000000000000000000000060"
	],
	"op":"EXP",
	"pc":9,
	"stack":[
		"00000000000000000000000000000000000000000000000000000000000000e0",
		"0000000000000000000000000000000000000000000000000000000000000002"
	],
	"storage":{
	},
+	"step":5,
+	"arg_origins":[
+		{
+			"depth":1,
+			"step":3
+		},
+		{
+			"depth":1,
+			"step":4
+		}
+	]
},

```

## Graphviz output

As a preparation, you need the `graphviz` tools:
```
sudo apt install graphviz
```

Then,
```
ruby src/enricher.rb -g example/example_1.json > graph.dot && \
dot -Tpdf graph.dot -o graph.pdf
```
would produce a data-flow diagram in `graph.pdf`.

## How to obtain vm traces

The input JSON can be obtained from `geth` RPC.  See `example/get_example_1.sh` for how.
