# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# TODO: use /root/usr/lang/rus/zaliz/conv/tab2full.pl

package Zaliz::DB::Tab;

## get_wi($wi) -- return hash of word properties
sub get_wi {
  my $wi = shift;
  my ($w, $a, @r) = split(/\t/, $wi);
  my %wi;
  $wi{w} = $w;
  $wi{a} = $a;
  foreach (@r) {
    if (/:/) { $wi{$`} = $' }
    else { $wi{$_} = 1 }
  }
  %wi
}

while (<>) {
  chomp;
  
}
