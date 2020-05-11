#!/usr/bin/perl -w
# -*- mode: perl -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# License: GNU GPL 2 (see the file README)

# LANG=ru_RU.KOI8-R perl -Mlocale txt2rev.pl zaliz.txt > zaliz.rev
# alternative:
# perl -lpe '($a,$b)=split(/ /,$_,2);$_=reverse($a)." $b"' zaliz.txt | LANG=ru_RU.KOI8-R sort -s -t " " -k 1,1 | perl -ple '($a,$b)=split(/ /,$_,2);$_=reverse($a)." $b"' > zaliz.rev

use POSIX qw(locale_h strftime);
my $CURDATE = strftime('%Y-%m-%d', localtime);
my $PROGRAM = ($0 =~ /([^\/]*)$/)[0];
my $VERSION = "0.0.1";

print <<HERE;
# -*- mode: text; coding: cyrillic-koi8; -*-
# $CURDATE $PROGRAM v$VERSION http://jurta.org/ru/nlp/rus/zaliz
HERE

my %h;
while (<>) {
  next if /^#/;
  if (/^(\S+)/) {
    $h{reverse($1)} .= $_;
  } else {
    print $_;
  }
}

for (sort keys %h) {
    print $h{$_};
}
