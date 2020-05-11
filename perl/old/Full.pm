# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

package Zaliz::DB::Full;

$DBfilename = '/root/usr/lang/rus/zaliz/perl/z.full';
#  %wordpos = ();

## get_wi($word) -- return hash of word properties
sub get_wi {
  my $word = shift;
  map {conv_wi($_)} @{get_word($word)}
}

sub conv_wi {
  my $wi = shift;
  my ($w, $a, @r) = split(/\t/, $wi);
  my %wi;
  $wi{w} = $w;
  $wi{a} = $a;
  foreach (@r) {
    if (/:/) { $wi{$`} = $' }
    else { $wi{$_} = 1 }
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
    my ($w) = /^(\S+)/g;
    # push(@{$wordpos{$w}}, (tell(DBF)-length($_)));
    push(@{$wordpos{$w}}, $_);
    # if ($word eq $w) { $wi = $_; last }
    # $words{$w} = $_;
  }
  close (DBF);
}

1;
