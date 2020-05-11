#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# test_acc.pl - find wordforms accents which are out of head word boundaries

# cat rus.adb | perl test_acc.pl

# TODO: convert to priparad.pl

use strict;
use vars qw(%sufs %accs);

my ($pns, $pna) = (0, 0);

# open(ADB,"<rus.adb") or warn "Cannot open rus.adb: $!\n" and exit(1);
open(SUF,"<".shift) or warn "Cannot open file: $!\n" and exit(2);
open(ACC,"<".shift) or warn "Cannot open file: $!\n" and exit(3);

while (<SUF>) {
  next if /^#/;
  chomp;
  my ($n, $c, $p) = split /\t/;
  $sufs{$n} = $p;
}

# use Data::Dumper;

while (<ACC>) {
  next if /^#/;
  chomp;
  my ($n, $c, $p) = split /\t/;
#   if ($n == 2) { print Dumper([map {[split(/,/,$_,-1)]} split(/;/,$p,-1)]),"\n"; }
  $accs{$n} = [map {[map { s/\..*//; $_ if !/[-\#]$/ } split(/,/,$_,-1)]} split(/;/,$p,-1)];
}

while (<>) {
  next if /^#/;
  chomp;
  my ($w) = /^с:([^\t]+)/;
  my ($a) = /\tу:([^\t]+)/ ? $1 : 0;
  my ($b) = /\tб:([^\t]+)/ ? $1 : length($w);
  my ($i) = /\tио:([^\t]+)/ ? $1 : 0;
  my ($j) = /\tиу:([^\t]+)/ ? $1 : 0;

  my $wb = substr($w,0,$b);

  if ($i) {
    my $wfn = 0;
    map {
      my $wfnv = 0;
      map {
        # TODO: ignore "(.*)" && "[.*]"
        s/[\*\?]$//;
        if (!/[-\#]$/) {
          printf("$wb$_\t$w\t%s\n",$accs{$j}[$wfn][$wfnv]) if ($accs{$j}[$wfn][$wfnv] > length($wb.$_));
        }
        $wfnv++;
      } $_ ? split(/,/,$_,-1) : ($_);
      $wfn++;
    } split(/;/,$sufs{$i},-1)
  } else {
    $a =~ s/\..*//;
    printf("$w\t$w\t%s\n",$a) if ($a > length($w));
  }
}

# Full output:
# озорств	озорство	8	(ИСПРАВЛЕНО)
# перешагнунн	перешагнуть	12	(ИСПРАВЛЕНО)
