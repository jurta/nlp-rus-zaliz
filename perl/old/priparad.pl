#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# echo -e "проба\nперл" | perl priparad.pl

use strict;
use DB_File;

use vars qw($dbafn $dbfns $dbfni $dbfno $dbap $dbsp $dbip $dbop %dbah %dbsh %dbih %dboh);

$| = 1; # TRY

my $dbafn = "rus.db";
my $dbsfn = "russuf.db";
my $dbifn = "russufi.db";
my $dbofn = "russufo.db";

# Enable duplicate records
$DB_BTREE->{'flags'} = R_DUP;

$dbap = tie %dbah, "DB_File", $dbafn, O_RDONLY, 0640, $DB_BTREE
    or warn "Cannot open $dbafn: $!\n" and exit(1);

$dbsp = tie %dbsh, "DB_File", $dbsfn, O_RDONLY, 0640, $DB_BTREE
    or warn "Cannot open $dbsfn: $!\n" and exit(2);

$dbip = tie %dbih, "DB_File", $dbifn, O_RDONLY, 0640, $DB_BTREE
    or warn "Cannot open $dbifn: $!\n" and exit(3);

$dbop = tie %dboh, "DB_File", $dbofn, O_RDONLY, 0640, $DB_BTREE
    or warn "Cannot open $dbofn: $!\n" and exit(4);

while (<>) {
  chomp;
  my $w = $b = $_;
  my $s = "";

  print "$w\n";

  foreach ($dbap->get_dup($w)) {
    my ($na,$t,$c) = unpack("B", $_) ? unpack("CB8a*", $_) - 128 : unpack("nB8a*", $_);
    if ($na == 0) { print "  $w 0 ($t,$c)\n"; }
  }

  for (1 .. (length $w) + 1) {
    # print "?",join("/",$dbip->get_dup($s||"_")),"\n";
    my @bases = ($dbap->get_dup($b||"_"));
    foreach ($dbip->get_dup($s||"_")) {
      my ($n,$i) = (split/:/);
      # print "!",join("/",$dbap->get_dup($b||"_")),"\n";
      foreach (@bases) {
        my $wi = $_;
        my ($na,$t,$c) = unpack("B", $wi) ? unpack("CB8a*", $wi) - 128 : unpack("nB8a*", $wi);
        if ($n == $na) {
          my (@parads) = (split(/;/,$dbsh{$n}));
          my ($wfi, $wfo) = ($parads[0], $parads[$i-1]);
          if ($wfi eq "-") { $wfi = $parads[6]; }
          print "  $b$dboh{$wfi} -> $i ",join(",",map{"$b$dboh{$_}"}split(/,/,$wfo,-1))," ($t,$c)\n";
          priparad($b,$wi);
        }
      }
    }
    ($b =~ s/.$//) && ($s = "$&$s");
  }
}

sub priparad {
  my ($b,$wi) = @_;
  my ($n,$t,$c) = unpack("B", $wi) ? unpack("CB8a*", $wi) - 128 : unpack("nB8a*", $wi);
  
  map {
    (/^-$/) ? print "  -\n" :
    print "  ",join(",", map{ "$b$dboh{$_}" } split(/,/,$_,-1))," ($t,$c)\n";
  } (split(/;/,$dbsh{$n}));
}

undef $dbap;
untie %dbah;
undef $dbsp;
untie %dbsh;
undef $dbip;
untie %dbih;
undef $dbop;
untie %dboh;

#    foreach ($dbap->get_dup($w)) {
#      $i and do {
#        my ($j,$wi);
#        map {
#          $j++; $wi = $_ if $j == 1; # TODO: main form may be with "#": "чаевые:чаевой#"
#          map {
#            # TODO: ignore "(.*)" && "[.*]"
#            s/[\*\?]$//; print {$fhh{$l}} "$w$_:$w$wi\n" if !/[-\#]$/;
#          } $_ ? split(/,/,$_,-1) : ($_);
#        } split(/;/,$sufh{$i},-1)}
#      or print {$fhh{$l}} "$w\n";
#    }

#  while (<>) {
#    chomp;
#    my $w = $_;
#    my @ilist = $adbp->get_dup($w);
#    foreach $b (@ilist) {
#      my @suf = split /;/, $sufh{$b};
#      if (@suf == 12) {
#        print "Существительное: ";
#        map { print "$w$_ " } @suf;
#        print "\n";
#      }
#    }
#  #    map { print "$_ -> $suf\n" } @list;
#  }





