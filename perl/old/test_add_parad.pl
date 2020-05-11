#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# perl add_parad.pl z.lst > z.prp &
# head -100 z.lst | perl add_parad.pl > z100.prp &
# egrep "адрес" z.lst | perl add_parad.pl &

use Zaliz::DB::Prop;
use Zaliz::Inflect qw(inflect);

$| = 1;

while (<>) {
  chomp;
  my $w = $_;
  for $wihp (Zaliz::DB::Prop::get_wi($w)) {
#      use Data::Dumper;
#      print Dumper($wihp), "\n";
    # moved (defined $wihp->[0]->{'и'}) to Inflect !!!
    # my ($wi, $wfh) = (defined $wihp->[0]->{'и'}) && Zaliz::Inflect::wi2paradigm($wihp);;
    # print Orpho::Accent::accent($wi->[0]->{'w'},$wi->[0]->{'a'},"u"); # ???
    # print "(".$wi->[0]->{'к'}.")" if defined $wi->[0]->{'к'};
    # print $wi->[0]->{'w'}."\n"; # !!!

    my ($wi, $wfh) = Zaliz::Inflect::wi2paradigm($wihp);;

    foreach $ph (@{$wihp}[1..scalar(@{$wihp})-1]) {
      foreach $key (keys %{$ph}) {
        $wihp->[0]->{$key} = $ph->{$key} if !(exists $wihp->[0]->{$key})
      }
    }

    my %props = map {
      $_,$wihp->[0]->{$_}
    } grep {!/^(w|и|у|ос|ч|z|p|n|v|exc)/} keys %{$wihp->[0]};

    # ам;е;ами;;а;а;ах;у;ом;а;ов;
    # b:адрес	пе:псе1	пм:псм2	пае:асе1	пам:асм2

    if (defined $wfh) {
#      use Data::Dumper;
#      print Dumper($wfh), "\n";
      my $base = $wi->[0]->{'w'};
      map { map {
        $base=substr($base,0,diff_str($base,$_->{'w'}))
      } @{$_}} values(%{$wfh});
      $props{'b'} = $base;
      # print "$base\n";
      my $pos = $wi->[0]->{'s'};
      # $pc - paradigm category, $pcn - paradigm category name
      foreach $pc (($pos eq "с") ? ("е:.е","м:.м") :
                   ($pos eq "п") ? ("п:п","к:к") :
                   ($pos eq "г") ? ("и:[^пнбч]","п:п","н:н","б:б","ч:ч") :
                   ("a:")) {
        my ($pcn,$pc) = ($pc =~ /(.):(.*)/);
        # print "$pcn:";
        $suf =
          join(";", map {
            join(",", map {
              ($_->{'w'} =~ /^$base(.*)/) && $1 || ""
            } @{$wfh->{$_}})
          } grep {/^$pc/} @{$Zaliz::Inflect::paradigms{$pos}});
        $acc =
          join(";", map {
            join(",", map {
              $_->{'a'}
            } @{$wfh->{$_}})
          } grep {/^$pc/} @{$Zaliz::Inflect::paradigms{$pos}});

        if (!defined $sufs{$suf}) { $sufs{$suf} = $pos.$pcn.++$posnr{"$pos.$pcn"} }
        $props{"пп$pcn"} = $sufs{$suf};
        if (!defined $accs{$acc}) { $accs{$acc} = $pos.$pcn.++$posanr{"$pos.$pcn"} }
        $props{"пу$pcn"} = $accs{$acc};
        # print "\n";
      }
      # print "\n";
#        print join(";",map{map{$_->{'w'}}@{$_}}values(%{$wfh}))."\n";
#        next;
#        foreach $parad (@{$Zaliz::Inflect::paradigms{$wi->[0]->{'s'}}}) {
#          print ":",
#            join("/",
#                 map {
#                   (defined $_->{'к' } ? "(".$_->{'к' }.")" : "").
#                   (defined $_->{'п2'} ? "(".(($_->{'п2'} eq "1")?"в,на":($_->{'п2'})).")" : "").
#                   (defined $_->{'x'} &&
#                    ($_->{'x'} eq "z" && "*" || # "?"
#                     $_->{'x'} eq "p" && "?" || # "??" по словарю-"*"(e.g.*мацы)
#                     $_->{'x'} eq "n" && "-" || # "*"
#                     "")).
#                   Orpho::Accent::accent($_->{'w'},$_->{'a'},"u")
#                 } @{$wfh->{$parad}}
#                );
#        }
    }

    print "w:$w", map ({
      "\t$_" . ($props{$_} ne ":" ? ":".$props{$_} : "")
    } sort(keys %props)), "\n";

  }
}

print "%%\n";
%sufs=reverse(%sufs);
map { print "$_ $sufs{$_}\n" } sort(keys(%sufs));
%accs=reverse(%accs);
map { print "$_ $accs{$_}\n" } sort(keys(%accs));
#  map { print "$sufs{$_} $_\n" } sort(keys(%sufs));
#  map { print "$accs{$_} $_\n" } sort(keys(%accs));

sub diff_str {
  my ($str1, $str2) = @_;
  return length($str1) if length($str2) == 0;
  return length($str2) if length($str1) == 0;
  my $i = 0;
  while (defined(substr($str1,$i,1)) && defined(substr($str2,$i,1)) &&
         substr($str1,$i,1) ne "" && substr($str2,$i,1) ne "" &&
         substr($str1,$i,1) eq substr($str2,$i,1)) { $i++ }
  $i
}









