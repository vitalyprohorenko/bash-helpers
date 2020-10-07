#!/bin/bash

echo "Connect library"
source "../control-key/control-key.1.shlib" 
ckeyLocked="rukeys"

while true; do
echo -n "GETKEY:"
ckeyRun
echo "OK RESULT[${ckeyRType}/${ckeyResult}]"
done
