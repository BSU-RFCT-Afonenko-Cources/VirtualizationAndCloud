#!/bin/bash

echo "$(whoami)" > report.txt
echo "$(hostname)" >> report.txt
ls >> report.txt
