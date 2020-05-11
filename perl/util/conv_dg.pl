#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>

# perl -lne 'pos()-=1, print "$1$2" while (/(.)(.)/g)' zaliz.wf.sort.u.all | sort | uniq -c | sort -nr > digraphs&
# LANG=ru_RU.KOI8-R perl -Mlocale -lne '$h{$1.$2}++, pos()-=1 while (/(.)(.)/g);END{for(sort {$h{$b}<=>$h{$a} or $a cmp $b} keys %h){ print "$h{$_} $_" }}' zaliz.wf.sort.u.all > digraphs&
# head -800 digraphs | LANG=ru_RU.KOI8-R perl -Mlocale conv_dg.pl
# head -860 digraphs | LANG=ru_RU.KOI8-R perl -Mlocale conv_dg.pl

# ×Á!

%ch = (
       # KOI8-R
       'k' => 'ÁÂ×ÇÄÅ£ÖÚÉÊËÌÍÎÏĞÒÓÔÕÆÈÃŞÛİßÙØÜÀÑáâ÷çäå³öúéêëìíîïğòóôõæèãşûıÿùøüàñ',
       # ISO 8859-5
       'i' => 'ĞÑÒÓÔÕñÖ×ØÙÚÛÜİŞßàáâãäåæçèéêëìíîï°±²³´µ¡¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏ',
       # alt (DOS)
       'a' => ' ¡¢£¤¥ñ¦§¨©ª«¬­®¯àáâãäåæçèéêëìíîï€‚ƒ„…ğ†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ',
       # CP1251 (Windows)
       'w' => 'àáâãäå¸æçèéêëìíîïğñòóôõö÷øùúûüışÿÀÁÂÃÄÅ¨ÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞß',
       # Mac-Rus
       'm' => 'àáâãäåŞæçèéêëìíîïğñòóôõö÷øùúûüışß€‚ƒ„…İ†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ',
      );

while (<>) {
  chomp;
  next if /£/;
  if (/(\d+)\s+(\S+)/) {
    my ($c, $k) = ($1, $2);
    for ($k, uc $k#, ucfirst $k
        ) {
      my ($k, $a, $w, $i, $m) = ($_) x keys %ch;
      eval "\$a=~tr/$ch{'k'}/$ch{'a'}/";
      eval "\$w=~tr/$ch{'k'}/$ch{'w'}/";
      eval "\$i=~tr/$ch{'k'}/$ch{'i'}/";
      # eval "\$m=~tr/$ch{'k'}/$ch{'m'}/";
      $hk{$k} = $ha{$a} = $hw{$w} = $hi{$i} = $c;
    }
  }
}

for (sort { $hk{$b} <=> $hk{$a} } keys %hk) {
  print unpack("H*",$_), " ; $_\n" if (!(exists $ha{$_} || exists $hw{$_} || exists $hi{$_}));
}

# for (sort { $hw{$b} <=> $hw{$a} } keys %hw) {
#   print "$_\n" if (!(exists $ha{$_} || exists $hk{$_} || exists $hi{$_}));
# }

# use Data::Dumper;
# print Dumper(\%hk), "\n";
# print Dumper(\%ha), "\n";
