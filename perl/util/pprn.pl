#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# pprn.pl - postprocessor that removes non-existing wordforms

# perl pprn.pl

# TODO: make rebase!

use strict;
use vars qw(%convs %sufs %pcs $pns %conva %accs %pca $pna);

my ($pns, $pna) = (0, 0);

open(ADB,"<rusz.adb") or warn "Cannot open rusz.adb: $!\n" and exit(1);
open(SUF,"<rusz.suf") or warn "Cannot open rusz.suf: $!\n" and exit(2);
open(ACC,"<rusz.acc") or warn "Cannot open rusz.acc: $!\n" and exit(3);
open(ADB2,">rus.adb") or warn "Cannot open rus.adb: $!\n"  and exit(4);
open(SUF2,">rus.suf") or warn "Cannot open rus.suf: $!\n"  and exit(5);
open(ACC2,">rus.acc") or warn "Cannot open rus.acc: $!\n"  and exit(6);

while (<SUF>) {
  chomp;
  my ($n, $c, $p) = split /\t/;
  $p =~ s/[^\t;,]*\#/-/g; $p =~ s/,-//g; $p =~ s/-,//g;
  $p =~ s/\(устар\.\)/&/g; $p =~ s/\(затрудн\.\)/*/g;
  if (!defined $sufs{$p}) { $sufs{$p} = ($pns==12&&++$pns,++$pns) }
  $pcs{$sufs{$p}} += $c;
  $convs{$n} = $sufs{$p};
}
map { print SUF2 "$sufs{$_}\t$pcs{$sufs{$_}}\t$_\n" } sort {$pcs{$sufs{$b}} <=> $pcs{$sufs{$a}} || $sufs{$a} <=> $sufs{$b}} (keys(%sufs));

while (<ACC>) {
  chomp;
  my ($n, $c, $p) = split /\t/;
  $p =~ s/[^\t;,]*\#/-/g; $p =~ s/,-//g; $p =~ s/-,//g;
  if (!defined $accs{$p}) { $accs{$p} = ($pna==12&&++$pna,++$pna) }
  $pca{$accs{$p}} += $c;
  $conva{$n} = $accs{$p};
}
map { print ACC2 "$accs{$_}\t$pca{$accs{$_}}\t$_\n" } sort {$pca{$accs{$b}} <=> $pca{$accs{$a}} || $accs{$a} <=> $accs{$b}} (keys(%accs));

while (<ADB>) {
  chomp;
  s/(?<=\ti:)(\d+)/$convs{$1}/e;
  s/(?<=\tj:)(\d+)/$conva{$1}/e;
  print ADB2 "$_\n";
}





