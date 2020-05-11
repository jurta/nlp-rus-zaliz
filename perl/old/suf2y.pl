#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# suf2y.pl -- generates YACC/BISON grammar rules for parsing word stems
# usage: perl suf2y.pl rus.suf > librustree.y

use strict;
use vars qw($d %s $pns $pna);

my ($pns, $pna) = (0, 0);

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
          # printf "%05d", $s{$s};
        } (split//);
        s/(.)/->{'$1'}/g;
        eval "\$d$_=3";
        ""
        # s/\$$//; print "$_\n";
      }
    } $_ ? split(/,/,$_,-1) : ($_);
  } split(/;/,$p,-1);
}

sub pr {
  my ($d, $p) = @_;
  my (@sortedkeys) = (sort { $s{"$p$a"} <=> $s{"$p$b"} } (keys %$d));
  # return unless ref($d) eq 'HASH';
  my $first;
  print make_nts($p), ":";
  foreach my $key (@sortedkeys) {
    if ($key eq "\$") {
      # print "$p\n" ;
    } else {
      if (defined $first) { print "|" } else { $first = 1 }
      print "'$key'", !((defined $d->{"$key"}->{"\$"}) && (keys(%{$d->{"$key"}})==1)) ? make_nts("$p$key") : "" ;#, " {i=", ++$pna, "} ";
    }
  }
  print ";\n";
  foreach my $key (@sortedkeys) {
    pr($d->{$key},"$p$key") if ($key ne "\$" and !((defined $d->{"$key"}->{"\$"}) && (keys(%{$d->{"$key"}})==1)));
  }
}

# make_nts -- make "nonterminal symbol"
sub make_nts {
  my ($nts) = shift;
  $nts =~ tr/-ÁÂ×ÇÄÅ£ÖÚÉÊËÌÍÎÏĞÒÓÔÕÆÈÃŞÛİßÙØÜÀÑ/_abwgde6vzijklmnoprstufhc4127yx53q/;
  $nts =~ s/^(?=[^a-z])/_/;
  $nts
}

sub pr_orig {
  my ($d, $p) = @_;
  # return unless ref($d) eq 'HASH';
  foreach my $key (sort { $s{"$p$a"} <=> $s{"$p$b"} } (keys %$d)) {
    if ($key eq "\$") {
      print "$p\n" ;
    } else {
      pr(%$d->{$key},"$p$key");
    }
  }
}

pr($d,"");

#  use Data::Dumper;;
#  print Dumper(\$d);































