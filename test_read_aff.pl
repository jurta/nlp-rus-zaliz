#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# perl read_aff.pl

$eol = "\$";

open(DIC,"<zaliz.dic");
open(AFF,"<zaliz.aff");

while (<DIC>) {
  chomp;
  my ($base, $p) = split /\t/;
  $dicw{$base} = $p;
}

while (<AFF>) {
  chomp;
  my ($n, $c, $p) = split /\t/;
  my $i = 0;
  map {
    $i++;
    my $j = 0;
# use split(/,/,$_,-1) !!!
#      $_ eq "" && add_suff("",$n,$i,\%dict) ||
#      map { $j++; add_suff($_,$n,$i,\%dict); } split(/,/);
    map { $j++; add_suff($_,$n,$i,\%dict); } $_ ? split(/,/,$_,-1) : ($_);
  } split(/;/,$p,-1);
}

sub add_suff {
  my ($suf, $n, $i, $dic) = @_;
  if ($suf eq "") {
    push(@{$dic->{$eol}}, [$n,$i]);
  } else {
    my ($rest, $first) = ($suf =~ /^(.*)(.)$/);
    # my ($first, $rest) = ($suf =~ /^(.)(.*)$/);
    my %newd;
    if (!defined($dic->{$first})) { $dic->{$first} = \%newd }
    %$dic->{$first} = add_suff($rest,$n,$i,$dic->{$first});
  }
#  my $key = 
#    print "$suf\n";
  $dic
}

sub check_word {
  my ($base, $suff, $dic) = @_;
  return unless ref($dic) eq 'HASH';
  my ($rest, $first) = ($base =~ /^(.*)(.)$/);
  my $key = $dic->{$eol};
  if (defined $key) {
#      print "$base: ", join(",", map { $_->[0]."-".$_->[1] } @{$key}),"\n";
    if (defined $dicw{$base}) {
      print "$base: ", join(",", map { $_->[1] } grep { $_->[0] == $dicw{$base} } @{$key}),"\n";
    }
  }
  if ($base ne "") { check_word($rest,$first.$suff,$dic->{$first}) }
}

check_word("абажурного","",\%dict);
check_word("аккредитованиями","",\%dict);

#  use Data::Dumper;
#  print Dumper(\%dict);

print "%%\n";
pr_dic(0, \%dict);
sub pr_dic {
  my ($level, $dic) = @_;
  return unless ref($dic) eq 'HASH';
  foreach my $key (sort keys %$dic) {
    print ' ' x $level, "$key",
    (($key eq $eol) && join(",", map { $_->[0]."-".$_->[1] } @{$dic->{$key}})),
    "\n";
    pr_dic($level+length($key), %$dic->{$key})
  }
}

gen_c_code(\%dict);
sub gen_c_code {
  my ($dic) = @_;
  return unless ref($dic) eq 'HASH';
  foreach my $key (sort keys %$dic) {
#      print ' ' x $level, "$key";
    print "  if (*p == '$key') {\n";
    print "    if ((errno = dbcp->c_get(dbcp, &key, &data, DB_DUP_NEXT)) != 0)\n";
#      (($key eq $eol) && join(",", map { $_->[0]."-".$_->[1] } @{$dic->{$key}})),
    gen_c_code(%$dic->{$key});
    print "  \n";
    print "  }\n";
  }
  
}





