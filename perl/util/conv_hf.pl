#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# This file is distributed under the terms of the GNU GPL.

# head -1111 zaliz.wfa.sort.u.all | perl conv.pl
# LANG=ru_RU.KOI8-R grep -i "^стекл" zaliz.wfa.sort.u.all | perl conv.pl

my ($prev_wf, $prev_wi) = ("", "");
my @a;

while (<>) {
  chomp;
  my ($wf, $wi) = split(/ /,$_,2);

  if ($wf eq $prev_wf) {
    push @a, $prev_wi;
  } else {
    if (@a) {
      push @a, $prev_wi;
      print "$prev_wf: ", join(", ", @a), "\n";
      undef @a;
    }
  }

  ($prev_wf, $prev_wi) = ($wf, $wi);
}

if (@a) {
  push @a, $prev_wi;
  print "$prev_wf: ", join(", ", @a), "\n";
  undef @a;
}
