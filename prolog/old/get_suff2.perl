#!/usr/bin/perl -w # -*-perl-*-
# perl get_suff2.perl wouts2 |sort -u >wouts3

while (<>) {
  chomp;
  s/\s*\d+\s*//;
  @words = split;
  %seen = ();
  print join(" ", sort(grep(!$seen{$_}++, @words))), "\n";
}
