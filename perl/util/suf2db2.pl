#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id: suf2db2.pl,v 1.2 2001/03/17 17:29:23 juri Exp $
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# suf2db2.pl -- generate tables for parsing suffix trees and building paradigms
# usage: perl suf2db2.pl rus.suf

use strict;
use vars qw($t %srt $isrt $ists @sts @psts $ipsts
            %sufst %sufsts %stsuf %sufpr @prs @pprs $ipprs
            %suf %sufr %sufs $isuf $isufs @psufs @ppsufs $ippsufs $maxpn
            @psuf  $ipsuf $sufstr);

# $t - suffix tree
# %srt - keeps order of suffix tree nodes by their frequency
# $isrt - counter for %srt
# @sts - states
# $ists - counter of states
# @psts - pointers to states
# $ipsts - counter of pointers to states
# @prs - paradigms
# @pprs - pointers to paradigms
# $ipprs - counter of pointers to paradigms
# %sufst - mapping suffix to state
# %stsuf - mapping state to suffix (reverse of sufst)
# %sufsts - mapping suffix to state transitions (pairs of input char and next state)
# %sufpr - mapping suffix to paradigm
# %suf - mapping suffix to suffix number
# %sufr - mapping suffix number to suffix
# $isuf - counter of suffixes
# %sufs - mapping paradigm number to suffix numbers
# @psufs - pointers to suffixes
# @ppsufs - pointers to pointers to suffixes
# $ippsufs - counter of pointers to pointers to suffixes
# @psuf - pointers to suffix substrings
# $ipsuf - counter of pointers to suffix substrings
# $sufstr - suffix string

my ($isrt, $ists, $ipsts, $ipprs, $ippsufs, $maxpn, $ipsuf) = (0, 1, 0, 0, 0, 0, 1);
push @psts, 0, ($ipsts += 1);
push @sts, 0;
push @pprs, 0, ($ipprs += 1);
push @prs, 0;
push @ppsufs, 0, ($ippsufs += 1);
push @psufs, 0;

# 1. create suffix tree from suffix table for wordform analysis
# 2. build suffix index for wordform generation
while (<>) {
  chomp;
  my ($n, $c, $p) = split /\t/;
  my ($j) = (0);
  $maxpn = $n if ($n > $maxpn);
  $sufs{$n} = [map {
    $j++;
    if (!defined $suf{$_}) { $suf{$_} = (++$isuf) }
    my $s = $_ ne "-" ? $suf{$_} : 0;
#      print "suf>$_:$s\n";
    map {
      s/[\(\[*?&].*$//;
      if (!/[\-\#]$/) {
        $_ = reverse;
        push @{$sufpr{$_}}, [$n, $j];
        $_ .= "\$";
        my $s = "";
        map {
          $s .= $_;
          if (!defined $srt{"$s\$"}) { $srt{"$s\$"} = (++$isrt) }
          if (!defined $srt{$s}) { $srt{$s} = (++$isrt) }
        } (split//);
        s/(.)/->{'$1'}/g;
        eval "\$t$_=3";
        ""
      }
    } ($_ ? split(/,/,$_,-1) : ($_));
    $s
  } (split(/;/,$p,-1))];
#    print "sufs>$n:",@{$sufs{$n}},"\n";
}

# 3. build state transition table from suffix tree
sub walk_suf_tree {
  my ($t, $p) = @_;
  my (@sortedkeys) = (sort { $srt{"$p$a"} <=> $srt{"$p$b"} } (keys %$t));
  my $first;
  if (!defined $sufst{$p}) { $sufst{$p} = ($ists++) }
  foreach my $key (@sortedkeys) {
    if ($key ne "\$") {
      if (!defined $sufst{"$p$key"}) { $sufst{"$p$key"} = ($ists++) }
      push @{$sufsts{$p}}, ord($key), $sufst{"$p$key"};
    }
  }
  foreach my $key (@sortedkeys) {
    walk_suf_tree($t->{$key},"$p$key") if ($key ne "\$");
  }
}

walk_suf_tree($t,"");

%stsuf = reverse %sufst;

# 4. build result tables
foreach (1..$ists-1) {
  my $s = $stsuf{$_};
  # print "$_:$s:", join(",",map { "$_->[0]:$_->[1]" }@{$sufpr{$s}}), "/", join(";",defined @{$sufsts{$s}}?@{$sufsts{$s}}:"-"), "\n";
  if (defined $sufsts{$s} && @{$sufsts{$s}}) {
    push @sts, @{$sufsts{$s}};
    push @psts, ($ipsts += (@{$sufsts{$s}}));
  } else {
    push @sts, 0;
    push @psts, ($ipsts += 1);
  }
  if (defined $sufpr{$s} && @{$sufpr{$s}}) {
    foreach (@{$sufpr{$s}}) { push @prs, $_->[0], $_->[1] }
    push @pprs, ($ipprs += (@{$sufpr{$s}} * 2));
  } else {
    push @prs, 0;
    push @pprs, ($ipprs += 1);
  }
}

foreach (1..$maxpn) {
  if (defined $sufs{$_}) {
    push @psufs, @{$sufs{$_}};
    push @ppsufs, ($ippsufs += (@{$sufs{$_}}));
  } else {
    push @psufs, 0;
    push @ppsufs, ($ippsufs += 1);
  }
}

%sufr = reverse %suf;
push @psuf, 0, 1;
$sufstr = "-";
foreach (1..$isuf) {
  push @psuf, ($ipsuf += length($sufr{$_}));
  $sufstr .= $sufr{$_};
}

push @sts, 0;                   # TODO: test on boundary values
push @prs, 0;                   # TODO: test on boundary values

# 5. output results
sub print_c_tables {
  print "static const uint16_t psts[] = {", sprintf("%6d,", shift(@psts)),"\n";
  while (@psts) {
    my @psts10 = splice(@psts,0,10);
    print join(",", map { sprintf("%6d", $_) } @psts10), (@psts?",":""), "\n";
  }
  print "};\n\n";
  print "static const int16_t sts[] = {", sprintf("%6d,", shift(@sts)),"\n";
  while (@sts) {
    my @sts10 = splice(@sts,0,10);
    print join(",", map { sprintf("%6d", $_) } @sts10), (@sts?",":""), "\n";
  }
  print "};\n\n";
  print "static const int32_t pprs[] = {", sprintf("%6d,", shift(@pprs)),"\n";
  while (@pprs) {
    my @pprs10 = splice(@pprs,0,10);
    print join(",", map { sprintf("%6d", $_) } @pprs10), (@pprs?",":""), "\n";
  }
  print "};\n\n";
  print "static const int16_t prs[] = {", sprintf("%6d,", shift(@prs)),"\n";
  while (@prs) {
    my @prs10 = splice(@prs,0,10);
    print join(",", map { sprintf("%6d", $_) } @prs10), (@prs?",":""), "\n";
  }
  print "};\n\n";
  print "static const int32_t ppsufs[] = {", sprintf("%6d,", shift(@ppsufs)),"\n";
  while (@ppsufs) {
    my @ppsufs10 = splice(@ppsufs,0,10);
    print join(",", map { sprintf("%6d", $_) } @ppsufs10), (@ppsufs?",":""), "\n";
  }
  print "};\n\n";
  print "static const int16_t psufs[] = {", sprintf("%6d,", shift(@psufs)),"\n";
  while (@psufs) {
    my @psufs10 = splice(@psufs,0,10);
    print join(",", map { sprintf("%6d", $_) } @psufs10), (@psufs?",":""), "\n";
  }
  print "};\n\n";
  print "static char *sufs[] = {\n  \"-\",\n";
  foreach (1..$isuf) {
    print "  \"", $sufr{$_}, "\",\n";
  }
  print "  \"\"\n};\n\n";
}

#  print_c_tables();

use DB_File;

sub store_data_to_db {
  my $dbfn = "rus.db";
  my ($dbp, %dbh, %suf);

  # Enable duplicate records
  $DB_BTREE->{'flags'} = R_DUP;

  $dbp = tie %dbh, "DB_File", $dbfn, O_RDWR|O_CREAT, 0640, $DB_BTREE
      or warn "Cannot open $dbfn: $!\n" and exit(1);

  $dbh{'__psts'} = pack("S*", @psts);
  $dbh{'__sts'} = pack("s*", @sts);
  $dbh{'__pprs'} = pack("l*", @pprs);
  $dbh{'__prs'} = pack("s*", @prs);
  $dbh{'__ppsufs'} = pack("l*", @ppsufs);
  $dbh{'__psufs'} = pack("s*", @psufs);
  $dbh{'__psuf'} = pack("l*", @psuf);
  $dbh{'__suf'} = $sufstr;
}

store_data_to_db();
























