#!/bin/bash

mkdir -p /home/ubuntu/filesystem/{docs,archive}
touch /home/ubuntu/filesystem/archive/file-bak.txt
chmod -R ubuntu:ubuntu /home/ubuntu/filesystem/
