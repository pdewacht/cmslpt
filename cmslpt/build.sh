#!/bin/sh
set -e

VERSION_MAJOR=1
VERSION_MINOR=0

CC='wcc -bt=dos -zq -oxhs'
CC32='wcc386 -mf -zl -zls -zq -oxhs'
AS='wasm -zq'
DEFS="-dVERSION_MAJOR=$VERSION_MAJOR -dVERSION_MINOR=$VERSION_MINOR"
#DEFS="$DEFS -dDEBUG"

set -x
ragel -G2 cmdline.rl
$CC $DEFS cmslpt.c
$CC $DEFS cmdline.c
$CC $DEFS cmsinit.c
$CC $DEFS cmsout.c
$CC $DEFS res_data.c
$AS $DEFS resident.s
$AS $DEFS res_end.s
wlink @cmslpt.wl
