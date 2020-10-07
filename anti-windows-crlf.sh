#!/bin/bash
[ -r "$1" ] && sed -i -e 's/\r$//' $1 || echo "Can't read [$1]"