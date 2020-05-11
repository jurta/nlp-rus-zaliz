#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# This file is distributed under the terms of the GNU GPL.

# head -2222 zaliz.wfa.sort.u.all | perl conv.pl | sort -t : -k 2 | LANG=ru_RU.KOI8-R perl -Mlocale join.pl

my ($prev_wf, $prev_wi) = ("", "");
my @a;

while (<>) {
  chomp;
  my ($wf, $wi) = split(/: /,$_,2);

  if ($wi eq $prev_wi) {
    push @a, $prev_wf;
  } else {
    if (@a) {
      push @a, $prev_wf;
      print join(", ", sort @a), ": $prev_wi\n";
      undef @a;
    } else {
      print "$prev_wf: $prev_wi\n";
    }
  }

  ($prev_wf, $prev_wi) = ($wf, $wi);
}

if (@a) {
  push @a, $prev_wf;
  print join(", ", sort @a), ": $prev_wi\n";
  undef @a;
} else {
  print "$_\n";
}
