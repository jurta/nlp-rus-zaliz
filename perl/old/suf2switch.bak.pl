#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# suf2c.pl - sort all suffixes by frequency
# this is used for C program code generation

# usage: perl suf2c.pl

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

while (<SUFS>) {
  chomp;
  $line = $_;
  my ($base) = ($line);
  while ($prev !~ /^$base/) { $base =~ s/.$// } $base = length($base);
  my ($sline, $sprev) = (substr($line, $base), substr($prev, $base));
  # print TREE "($line, $prev), $base, ($sline, $sprev)\n";
  my $indent = " " x ($base+1);
  foreach (split(//,$sprev)) {
    # print "-";
    $indent =~ s/.$//;
    print TREE $indent, "}\n";
  }
  foreach (split(//,$sline)) {
    # print "+$_";
    if (length($line) > length($prev)) {
      print TREE $indent, "SWITCH (ch) {\n";
    } else {
      print TREE $indent, "break;\n";
    }
    print TREE $indent, "case '$_': WI(?);\n";
    $indent .= " ";
  }
  # print "\n";
  $prev = $line;
  # if ($line eq "") { $line = "_" }
}































