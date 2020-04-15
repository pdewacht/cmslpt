#!/bin/sh
set -e

VERSION_MAJOR=0
VERSION_MINOR=2

CC='wcc -bt=dos -zq -oxhs'
CC32='wcc386 -mf -zl -zls -zq -oxhs'
AS='wasm -zq'
DEFS="-dVERSION_MAJOR=$VERSION_MAJOR -dVERSION_MINOR=$VERSION_MINOR"
#DEFS="$DEFS -dDEBUG"

set -x
$CC $DEFS cmslpt.c
$AS $DEFS resident.s
$AS $DEFS res_end.s
wlink @cmslpt.wl
