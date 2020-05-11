#!/usr/bin/perl -w
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# This file is distributed under the terms of the GNU GPL.

=head1 NAME

  subpatch - apply patch containing substitutions whose order is not important

=head1 SYNOPSIS

  subpatch z.1.subpatch z.2.subpatch < z.orig.txt > z.txt

=head1 DESCRIPTION

  This program applies patches containing substitutions
  (their order is not important)

=cut

# ($progname = $0) =~ s(^.*/)();
# $VERSION = sprintf "%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/;

use POSIX qw(locale_h strftime);
my $CURDATE = strftime('%Y-%m-%d', localtime);
my $PROGRAM = ($0 =~ /([^\/]*)$/)[0];
my $VERSION = "0.0.1";

#  &usage,exit(0) unless @_;

foreach $patch (@ARGV) {
  my $line;
  open (PATCH, $patch) or die "$0: cannot open $patch: $!\n";
  while (<PATCH>) {
    if (/^< /) {
      $line = substr($_, 2);
      $lineh{$line} = "";
    } elsif (/^> /) {
      $lineh{$line} .= substr($_, 2);
    }
  }
  close (PATCH);
}

while (<STDIN>) {
  my $line = $lineh{$_};
  $_ = $line if defined $line;
  next unless length;
  # print "$_";
  print
}

sub usage {
  print "$PROGRAM v$VERSION - description\n";
  print "usage: use MODULE [,SUBS...]\n";
}

=head1 AUTHOR

Juri Linkov <juri@jurta.org>

=head1 COPYRIGHT

Copyright (C) 1999-2003  Juri Linkov

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

=cut

1;
