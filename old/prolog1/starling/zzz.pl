#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# perl zzz.pl ~/usr/lang/rus/start/zz1

while(<>) {
    chomp;
    s/\(_.*_\)\s*//;
    s/\[.*\]\s*//;
    s/\004.*$//;
    s/ $//;
    s/([\d*]+)Á/\1a/;
    s/([\d*]+)×/\1b/;
    s/([\d*]+)Å/\1e/;
    s/([\d*]+)Ó/\1c/;
    print "$_\n";
}
