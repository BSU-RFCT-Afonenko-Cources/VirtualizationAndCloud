#!/bin/bash

d=$1
mkdir -p "$d"/{src,data,reports}
echo "# $d" > "$d/README.md"
