#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# perl suf2db2.pl rus.suf

# use this instead of suf2hash.pl

use strict;
use DB_File;

use vars qw($dbfns $dbfni $dbfno $dbsp $dbip $dbop %dbsh %dbih %dboh %sufs $pns);

my $dbfns = "russuf.db";
my $dbfni = "russufi.db";
my $dbfno = "russufo.db";

# Enable duplicate records
$DB_BTREE->{'flags'} = R_DUP;

$dbsp = tie %dbsh, "DB_File", $dbfns, O_RDWR|O_CREAT, 0640, $DB_BTREE
    or warn "Cannot open $dbfns: $!\n" and exit(1);

$dbip = tie %dbih, "DB_File", $dbfni, O_RDWR|O_CREAT, 0640, $DB_BTREE
    or warn "Cannot open $dbfni: $!\n" and exit(2);

$dbop = tie %dboh, "DB_File", $dbfno, O_RDWR|O_CREAT, 0640, $DB_BTREE
    or warn "Cannot open $dbfno: $!\n" and exit(3);

my ($pns) = (0);

#open(SUFS,">russ.suf") or warn "Cannot open russ.suf: $!\n" and exit(4);
#open(SUFI,">rusi.suf") or warn "Cannot open rusi.suf: $!\n" and exit(5);
#open(SUFO,">ruso.suf") or warn "Cannot open ruso.suf: $!\n" and exit(6);

while (<>) {
  chomp;
  my ($n, $c, $p) = split /\t/;
  # $dbh{$n} = $p;

  my $i = 0;
  $dbsh{$n} = 
#print SUFS "\$dbsh{$n} = ",
   (join ";", map {
    $i++;
    join ",", map {
      if ($_ ne "-") {
        # $_ = "_" if !$_;
        (my $s = $_ || "_") =~ (s/[\(\[*?&].*$//);
        $dbih{$s} = "$n:$i";
        # print SUFI "\$dbih{$_} = \"$n:$i\"\n"; 
        if (!defined $sufs{$_}) { $sufs{$_} = ($pns==12&&++$pns,++$pns) }
        "$sufs{$_}"
      } else { "-" }
    } ($_ ? split(/,/,$_,-1) : ($_));
  } (split(/;/,$p,-1)))
#,"\n";
}
map { $dboh{$sufs{$_}} = $_; } (keys(%sufs));
#map { print SUFO "\$dboh{$sufs{$_}} = $_\n"; } (keys(%sufs));

undef $dbsp;
untie %dbsh;
undef $dbip;
untie %dbih;
undef $dbop;
untie %dboh;


