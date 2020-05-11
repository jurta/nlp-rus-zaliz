#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# suf2switch.pl -- generate C switch statements for parsing word stem trees
# usage: perl suf2switch.pl

use strict;
use vars qw(%s $pns);

open(SUF, "<rus.suf")      or warn "Cannot open rus.suf: $!\n"      and exit(1);
open(SUFS,"<russort.suf")  or warn "Cannot open russort.suf: $!\n"  and exit(2);
open(DATA,">librusdata.h") or warn "Cannot open librusdata.h: $!\n" and exit(3);
open(TREE,">librustree.h") or warn "Cannot open librustree.h: $!\n" and exit(4);

my ($pns) = (0);

while (<SUF>) {
  next; # TEST
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
          if (!defined $s{$s}) { $s{$s} = ($pns==12&&++$pns,++$pns) }
          printf DATA "%05d", $s{$s};
        } (split//);
        print DATA "$_\n";
      }
    } $_ ? split(/,/,$_,-1) : ($_);
  } split(/;/,$p,-1);
}

my $prev = "";
my $line = "";
#  my $level = 0;

while (<SUFS>) {
  chomp;
  $line = $_;
  my ($base) = ($line);
  while ($prev !~ /^$base/) { $base =~ s/.$// }
  my $lbase = length($base);
  my ($sline, $sprev) = (substr($line, $lbase), substr($prev, $lbase));
  my ($lline, $lprev) = (length($sline), length($sprev));
  # print TREE "($line, $prev), $base, ($sline, $sprev)\n";

  if ($lprev > 0) {
    my $i = 1;
    foreach (split(//,$sprev)) {
      print TREE "break;";
      print TREE "};" if ($i++ < $lprev);
    }
  }
  if ($lline > 0) {
    my $i = 1;
    foreach (split(//,$sline)) {
      print TREE "if(!*++w)goto x;switch(*w){" if ($i++ > ($lprev > 0) ? 1 : 0); # NEXT_CH;
      # print TREE "switch(*w){" if ($i++ > ($lprev > 0) ? 1 : 0); # NEXT_CH;
      print TREE "\ncase'$_':";
    }
  }
  print TREE "pwn[pwnc++]=1;";

#    if ($lprev > 0) {
#      my ($first, @next) = (split(//,$sprev));
#      my $i = 0;
#      foreach (split(//,$sprev)) {
#        print TREE "break;\n" if (++$i > $lline);
#      }
#      print TREE "};\n" if ($lprev > 1);
#    }
#    if ($lline > 0) {
#      my ($first, @next) = (split(//,$sprev));
#      my $i = 0;
#      foreach (split(//,$sline)) {
#        print TREE "switch (ch) {\n" if (++$i > $lprev);
#        print TREE "case '$_':\n";
#      }
#      print TREE "WI(?);\n";
#    }

#    print "switch (ch) {\n";
#    print "case '$l':\n";
#    print "WI(?);\n";
#    print "break;\n";
#    print "}\n";

#    my $indent = " " x ($base+1);
#    foreach (split(//,$sprev)) {
#      # print "-";
#      $indent =~ s/.$//;
#      print TREE $indent, "}\n";
#    }
#    foreach (split(//,$sline)) {
#      # print "+$_";
#      if (length($line) > length($prev)) {
#        print TREE $indent, "SWITCH (ch) {\n";
#      } else {
#        print TREE $indent, "break;\n";
#      }
#      print TREE $indent, "case '$_': WI(?);\n";
#      $indent .= " ";
#    }
  # print "\n";
  $prev = $line;
  # if ($line eq "") { $line = "_" }
}































