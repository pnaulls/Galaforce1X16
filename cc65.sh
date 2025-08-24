#!/bin/bash -e

export PATH=$PATH:~/x16/cc65/bin/

program="GalaForce1"

source=$1

cl65 -m map.txt -t cx16 -C galaforce1.cfg  --cpu 65C02 -o ${program}.PRG -l ${program}.list ${source} --verbose
