#!/usr/bin/perl -w
# -*- Perl -*-
# $Revision$

# perl -n util/subpatch-check.pl z.subpatch

if (/^< (\S+)/) { $w = $1 }
if (/^> (\S+)/) { print if $1 ne $w }

# Other checks:
# egrep "^>.*\."
# egrep "^> [^{]"
# perl -lne 'print if s/^.*\@:?\s*//' z.adb.err | LANG=ru_RU.KOI8-R sort -u > z_l.adb.err
# perl -lne 'print if s/^\< :?\s*//' z.x.subpatch | LANG=ru_RU.KOI8-R sort -u > z_l.except
