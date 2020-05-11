#!/usr/bin/perl -w
# -*- Perl -*-
# $Id$

# cat /home/juri/media/audio/voice/ETA/000721a.trs | perl rus_split.pl | /home/work/nlp/morfo/fsa/fsa/s_fsa/fsa_morph -d /home/work/ling/rus/morfo/zaliz/perl/conv/z.fsm -l /home/juri/ling/rus/morfo/fsa/ru.lang | perl rus_join.pl

my $u = "áâ÷çäå³öúéêëìíîïğòóôõæèãşûıøùÿüàñ";
my $l = "ÁÂ×ÇÄÅ£ÖÚÉÊËÌÍÎÏĞÒÓÔÕÆÈÃŞÛİØÙßÜÀÑ";

while (<>) {
  chomp;
  # "tr/$u/$l/" is equal to "lc" with Russian locale
  # print join("\n", map { tr/$u/$l/; $_ } split(/([$u$l-]+)/)), "\n\\n\n";
  print join("\n", split(/([$u$l-]+)/)), "\n\\n\n";
}
