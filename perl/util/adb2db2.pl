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
    my ($a) = /\t�:([^\t]+)/ ? $1 : "�";
    $t .= ($a =~ /�/) ? "1" : "0";
    $t .= ($a =~ /�/) ? "1" : "0";
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

  $dbh{substr($w,0,$b) || "_"} = $i>128 ? pack("nb8a*",$i,$t,$c) : pack("Cb8a*",$i+128,$t,$c);
}

undef $dbp;
untie %dbh;
