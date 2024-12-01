#!/bin/bash

set -xe

as exit.s -o exit.o
ld exit.o -o exit
./exit
