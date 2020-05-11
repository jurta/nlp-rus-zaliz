#!/usr/bin/perl -w
# -*- mode: perl; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# License: GNU GPL 2 (see the file README)

# perl adb2lst.pl zaliz.adb | LANG=ru_RU.KOI8-R sort -u > zaliz.lst

use POSIX qw(locale_h strftime);
my $CURDATE = strftime('%Y-%m-%d', localtime);
my $PROGRAM = ($0 =~ /([^\/]*)$/)[0];
my $VERSION = "0.0.1";

print <<HERE;
# -*- mode: text; coding: cyrillic-koi8; -*-
# $CURDATE $PROGRAM v$VERSION http://jurta.org/ru/nlp/rus/zaliz
HERE

while (<>) {
  next if /^#/;
  chomp;
  print "$1\n" if /^Ó:([^\t]+)/;
}
