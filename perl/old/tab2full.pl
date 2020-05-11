#!/usr/bin/perl -w
# -*- Perl -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# Usage: perl tab2pl.pl z.tab > z.pl 2> z.pl.err

#  use Util;

while (<>) {
  chomp;

  ($w,$a,$pos,$idx,@plm) = split(/\t/);

  $ac = $a;
  ($idx =~ s((\d+)(.+))(i:$1\ta1:$2)
   or $idx =~ s(0)(i:0));
  ($pos =~ s(^([���])$)(pos:�\tg:$1\t�:�)
   or $pos =~ s(^([���])�$)(pos:�\tg:$1\t�:�)
   or $pos =~ s(^(��)$)(pos:�\t��:$1)
   or $pos =~ s(^(���)$)(pos:�\t��:$1)
   or $pos =~ s(^(��-���)$)(pos:�\t��:$1)
   or $pos =~ s(^)(pos:));

  print join("\t",($w,$ac,$pos,$idx,@plm)),"\n";
}
