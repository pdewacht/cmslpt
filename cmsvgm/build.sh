#!/bin/sh
set -e

VERSION=20200415

CC='wcc -bt=dos -zq -oxhs -mc -zm'
ZDEFS="-dNO_GZCOMPRESS"
DEFS="-dVERSION=$VERSION $ZDEFS"

set -x
ragel -s -G2 vgm.rl
$CC $DEFS main.c
$CC $DEFS timer.c
$CC $DEFS vgm.c
$CC $DEFS ../cmslpt/cmsinit.c
$CC $DEFS ../cmslpt/cmsout.c

$CC $ZDEFS zlib/gzlib.c
$CC $ZDEFS zlib/gzread.c
$CC $ZDEFS zlib/inflate.c
$CC $ZDEFS zlib/inffast.c
$CC $ZDEFS zlib/inftrees.c
$CC $ZDEFS zlib/adler32.c
$CC $ZDEFS zlib/crc32.c
$CC $ZDEFS zlib/zutil.c

wlink name clpttest system dos file main,timer,vgm,cmsinit,cmsout,gzlib,gzread,inflate,inffast,inftrees,zutil,adler32,crc32 option quiet,map,eliminate
