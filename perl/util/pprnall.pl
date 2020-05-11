#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# pprnall.pl - print all forms of all words

# perl pprnall.pl rus.adb
# cat rus.adb | perl pprnall.pl | perl /home/work/nlp/morfo/fsa/fsa/s_fsa/morph_data.pl | sort -u | /home/work/nlp/morfo/fsa/fsa/s_fsa/fsa_build > z.fsm
# echo "" | /home/work/nlp/morfo/fsa/fsa/s_fsa/fsa_prefix -d z.fsm | sed -e 's/^: //g' -e 's/^ //g' -e 's/\+.*//g' | sort -u | /home/work/nlp/morfo/fsa/fsa/s_fsa/fsa_build > z.fsa
# BAD: cat z.lst | sort -u | /home/work/nlp/morfo/fsa/fsa/s_fsa/fsa_build > z.fsa

use strict;
use vars qw(%sufs %accs);

my ($pns, $pna) = (0, 0);

# open(ADB,"<rus.adb") or warn "Cannot open rus.adb: $!\n" and exit(1);
open(SUF,"<rus.suf") or warn "Cannot open rus.suf: $!\n" and exit(2);
open(ACC,"<rus.acc") or warn "Cannot open rus.acc: $!\n" and exit(3);

while (<SUF>) {
  chomp;
  my ($n, $c, $p) = split /\t/;
  $sufs{$n} = $p;
}

# use Data::Dumper;

while (<ACC>) {
  chomp;
  my ($n, $c, $p) = split /\t/;
#   if ($n == 2) { print Dumper([map {[split(/,/,$_,-1)]} split(/;/,$p,-1)]),"\n"; }
  $accs{$n} = [map {[map { make_accent($_) if !/[-\#]$/ } split(/,/,$_,-1)]} split(/;/,$p,-1)];
}

while (<>) {
  chomp;
  my ($w) = /^w:([^\t]+)/;
  my ($a) = /\ta:([^\t]+)/ ? $1 : 0;
  my ($b) = /\tb:([^\t]+)/ ? $1 : length($w);
  my ($i) = /\ti:([^\t]+)/ ? $1 : 0;
  my ($j) = /\tj:([^\t]+)/ ? $1 : 0;
  my ($t) = "";

  my ($s) = /\ts:([^\t]+)/ ? $1 : "";
  if ($s eq "�") {
    $t .= "1";
    my ($g) = /\t�:([^\t]+)/ ? $1 : "";
    if ($g eq "�") {
      $t .= "000";
    } else {
      $t .= ($g =~ /�/) ? "1" : "0";
      $t .= ($g =~ /�/) ? "1" : "0";
      $t .= ($g =~ /�/) ? "1" : "0";
    }
    my ($o) = /\t�:([^\t]+)/ ? $1 : "�";
    $t .= ($o =~ /�/) ? "1" : "0";
    $t .= ($o =~ /�/) ? "1" : "0";
    $t .= (/\t��/) ? "1" : "0";
    $t .= "0";                  # NOT USED
  } else {
    $t .= "0";
    if ($s eq "�") {
      $t .= "1";
      my ($v) = /\t��:([^\t]+)/ ? $1 : "";
      $t .= ($v =~ /^��/) ? "1" : "0";
      $t .= ($v =~ /���/) ? "1" : "0";
      $t .= (/\t��:�/) ? "1" : "0";
      $t .= (/\t���/) ? "1" : "0";
      $t .= (/\t���/) ? "1" : "0";
      $t .= "0";                # NOT USED
    } else {
      $t .= "0";
      if ($s eq "�") {
        $t .= "10000";
      } elsif ($s eq "��-�") {  # ������������ ��������������
        $t .= "11000";
      } elsif ($s eq "����-�") {
        $t .= "10100";
      } elsif ($s eq "��") {
        $t .= "10010";
      } elsif ($s eq "����") {
        $t .= "10001";
      } elsif ($s eq "�����") {
        $t .= "00100";
      } elsif ($s eq "����") {
        $t .= "00010";
      } elsif ($s eq "������") {
        $t .= "00110";
      } elsif ($s eq "�����") {
        $t .= "00001";
      } elsif ($s eq "����") {
        $t .= "00101";
      } elsif ($s eq "����") {
        $t .= "00011";
      } elsif ($s eq "�") {
        $t .= "00111";
      } elsif ($s eq "�����") {
        $t .= "01000";
      } else {
        $t .= "00000";
      }
      $t .= "0";                # NOT USED
    }
  }

  my ($c) = /\t�:([^\t]+)/ ? $1 : "";

  my $wb = substr($w,0,$b);
  # my $tags = $i>128 ? pack("nb8a*",$i,$t,$c) : pack("Cb8a*",$i+128,$t,$c);
  my $tags = unpack("C",pack("b8",$t))+32;

  if ($i) {
    my $wfn = 0;
    map {
      my $wfnv = 0;
      map {
        # TODO: ignore "(.*)" && "[.*]"
        s/[\*\?]$//;
        if (!/[-\#]$/) {
          # printf("$wb$_\t$w\t%c%c%s\n",$tags,$wfn+49,$accs{$j}[$wfn][$wfnv]);
          printf("$wb$_\t$w\t%s\n",$accs{$j}[$wfn][$wfnv]);
        }
        $wfnv++;
      } $_ ? split(/,/,$_,-1) : ($_);
      $wfn++;
    } split(/;/,$sufs{$i},-1)
  } else {
    # printf("$w\t$w\t%c0%s\n",$tags,make_accent($a));
    printf("$w\t$w\t%s\n",make_accent($a));
  }
}

sub make_accent {
  join("", map { sprintf("%c",$_+64) } split(/\./,shift,-1))
}
