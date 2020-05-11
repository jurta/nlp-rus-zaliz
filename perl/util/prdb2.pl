#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# prdb2.pl - print out DB2 content

# perl prdb2.pl russuf.db > russuf.db.out
# perl prdb2.pl russuf.db 1 > russuf.db.out -- no R_DUP

# but better to use: db_dump -p -f russuf.db.out russuf.db
# with filter: perl -lne 'print pack("H*",$_)'

use strict;
use DB_File;

use vars qw($dbfilename $dbp %dbh);

my $dbfilename = shift or warn "Database file name is not given: $!\n" and exit(1);

# Enable duplicate records
$DB_BTREE->{'flags'} = R_DUP if !defined shift;

$dbp = tie %dbh, "DB_File", $dbfilename, O_RDONLY, 0640, $DB_BTREE
    or warn "Cannot open $dbfilename: $!\n" and exit(2);

foreach (keys (%dbh)) {
  print "$_\t";
  foreach ($dbp->get_dup($_)) { print "$_\t" }
  print "\n";
}

undef $dbp;
untie %dbh;
