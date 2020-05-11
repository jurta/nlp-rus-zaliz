#!/usr/bin/perl -w
# -*- Perl -*-
# $Id$

# cat /home/juri/media/audio/voice/ETA/000721a.trs | perl rus_split.pl | /home/work/nlp/morfo/fsa/fsa/s_fsa/fsa_morph -d /home/work/ling/rus/morfo/zaliz/perl/conv/z.fsm -l /home/juri/ling/rus/morfo/fsa/ru.lang | perl rus_join.pl
# cat /home/juri/media/audio/voice/ETA/000721b.trs | perl rus_split.pl | /home/work/nlp/morfo/fsa/fsa/s_fsa/fsa_morph -d /home/work/ling/rus/morfo/zaliz/perl/conv/z.fsm -l /home/juri/ling/rus/morfo/fsa/ru.lang | perl rus_join.pl
# TODO: add new accent scheme (as in section "áËÃÅÎÔÕÁÃÉÑ" in ling/rus/morfo/zaliz/perl/conv/README) to ling/rus/morfo/zaliz/perl/Orpho/Accent.pm and use it here

my $u = "áâ÷çäå³öúéêëìíîïğòóôõæèãşûıøùÿüàñ";
my $l = "ÁÂ×ÇÄÅ£ÖÚÉÊËÌÍÎÏĞÒÓÔÕÆÈÃŞÛİØÙßÜÀÑ";

while (<>) {
  chomp;
  if (/^.[$u$l-]+: \*not found\*/) {
    # cat /home/juri/media/audio/voice/ETA/000721a.trs | perl rus_split.pl | /home/work/nlp/morfo/fsa/fsa/s_fsa/fsa_morph -d /home/work/ling/rus/morfo/zaliz/perl/conv/z.fsm -l /home/juri/ling/rus/morfo/fsa/ru.lang | perl rus_join.pl > notf
    # cat /home/juri/media/audio/voice/ETA/000721b.trs | perl rus_split.pl | /home/work/nlp/morfo/fsa/fsa/s_fsa/fsa_morph -d /home/work/ling/rus/morfo/zaliz/perl/conv/z.fsm -l /home/juri/ling/rus/morfo/fsa/ru.lang | perl rus_join.pl >> notf
    # LANG=ru_RU.KOI8-R sort -u <notf >notfs
    # s/: \*not found\*//;
    # print "$_\n";
  }
  s/: \*not found\*//;
#  s/^.*: //; # for accents
  # if (s/:[^+]*\+([\@A-Z]).*// && $1 ne "@")
  if (s/:.*\+([\@A-Z]).*// && $1 ne "@")
  {
    substr($_,ord($1)-64,0) = "'";
  }
  if (/\\n/) {
    print "\n";
  } else {
    print "$_";
  }
}
