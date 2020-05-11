#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# echo -e "проба\nперл" | perl priparad.pl
# perl -lne '($w)=/^w:([^\t]+)/;print /\tb:([^\t]+)/&&substr($w,0,$1)||$w' rus.adb | uniq | perl priparad.pl > rus.parad.all &
# perl -lne '($w)=/^w:([^\t]+)/;print /\tb:([^\t]+)/&&substr($w,0,$1)||$w' rus.adb | uniq | perl priparad.pl &

use strict;
use DB_File;
use IO::File;

use vars qw($adbfilename $suffilename $adbp $sufp %adbh %sufh %fhh);

my $adbfilename = "rus.db";
my $suffilename = "russuf.db";

# Enable duplicate records
$DB_BTREE->{'flags'} = R_DUP;

$adbp = tie %adbh, "DB_File", $adbfilename, O_RDONLY, 0640, $DB_BTREE 
    or warn "Cannot open $adbfilename: $!\n" and exit(1);

$sufp = tie %sufh, "DB_File", $suffilename, O_RDONLY, 0640, $DB_BTREE 
    or warn "Cannot open $suffilename: $!\n" and exit(2);

my $prevl = "";

while (<>) {
  chomp;
  my $w = $_;
  my $l = substr($w,0,1);
  if ($l ne $prevl) {
    if (!defined $fhh{$l}) {
      $fhh{$l} = new IO::File;
      open($fhh{$l}, ">rus.parad.$l") or warn "rus.parad.$l: $!" and exit(3);
    };
    # sysseek($fhh{$l}, 0, 1);
    $prevl = $l;
  }
  foreach my $i ($adbp->get_dup($w)) {
    $i and do {
      my ($j,$wi);
      map {
        $j++; $wi = $_ if $j == 1; # TODO: main form may be with "#": "чаевые:чаевой#"
        map {
          # TODO: ignore "(.*)" && "[.*]"
          s/[\*\?]$//; print {$fhh{$l}} "$w$_:$w$wi\n" if !/[-\#]$/;
        } $_ ? split(/,/,$_,-1) : ($_);
      } split(/;/,$sufh{$i},-1)}
    or print {$fhh{$l}} "$w\n";
  }
}

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

undef $sufp;
untie %sufh;
undef $adbp;
untie %adbh;
