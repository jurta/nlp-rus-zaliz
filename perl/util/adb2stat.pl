#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# License: GNU GPL 2 (see the file README)

# perl adb2stat.pl zaliz.adb > zaliz.stat

# perl -lne 'print $1 while(/\$props{(.*?)}/g)' txt2adb.pl | LANG=ru_RU.KOI8-R sort -u
# perl -lne 'print $1 while(/\t([^:\t]+):?/g)' zaliz.adb | LANG=ru_RU.KOI8-R sort -u
# perl -lne 'print $1 while(/\t([^:\t]+):?/g)' zaliz.adb | LANG=ru_RU.KOI8-R sort -u

while (<>) {
  chomp;
  next if /^#/;
  for (split /\t/) {
    /^([^:]+)/
      && ($w1->{$1}++);
    /^([^:]+):(.*)/
      && ($1 !~ /^(с|искл|з|слсч|фк|фр|гпр|у)$/)
      && ($w2->{$1}->{$2}++);
  }
}

use Data::Dumper;
print Dumper($w1,$w2);
