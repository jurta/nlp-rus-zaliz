#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# NOT USED
# perl gen_suff.pl z.prop > z.db 2> z.db.suf
# NB! better to run this on output of test_inflect.pl

# for ispell
# À… :À… :ÀÈ—/À…Ò:ÀÈ¿/À…‡:À… :ÀÈ≈Õ/À…≥Õ:ÀÈ…/À…Â:À…È:À…≥◊:À…ÒÕ:À…È:À…ÒÕ…:À…Ò»
# ->
# 3: ≈ ≈Õ £◊ £Õ …   ¿ — —Õ —Õ… —»
# À…: 3

# for grammar
# À… :À… :ÀÈ—/À…Ò:ÀÈ¿/À…‡:À… :ÀÈ≈Õ/À…≥Õ:ÀÈ…/À…Â:À…È:À…≥◊:À…ÒÕ:À…È:À…ÒÕ…:À…Ò»
# ->
# 3:  :—:¿: :≈Õ/£Õ:…/≈:…:£◊:—Õ:…:—Õ…:—»
# À…: 3

# make format similar to xpm: first part is encodings, second is data

use Zaliz::DB::Prop;
use Zaliz::Inflect qw(inflect);

$| = 1;

while (<>) {
  chomp;
  s/w:(\S+).*$/$1/;
  for $wihp (Zaliz::DB::Prop::get_wi($_)) {
    ($wi, $wfh) = Zaliz::Inflect::wi2paradigm($wihp);
    print $wi->[0]->{'w'};
    if (defined $wfh) {
      foreach $parad (@{$Zaliz::Inflect::paradigms{$wi->[0]->{'s'}}}) {
        print ":",
          join("/",
               map {
                 (defined $_->{'x'} &&
                  ($_->{'x'} eq "z" && "*" || # "?"
                   $_->{'x'} eq "p" && "?" || # "??" –œ ”Ãœ◊¡“¿-"*"(e.g.*Õ¡√Ÿ)
                   $_->{'x'} eq "n" && "-" || # "*"
                   "")).
                 $_->{'w'}
               } @{$wfh->{$parad}}
              );
      }
    }
    print "\n";
  }
}


while (<>) {
  chomp;
  my $wihp = Zaliz::DB::Prop::conv_wi($_);
  ($wi, $wfs) = Zaliz::Inflect::wi2paradigm($wihp);
  if (!defined $wfs) {
    print $wi->{'w'}, ": 0\n";
    next
  }
  $base = $wi->{'w'};
  foreach $wf (values %$wfs) {
    if ((!defined $wf->{'p'}) && 
        (!defined $wf->{'z'}) &&
        (!defined $wf->{'n'})) {
      $i = diff_str($base, $wf->{'w'});
      $base = substr($base, 0, $i);
    }
  }
  $suffixes = join " ", map {s/^$base//;$_} map {$_->{'w'}} values %$wfs;
  if (!defined $suf{$suffixes}) {
    $suf{$suffixes} = ++$sufnr;
  }
  # print "$base: $suffixes\n";
  print "$base: ",$suf{$suffixes},"\n";
}

while (($key,$value) = each %suf) {
  print STDERR "$value:$key\n";
}

print "$_\n";

# from /root/usr/lang/prog/perl/ispell/sq.pl
sub diff_str {
  my ($str1, $str2) = @_;
  my $i = 0;
  while (defined(substr($str1,$i,1)) && defined(substr($str2,$i,1)) &&
         substr($str1,$i,1) ne "" && substr($str2,$i,1) ne "" &&
         substr($str1,$i,1) eq substr($str2,$i,1)) { $i++ }
  $i
}
