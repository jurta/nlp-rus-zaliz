#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# perl suf2hash.pl rus.suf > rushash.pl
# perl -e '$_=reverse"abc";s/(.)/->{"$1"}/g;eval"push(\@{\$w$_},[3])";use Data::Dumper;print "\$w$_"."->[0]->[0]",Dumper(eval"\$w$_"."->[0]->[0]")'
# perl -e 'while(<>){@a=split/\t/;$n+=$a[1]*(($a[2]=~tr/;/;/)-($a[2]=~tr/#-/#-/))}print $n' rus.suf
# perl -lne 'map{print}split/[;,]/,(split/\t/)[2]' rus.suf | sort | uniq -c | sort -nr > suffixes

# NB! This is very memory-hungry solution, use suf2db2.pl instead

use strict;
use vars qw($s);

while (<>) {
  chomp;
  my ($n, $c, $p) = split /\t/;
  my ($j);
  map {
    $j++;
    map {
      # TODO: ignore "(.*)" && "[.*]"
      s/[\*\?\&]$//;
      if (!/[-\#]$/) {
        $_ = reverse."\*";
#          s/(.)/->{"$1"}/g;
#          eval "push(\@{\$s$_},[$n,$j])";
        s/(.)/->{'$1'}/g;
        print "push(\@{\$s$_},[$n,$j]);\n";
#          print "push(\@{\$s$_},[$n,$j])\n";
#          print "\$s$_=3;\n";     # TEST
      }
    } $_ ? split(/,/,$_,-1) : ($_);
  } split(/;/,$p,-1);
}

print "use Data::Dumper;\n";
print "print Dumper(\$s)\n";
