#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# sufsort.pl -- sort all suffixes by frequency
# this is used for C program code generation (by suf2switch.pl)

# usage: perl sufsort.pl rus.suf | LANG=C sort | perl -lpe 's/^\d*//g' | uniq > russort.suf

use strict;
use vars qw(%s $pns);

my ($pns) = (0);

while (<>) {
  chomp;
  my ($n, $c, $p) = split /\t/;
  my ($j);
  map {
    $j++;
    map {
      s/[\(\[*?&].*$//;
      if (!/[\-\#]$/) {
        $_ = reverse."\$";
        my $s = "";
        map {
          $s .= $_;
          if (!defined $s{"$s\$"}) { $s{"$s\$"} = ($pns==12&&++$pns,++$pns) }
          if (!defined $s{$s}) { $s{$s} = ($pns==12&&++$pns,++$pns) }
          printf "%05d", $s{$s};
        } (split//);
        s/\$$//;
        print "$_\n";
      }
    } $_ ? split(/,/,$_,-1) : ($_);
  } split(/;/,$p,-1);
}
