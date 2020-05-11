#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id: adb2db2.pl,v 1.1 2001/03/17 17:32:02 juri Exp $
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# perl adb2db2.pl rus.adb

use strict;
use DB_File;

use vars qw($dbfn $dbp %dbh);

my $dbfn = "rus.db";

# Enable duplicate records
$DB_BTREE->{'flags'} = R_DUP;

$dbp = tie %dbh, "DB_File", $dbfn, O_RDWR|O_CREAT, 0640, $DB_BTREE
    or warn "Cannot open $dbfn: $!\n" and exit(1);

while (<>) {
  chomp;
  my ($w) = /^w:([^\t]+)/;
  my ($b) = /\tb:([^\t]+)/ ? $1 : length($w);
  my ($i) = /\ti:([^\t]+)/ ? $1 : 0;
  my ($t) = "";

  my ($s) = /\ts:([^\t]+)/ ? $1 : "";
  if ($s eq "с") {
    $t .= "1";
    my ($g) = /\tр:([^\t]+)/ ? $1 : "";
    if ($g eq "о") {
      $t .= "000";
    } else {
      $t .= ($g =~ /м/) ? "1" : "0";
      $t .= ($g =~ /ж/) ? "1" : "0";
      $t .= ($g =~ /с/) ? "1" : "0";
    }
    my ($a) = /\tо:([^\t]+)/ ? $1 : "н";
    $t .= ($a =~ /н/) ? "1" : "0";
    $t .= ($a =~ /о/) ? "1" : "0";
    $t .= (/\tмн/) ? "1" : "0";
    $t .= "0";                  # NOT USED
  } else {
    $t .= "0";
    if ($s eq "г") {
      $t .= "1";
      my ($v) = /\tгв:([^\t]+)/ ? $1 : "";
      $t .= ($v =~ /^св/) ? "1" : "0";
      $t .= ($v =~ /нсв/) ? "1" : "0";
      $t .= (/\tгп:п/) ? "1" : "0";
      $t .= (/\tгбл/) ? "1" : "0";
      $t .= (/\tгмн/) ? "1" : "0";
      $t .= "0";                # NOT USED
    } else {
      $t .= "0";
      if ($s eq "п") {
        $t .= "10000";
      } elsif ($s eq "мс-п") {  # местоименные прилагательное
        $t .= "11000";
      } elsif ($s eq "числ-п") {
        $t .= "10100";
      } elsif ($s eq "мс") {
        $t .= "10010";
      } elsif ($s eq "числ") {
        $t .= "10001";
      } elsif ($s eq "вводн") {
        $t .= "00100";
      } elsif ($s eq "межд") {
        $t .= "00010";
      } elsif ($s eq "предик") {
        $t .= "00110";
      } elsif ($s eq "предл") {
        $t .= "00001";
      } elsif ($s eq "союз") {
        $t .= "00101";
      } elsif ($s eq "част") {
        $t .= "00011";
      } elsif ($s eq "н") {
        $t .= "00111";
      } elsif ($s eq "сравн") {
        $t .= "01000";
      } else {
        $t .= "00000";
      }
      $t .= "0";                # NOT USED
    }
  }

  my ($c) = /\tк:([^\t]+)/ ? $1 : "";

  $dbh{substr($w,0,$b) || "_"} = $i>128 ? pack("nb8a*",$i,$t,$c) : pack("Cb8a*",$i+128,$t,$c);
}

undef $dbp;
untie %dbh;
