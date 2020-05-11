#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# This file is distributed under the terms of the GNU GPL.

# perl adb2suf.pl zaliz.adb zaliz2.suf zaliz2.acc zaliz.lst > zaliz2.adb 2> zaliz2.adb.err
# head -11111 zaliz.lst | perl adb2suf.pl zaliz.adb zaliz2.suf zaliz2.acc > zaliz2.adb 2> zaliz2.adb.err
# grep -xf wordlist zaliz.lst | perl adb2suf.pl zaliz.adb zaliz2.suf zaliz2.acc > zaliz2.adb 2> zaliz2.adb.err

# For sorting Russian words in Perl use Russian collation:
# $ENV{'LANG'} = 'ru_RU.KOI8-R'; use locale;
# or
# LANG=ru_RU.KOI8-R perl -Mlocale adb2suf.pl z.lst

use POSIX qw(locale_h strftime);
my $CURDATE = strftime('%Y-%m-%d', localtime);
my $PROGRAM = ($0 =~ /([^\/]*)$/)[0];
my $VERSION = "0.0.1";

sub usage {
  warn <<HERE;
Запуск: $PROGRAM zaliz.adb zaliz2.suf zaliz2.acc zaliz.lst > zaliz2.adb 2> zaliz2.adb.err
HERE
  exit(9);
}

my $adb_file_I = shift || usage();
my $suf_file_O = shift || usage();
my $acc_file_O = shift || usage();

use Lingua::RU::Zaliz::Inflect qw(inflect);
use ADB_File;

ADB_File::load_words($adb_file_I);

open(SUF,">$suf_file_O") or warn "Cannot open $suf_file_O: $!\n" and exit(2);
open(ACC,">$acc_file_O") or warn "Cannot open $acc_file_O: $!\n" and exit(3);

print <<HERE;
# -*- mode: text; coding: cyrillic-koi8; -*-
# $CURDATE $PROGRAM v$VERSION http://jurta.org/ru/nlp/rus/zaliz
HERE

my ($pns, $pna) = (0, 0);

while (<>) { # (sort (keys (%ADB_File::wordpos)))
  next if /^#/;
  chomp;
  my $w = $_;
  for $wihp (ADB_File::get_wi($w)) {
    my ($wi, $wfh) = Lingua::RU::Zaliz::Inflect::wi2paradigm($wihp);

    foreach $ph (@{$wihp}[1..scalar(@{$wihp})-1]) {
      foreach $key (keys %{$ph}) {
        $wihp->[0]->{$key} = $ph->{$key} if !(exists $wihp->[0]->{$key})
      }
    }

    my %props = map {
      $_,$wihp->[0]->{$_}
    } grep {!/^(с|и|у[12]|ос[ф]?|ч[ёо23]?|ф[зпн]|искл|вар)$/} keys %{$wihp->[0]};

    if (defined $wfh) {
      my $base = $wi->[0]->{'с'};
      map {
        map {
          if (length($_->{'с'})) {
            while ($_->{'с'} !~ /^$base/) { $base =~ s/.$// }
          }
        } @{$_}
      } values(%{$wfh});
      $props{'б'} = length($base);
      my $pos = $wi->[0]->{'т'};
      my $suf =
          join(";", map {
            join(",", map {
              (!(length($_->{'с'}))) ? "0" :
              ($_->{'с'} =~ /^$base(.*)/) ?
              $1.(defined $_->{'з'} ? "(".$_->{'з'}.")" : "").
                 (defined $_->{'п2'} ? "[".(($_->{'п2'} eq "1")?"в,на":($_->{'п2'}))."]" : "").
                 (defined $_->{'р2'} ? "[]" : "").
                 (defined $_->{'ф'} &&
                   ($_->{'ф'} eq "фз" && "*" || # форма затруднительна ("X", "!")
                    $_->{'ф'} eq "фп" && "?" || # форма предположительна ("-", "-")
                    $_->{'ф'} eq "фн" && "-" || # формы нет ("[X]", "?")
                    defined $_->{'ф'})) : $_->{'с'}
            } @{$wfh->{$_}})
          } @{$Lingua::RU::Zaliz::Inflect::paradigms{$pos}});
      my $acc =
          join(";", map {
            join(",", map {
              # (defined $_->{'ф'} && $_->{'ф'} eq "фн") ? "$_->{'у'}-" :
              $_->{'у'}
            } @{$wfh->{$_}})
          } @{$Lingua::RU::Zaliz::Inflect::paradigms{$pos}});
      if (!defined $sufs{$suf}) { $sufs{$suf} = ++$pns }
      $pcs{$sufs{$suf}}++;      # pcs - paradigm counter for suffixes
      $props{'ио'} = $sufs{$suf};
      if (!defined $accs{$acc}) { $accs{$acc} = ++$pna }
      $pca{$accs{$acc}}++;      # pca - paradigm counter for accents
      $props{'иу'} = $accs{$acc};
    }
    print "с:$w", map ({
      "\t$_" . ($props{$_} ne ":" ? ":".$props{$_} : "")
    } sort(keys %props)), "\n";
  }
}

print SUF <<HERE;
# -*- mode: text; coding: cyrillic-koi8; -*-
# $CURDATE $PROGRAM v$VERSION http://jurta.org/ru/nlp/rus/zaliz
HERE

map {
  print SUF "$sufs{$_}\t$pcs{$sufs{$_}}\t$_\n"
} sort {
  $pcs{$sufs{$b}} <=> $pcs{$sufs{$a}} || $sufs{$a} <=> $sufs{$b}
} (keys(%sufs));

print ACC <<HERE;
# -*- mode: text; coding: cyrillic-koi8; -*-
# $CURDATE $PROGRAM v$VERSION http://jurta.org/ru/nlp/rus/zaliz
HERE

map {
  print ACC "$accs{$_}\t$pca{$accs{$_}}\t$_\n"
} sort {
  $pca{$accs{$b}} <=> $pca{$accs{$a}} || $accs{$a} <=> $accs{$b}
} (keys(%accs));
