#!/usr/bin/perl -w
# -*- Perl -*-
# $Id$
# diff z.tab.old z.tab | perl diffuniq.pl > z.diff2
# similar fun: diff z.tab.old z.tab | grep "^[<>]" z.diff | cut -c 3- | sortnr | grep -v "^ *2"

@lines = <>;

foreach (@lines) {
  if (/^[<>] /) { $lu{substr($_, 2)}++ }
}

foreach (@lines) {
  if (/^[<>] /) {
    $s = ($lu{substr($_, 2)} > 1) ? "-" : "!";
    s/^</<$s/;
    s/^>/$s>/;
  }
  print;
}
