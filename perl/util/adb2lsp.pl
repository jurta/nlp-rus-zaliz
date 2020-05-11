#!/usr/bin/perl -w
# -*- Perl -*-
# $Revision$

# perl adb2lsp.pl z.adb > z.lsp

while (<>) {
  chomp;
  next if /^#/;
  print "(", join " ", (map {
    /^([^:]+):(.*)/&&"($1 \"$2\")"
  } split/\t/), ")\n";
}
