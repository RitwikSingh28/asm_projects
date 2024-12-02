#!/bin/bash

set -xe

as exit.s -o exit.o
ld exit.o -o exit

as -g maximum.s -o maximum.o
ld maximum.o -o maximum
