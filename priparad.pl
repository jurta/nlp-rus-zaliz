#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# This file is distributed under the terms of the GNU GPL.

# priparad.pl - PRInt PARADigms

# perl priparad.pl -html zaliz2.adb zaliz2.suf zaliz2.acc > zaliz2.parad.all
# echo "аэрофотосъёмка" | perl priparad.pl -full zaliz3.adb zaliz3.suf zaliz3.acc > zaliz3.parad
# cat zaliz.lst | grep "тигать|тигнуть|тичь" | perl priparad.pl -adb zaliz2.adb zaliz2.suf zaliz2.acc > zaliz2.parad

use strict;
use vars qw(%sufs %accs);

use Lingua::RU::Zaliz::Inflect qw(inflect); # for paradigm names
use Lingua::RU::Accent;
use ADB_File;

use POSIX qw(locale_h strftime);
my ($CURDATE) = strftime('%Y-%m-%d', localtime);
my ($PROGRAM) = $0 =~ /([^\/]*)$/;
my ($VERSION) = "0.0.1";

sub usage {
  warn <<HERE;
Запуск: $PROGRAM -type zaliz2.adb zaliz2.suf zaliz2.acc > zaliz2.parad.all
        cat wordlistfile $PROGRAM -type zaliz2.adb zaliz2.suf zaliz2.acc - > zaliz2.parad
        grep "слово" wordlistfile | $PROGRAM -type zaliz2.adb zaliz2.suf zaliz2.acc - > zaliz2.parad.all
        echo "слово" | $PROGRAM -type zaliz2.adb zaliz2.suf zaliz2.acc - > zaliz2.parad.all
где -type = -html, -full, -adb
HERE
  exit(9);
}

my %funs =
  (
   "-full" => \&prifull,
   "-dump" => \&pridump,
   "-wf" => \&priwf,
   "-wfa" => \&priwfa,
   "-hf" => \&prihf,
  );

my $type = shift || usage();
my $fun = $funs{$type} || usage();

my $adb_file = shift || usage();
my $suf_file = shift || usage();
my $acc_file = shift || usage();

open(ADB,"<$adb_file") or warn "Cannot open $adb_file: $!\n" and exit(1);
open(SUF,"<$suf_file") or warn "Cannot open $suf_file: $!\n" and exit(2);
open(ACC,"<$acc_file") or warn "Cannot open $acc_file: $!\n" and exit(3);

while (<SUF>) {
  next if /^#/;
  chomp;
  my ($n, $c, $p) = split /\t/;
  # $sufstrs{$n} = $p;
  $sufs{$n} = [map {[$_ ? split(/,/,$_,-1) : ($_)]} split(/;/,$p,-1)];
}

while (<ACC>) {
  next if /^#/;
  chomp;
  my ($n, $c, $p) = split /\t/;
  # $accstrs{$n} = $p;
  $accs{$n} = [map {[$_ ? split(/,/,$_,-1) : ($_)]} split(/;/,$p,-1)];
}

my @wl;
my %wh;

if (defined $ARGV[0]) { # !eof
  while (<>) {
    next if /^#/;
    chomp;
    push(@wl, $_);
  }
}

if (@wl) {
  # if word list is not empty, then read needed info form adb into word hash
  while (<ADB>) {
    next if /^#/;
    chomp;
    my ($w) = /^с:([^\t]+)/;
    if (grep { $_ eq $w } @wl) {
      push(@{$wh{$w}}, $_);
    }
  }
  for my $w (@wl) {
    for my $wi (@{$wh{$w}}) {
      &$fun(ADB_File::conv_wi($wi));
    }
  }
} else {
  # if word list is empty, then process all words from adb file
  while (<ADB>) {
    next if /^#/;
    chomp;
    &$fun(ADB_File::conv_wi($_));
  }
}

sub pridump {
  print "?", Data::Dumper::Dumper(@_), "\n";
}

sub prifull {
  my ($wih) = @_;
  my ($w, $io, $iu) = ($wih->{'с'}, $wih->{'ио'}, $wih->{'иу'});
  my $wb = substr($w, 0, defined $wih->{'б'} ? $wih->{'б'} : length($w));
  print Lingua::RU::Accent::accent($w,$wih->{'у'},"u"),"\t";
  if ($io) {
    my $wfn = -1; # word form number
    print
      join ";", map {
        my $wfnv = -1; # word form number variant
        ++$wfn;
        join ",", map {
          # if (!/[-\#]$/) { } s/[\*\?]$//; TODO: ignore "(.*)" && "[.*]"
          $_ eq "0" ? "-" :
            Lingua::RU::Accent::accent("$wb$_",$accs{$iu}[$wfn][++$wfnv],"u");
        } @{$_};
      } @{$sufs{$io}};
  }
  print "\n";
}

# priwf - print simple wordform
sub priwf {
  my ($wih) = @_;
  my ($w) = ($wih->{'с'});
  my $wb = substr($w, 0, defined $wih->{'б'} ? $wih->{'б'} : length($w));
  if (defined $wih->{'ио'}) {
    for (@{$sufs{$wih->{'ио'}}}) {
      for (@{$_}) {
        if (!/[-0]$/) {
          s/[\*\?\(\[].*//;
          print "$wb$_","\n";
        }
      }
    }
  } else {
    print "$w\n";
  }
}

# priwfa - print wordform with all information
sub priwfa {
  my ($wih) = @_;
  my ($w, $t, $io, $iu) = ($wih->{'с'}, $wih->{'т'}, $wih->{'ио'}, $wih->{'иу'});
  my $wb = substr($w, 0, defined $wih->{'б'} ? $wih->{'б'} : length($w));
  my $wa = Lingua::RU::Accent::accent("$w",$wih->{'у'},"u");
  if (defined $wih->{'ио'}) {
    my $paradigms = $Lingua::RU::Zaliz::Inflect::paradigms{$t};
    my $wfn = -1; # word form number
    for (@{$sufs{$wih->{'ио'}}}) {
      my $wfnv = -1; # word form number variant
      ++$wfn;
      for (@{$_}) {
        if (!/[-0]$/) {
          s/[\*\?\(\[].*//;
          print Lingua::RU::Accent::accent("$wb$_",$accs{$iu}[$wfn][++$wfnv],"u"), " $wa ", $paradigms->[$wfn], "\n";
        }
      }
    }
  } else {
    print "$wa $wa ",(defined $t?$t:""),"\n";
  }
}

# prihf - print wordforms for homoforms
sub prihf {
  my ($wih) = @_;
  my ($w, $t, $io, $iu) = ($wih->{'с'}, $wih->{'т'}, $wih->{'ио'}, $wih->{'иу'});
  $w =~ tr/ё/е/;
  my $wb = substr($w, 0, defined $wih->{'б'} ? $wih->{'б'} : length($w));
  if (defined $wih->{'ио'}) {
    my $wfn = -1; # word form number
    for ($t eq "г"?@{$sufs{$wih->{'ио'}}}[0..20]:@{$sufs{$wih->{'ио'}}}) { # пропустить причастия
      my $wfnv = -1; # word form number variant
      ++$wfn;
      for (@{$_}) {
        if (!/[-0]$/) {
          s/[\*\?\(\[].*//;
          tr/ё/е/;
          print "$wb$_ $w ($t)\n";
        }
      }
    }
  } else {
    print "$w $w (",(defined $t?$t:""),")\n";
  }
}

# require Data::Dumper if $type eq "dump";
# use Data::Dumper;
# print "?", Data::Dumper::Dumper($sufs{1}), "\n";
