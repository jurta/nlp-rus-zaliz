# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# NOT USED: replaced by ADB.pm

package Zaliz::DB::Prop;

$DBfilename = 'z.prop';
#  %wordpos = ();

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
    my $vi = $wi->{'v'};
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

if prop and value are separated by colon, than value is used as string
if prop and value are separated by two colons, than value is evaluated
Example: input:  prop1	prop2:value2	prop3::{a=>[b,c]}
         output: {prop1=>1,prop2=>"value2",prop3=>{a=>[b,c]}}

=cut

sub conv_wi {
  # my $wi = shift;
  # my ($w, @r) = split(/\t/, $wi);
  my %wi;
  # $wi{w} = $w;
  # foreach (@r) {
  foreach (split(/\t/, shift)) {
    if (m(::?)o) { $wi{$`} = length($&)-2 && $' || eval $'; warn "$@ in \"$'\"" if $@; }
    else { $wi{$_} = ":" } # { $wi{$_} = 1 }
  }
  \%wi
}

sub get_word {
  my $word = shift;
  if (!defined %wordpos) {
    load_words();
  }
  # open (DBF, $DBfilename) or die "$0: cannot open $patch: $!\n";
  # print "!",@{$wordpos{$word}},"\n";
  # my @ret = map { seek (DBF, $_, 0); chomp($_ = <DBF>); $_ } @{$wordpos{$word}};
  my $ret = $wordpos{$word};
  # print "!!",@ret,"\n";
  # close (DBF);
  $ret
}

sub load_words {
  open (DBF, $DBfilename) or die "$0: cannot open $patch: $!\n";
  while (<DBF>) {
    chomp;
    my ($w) = /^w:(\S+)/g;
    # push(@{$wordpos{$w}}, (tell(DBF)-length($_)));
    push(@{$wordpos{$w}}, $_);
    # if ($word eq $w) { $wi = $_; last }
    # $words{$w} = $_;
  }
  close (DBF);
}

1;
