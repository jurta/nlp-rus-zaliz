#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# priparad.pl - print all wordforms of all words

# cat zaliz2.adb | perl priparad.pl > zaliz2.parad.all &
# cat zaliz2.adb | grep -i "^с:аэрофотосъёмка" | perl priparad.pl > zaliz2.parad.all &
# head zaliz2.adb | perl priparad.pl

# perl priparad_join.pl zaliz2.suf zaliz2.acc zaliz2.adb > zaliz2.parad.join

use strict;
use vars qw(%sufs %accs);

# open(ADB,"<rus.adb") or warn "Cannot open rus.adb: $!\n" and exit(1);
open(SUF,"<".shift) or warn "Cannot open file: $!\n" and exit(2);
open(ACC,"<".shift) or warn "Cannot open file: $!\n" and exit(3);

while (<SUF>) {
  chomp;
  next if /^#/;
  my ($n, $c, $p) = split /\t/;
  $sufs{$n} = $p;
}

while (<ACC>) {
  chomp;
  next if /^#/;
  my ($n, $c, $p) = split /\t/;
  $accs{$n} = $p;
}

while (<>) {
  chomp;
  next if /^#/;

  s/^с:/w:/;
  s/\tу:/\ta:/;
  s/\tт:/\ts:/;
  s/\tт2:/\ts2:/;
  s/\tб:/\tb:/;
  s/\tз:/\tк:/;
  s/\tз2:/\tк2:/;
  s/\tз3:/\tк3:/;
  s/\tио:/\ti:/;
  s/\tиу:/\tj:/;
  s/\tискл:/\texc:/;
  s/\tслсч:/\tсл:/;

  s/(?<=\ti:)([^\t]+)/$sufs{$1}/e;
  s/(?<=\tj:)([^\t]+)/$accs{$1}/e;
  # s/\tj:[^\t]+//;

  print join("\t",sort split(/\t/)), "\n";
  # print "$_\n";
}
