# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

package ADB_File;

my $varkey = 'вар';

my %wordpos;

## get_wi($word) -- return hash of word properties
sub get_wi {
  my $word = shift;
  # map {conv_wi($_)} @{get_word($word)}
  make_variants(map {conv_wi($_)} @{get_word($word)})
}

## make_variants(@wfs) -- split words with variants into different groups
#  return array of pointers to arrays of pointers to hashes
sub make_variants {
  my @wis = @_;
  my $v = -1;
  my (@cres, @res);
  for $wi (@wis) {
    my $vi = $wi->{$varkey};
#      if (@cres && ((defined $vi) ? ($vi == 1) : ($v != 0))) {
    if (@cres && !(defined $vi && $vi == $v + 1)) {
      push @res, [@cres]; @cres = ()
    }
    if (defined $vi) { $v = $vi } else { $v = -1 }
    push @cres, $wi
  }
  if (@cres) { push @res, [@cres] }
  @res
}

=item conv_wi

Convert string of key-value pairs separated by tabs to Perl hash

if key has no value then value is assigned to ":"
if key and value are separated by colon, than value is assigned as string
if key and value are separated by two colons, than value is evaluated
Example: input:  "key1	key2:value2	key3::{a=>[b,c]}"
         output: {key1=>":", key2=>"value2", key3=>{a=>[b,c]}}

=cut

sub conv_wi {
  my %wi;
  foreach (split(/\t/, shift)) {
    if (m(::?)o) {
      $wi{$`} = length($&)-2 && $' || eval $';
      warn "$@ in \"$'\"" if $@;
    } else {
      $wi{$_} = ":"
    }
  }
  \%wi
}

=item get_word

Return array of positions of word

Example: input:  "word"
         output: ???

=cut

sub get_word {
  my $word = shift;
  # load_words() if !defined %wordpos;
  # open (ADBF, $adb_file) or die "$0: cannot open $patch: $!\n";
  # print "!",@{$wordpos{$word}},"\n";
  # my @ret = map { seek (ADBF, $_, 0); chomp($_ = <ADBF>); $_ } @{$wordpos{$word}};
  my $ret = $wordpos{$word};
  # print "!!",@ret,"\n";
  # close (ADBF);
  $ret
}

sub load_words {
  my $adb_file = shift or die "$0: specify database file name: $!\n";
  open (ADBF, "<$adb_file") or die "$0: cannot open $adb_file: $!\n";
  while (<ADBF>) {
    chomp;
    next if /^#/;
    my ($w) = /^с:(\S+)/g;
    warn "Wrong format: $_\n" and next if !$w;
    # push(@{$wordpos{$w}}, (tell(ADBF)-length($_)));
    push(@{$wordpos{$w}}, $_);
    # if ($word eq $w) { $wi = $_; last }
    # $words{$w} = $_;
  }
  close (ADBF);
}

1;
