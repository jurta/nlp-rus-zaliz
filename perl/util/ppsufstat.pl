#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# ppsufstat.pl - postprocessor that prints statistics for suffixes

# perl ppsufstat.pl rus.suf

use strict;
use vars qw($s);

while (<>) {
  chomp;
  my ($n, $c, $p) = split /\t/;
  my $cnt = ($p =~ tr/;/;/) + 1;
#    print "$cnt: $p\n";
  my $i = 0;

  map {
    $i++;
    map {
      $s->{$cnt}->{$i}->{$_}++;
    } $_ ? split(/,/,$_,-1) : ($_);
  } split(/;/,$p,-1);
}

use Data::Dumper;
print Dumper($s);
