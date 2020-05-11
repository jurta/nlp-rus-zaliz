#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# Usage: perl tab2pl.pl z.tab > z.pl 2> z.pl.err

print ":-module(z0,[]).\n";
#  print ":-module(z0,[w/4]).\n";

while (<>) {
  chomp;

  ($w,$a,$pos,$idx,@plm) = split(/\t/);

  $ac = $a;
  while ($ac =~ s(,(\d+))()) {
    $ac =~ s(\b($1)\b)(e($1));
  }
  if ($ac =~ s(\.)(,)g) {
    $ac = "a($ac)";             # this should be: "[$ac]"
  }

  $idx =~ s/(\d+)(.+)/$1,$2/;
  $idx = "i($idx)";

  @plm = map {
    if (/^[pzn]/) {
      $_ = join(",", map {
        if (/[-]/) { $_ = $`.$&.join(",",split(/ */,$')); }
        s(-(.+))(($1))g;
        s([.])(_)g;
        $_
      } split(/[|]/));
      s(:(.+))(:[$1]);
    }
    s(\')(\'\'), s(:(.+))(:'$1') if (/^c/);
    s(:(.+))(($1));
    s/^Ð2(Æ?)$/Ð2$1(_)/;
    $_
  } @plm;

  $plm = join(",", @plm);
  if ($plm ne "") { $idx = "[$idx,$plm]" }

  if ($w   =~ /-/) { $w   = "'$w'"   }
  if ($pos =~ /-/) { $pos = "'$pos'" }

  print "w($w,$ac,$pos,$idx).\n";
}
