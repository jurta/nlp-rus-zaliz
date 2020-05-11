#!/usr/bin/perl -w # -*-perl-*-
# head -20 wouts | perl get_suff.perl
# perl get_suff.perl wouts |sort -u >wouts2

while (<>) {
  chomp;
  next if not /: /;
  s/.*: //; s|[?*/x]| |g;
  s/\([^\)]*\)//g;
  @words = split;
#    print "@words\n";
  $base = $words[0];
  foreach $word (@words) {      # FIXME: #@words-1
    my $i = 0;
    for (1..length $word) {
      last if substr($word,$i,1) ne substr($base,$i,1);
      $i++
    }
    $base = substr($base, 0, $i);
  }
#    print "$base\n";
  @suffixes = map {s/^$base//;$_} @words;
  print "@suffixes\n";
}
