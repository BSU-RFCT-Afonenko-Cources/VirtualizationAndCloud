#!/bin/bash

words=("$@")
longest=
for w in "${words[@]}"; do
  (( ${#w} > ${#longest} )) && longest=$w
done
echo "$longest"
