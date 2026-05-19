#!/bin/bash

[[ -f $1 ]] || { echo "missing"; return 1; }
cp "$1" "$1.bak"
