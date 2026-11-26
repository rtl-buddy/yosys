#!/usr/bin/env bash
# A memory of non-power-of-two depth leaves read-mux bits undriven after
# memory_map -formal; write_aiger turns them into AIGER inputs that have no
# entry in the witness map. aiw2yw must report them and still convert the trace.
set -ex
# yosys-witness needs the python click module, which not every test host has.
python3 -c 'import click' 2>/dev/null || { echo 'skipping: python3 has no click module'; exit 0; }
pfx=aiw2yw_undriven
${YOSYS} -q -p "read_verilog -formal $pfx.v; prep -top top; async2sync; chformal -lower; setundef -undriven -anyseq; memory_map -formal; formalff -clk2ff -ff2anyinit; simplemap; dffunmap; aigmap; opt_clean; write_aiger -I -B -zinit -no-startoffset -ywmap $pfx.ywa $pfx.aig"
read -r latches inputs < <(python3 -c "import json; m = json.load(open('$pfx.ywa')); print(m['latch_count'], m['input_count'])")
{
  echo 1; echo b0
  printf '0%.0s' $(seq 1 "$latches"); echo
  for t in 0 1; do printf '1%.0s' $(seq 1 "$inputs"); echo; done
  echo .
} > $pfx.aiw
${YOSYS_WITNESS#@} aiw2yw $pfx.aiw $pfx.ywa $pfx.yw > $pfx.log
grep -q "belong to unknown signals" $pfx.log
python3 -c "import json; json.load(open('$pfx.yw'))"
rm -f $pfx.ywa $pfx.aig $pfx.aiw $pfx.yw $pfx.log
