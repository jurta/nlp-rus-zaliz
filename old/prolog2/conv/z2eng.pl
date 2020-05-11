#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# perl z2eng.pl /home/juri/cd4/doc/lang/rus/new/starling/z > z2eng.out

while(<>) {
  chomp;
#    if(/^$/) { next; }
  if(s/(.*?)\s*\d.*\004(.*)$//) { print "$1 $2\n"; }
}
