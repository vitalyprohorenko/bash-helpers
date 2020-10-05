#!/bin/bash

echo "Connect library"
source "../control-key/$(ls ../control-key --color=never --file-type -tq1 | tail -n1)" 
ckeyLocked="rukeys"

while true; do
echo -n "GETKEY:"
ckeyRun
echo "OK RESULT[${ckeyRType}/${ckeyResult}]"
done
