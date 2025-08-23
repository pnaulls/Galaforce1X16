#!/bin/bash -e

export PATH=$PATH:~/x16/cc65/bin/

program="GalaForce1"

source=$1

cl65 --cpu 65C02 -o ${program}.PRG -l ${program}.list ${source} --verbose
