#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# perl -Mlocale gen_aff.pl

# use locale with LANG=ru_RU.KOI8-R for sort by Russian collation

use Zaliz::DB::ADB;
use Zaliz::Inflect qw(inflect);

Zaliz::DB::ADB::load_words();

my $n = shift || 100;

open(ADB,">rus$n.adb");
open(SUF,">rus$n.suf");
open(ACC,">rus$n.acc");

my ($pns, $pna) = (0, 0);

map {
  my $w = $_;
  for $wihp (Zaliz::DB::ADB::get_wi($w)) {
    my ($wi, $wfh) = Zaliz::Inflect::wi2paradigm($wihp);;

    foreach $ph (@{$wihp}[1..scalar(@{$wihp})-1]) {
      foreach $key (keys %{$ph}) {
        $wihp->[0]->{$key} = $ph->{$key} if !(exists $wihp->[0]->{$key})
      }
    }

    my %props = map {
      $_,$wihp->[0]->{$_}
    } grep {!/^(w|и|у|ос|ч|z|p|n|v|exc)/} keys %{$wihp->[0]};

    if (defined $wfh) {
      my $base = $wi->[0]->{'w'};
      map {
        map {
          if (length($_->{'w'}) # && !(defined $_->{'x'} && $_->{'x'} eq "n")
              ) {
            while ($_->{'w'} !~ /^$base/) { $base =~ s/.$// }
          }
        } @{$_}
      } values(%{$wfh});
      $props{'b'} = length($base);
      my $pos = $wi->[0]->{'s'};
      my $suf =
          join(";", map {
            join(",", map {
              (!(length($_->{'w'}) # && !(defined $_->{'x'} && $_->{'x'} eq "n")
                )) ?
              "-" :
              ($_->{'w'} =~ /^$base(.*)/) ?
              $1.(defined $_->{'к' } ? "(".$_->{'к' }.")" : "").
                 (defined $_->{'п2'} ? "[".(($_->{'п2'} eq "1")?"в,на":($_->{'п2'}))."]" : "").
                 (defined $_->{'x'} &&
                   ($_->{'x'} eq "z" && "*" || # "?"
                    $_->{'x'} eq "p" && "?" || # "??" по словарю-"*"(e.g.*мацы)
                    $_->{'x'} eq "n" && "#" || # "*"
                    ""))
              : ""
            } @{$wfh->{$_}})
          } @{$Zaliz::Inflect::paradigms{$pos}});
      my $acc =
          join(";", map {
            join(",", map {
              (defined $_->{'x'} && $_->{'x'} eq "n") ? "-" :
              $_->{'a'}
            } @{$wfh->{$_}})
          } @{$Zaliz::Inflect::paradigms{$pos}});
      if (!defined $sufs{$suf}) { $sufs{$suf} = ($pns==12&&++$pns,++$pns) }
      $pcs{$sufs{$suf}}++;                # pcs - paradigm counter for suffixes
      $props{'i'} = $sufs{$suf};
      if (!defined $accs{$acc}) { $accs{$acc} = ($pna==12&&++$pna,++$pna) }
      $pca{$accs{$acc}}++;                # pca - paradigm counter for accents
      $props{'j'} = $accs{$acc};
#        print ADB "w:$base\tb:",length($base),"\t",$sufs{$suf},"\n"
#        print ADB "$base\t",$sufs{$suf},"\n"
    }
    print ADB "w:$w", map ({
      "\t$_" . ($props{$_} ne ":" ? ":".$props{$_} : "")
    } sort(keys %props)), "\n";
  }
} (sort (keys (%Zaliz::DB::ADB::wordpos)))[0..$n];

map { print SUF "$sufs{$_}\t$pcs{$sufs{$_}}\t$_\n" } sort {$pcs{$sufs{$b}} <=> $pcs{$sufs{$a}} || $sufs{$a} <=> $sufs{$b}} (keys(%sufs)); # don't sort here. Why??? We need statistics here!!!
map { print ACC "$accs{$_}\t$pca{$accs{$_}}\t$_\n" } sort {$pca{$accs{$b}} <=> $pca{$accs{$a}} || $accs{$a} <=> $accs{$b}} (keys(%accs));


