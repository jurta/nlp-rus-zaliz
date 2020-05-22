#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; perl-indent-level: 2; -*-
# Copyright (C) 2020  Juri Linkov <juri@jurta.org>
# This file is distributed under the terms of the GNU GPL.

# PERL5LIB=. perl adb2yml.pl zaliz.adb zaliz.lst 2> zaliz.yml.err | perl koi8-utf8.pl > zaliz.yml
# head -11111 zaliz.lst | PERL5LIB=. perl adb2yml.pl zaliz.adb 2> zaliz.yml.err | perl koi8-utf8.pl > zaliz.yml
# grep -xf wordlist zaliz.lst | PERL5LIB=. perl adb2yml.pl zaliz.adb 2> zaliz.yml.err | perl koi8-utf8.pl > zaliz.yml

# For sorting Russian words in Perl use Russian collation:
# $ENV{'LANG'} = 'ru_RU.KOI8-R'; use locale;
# or
# LANG=ru_RU.KOI8-R perl -Mlocale adb2yml.pl z.lst

use POSIX qw(locale_h strftime);
my $CURDATE = strftime('%Y-%m-%d', localtime);
my $PROGRAM = ($0 =~ /([^\/]*)$/)[0];
my $VERSION = "0.0.1";

sub usage {
  warn <<HERE;
úÁÐÕÓË: $PROGRAM zaliz.adb zaliz.lst > zaliz.yml 2> zaliz.yml.err
HERE
  exit(9);
}

my $adb_file_I = shift || usage();

use Lingua::RU::Zaliz::Inflect qw(inflect);
use Lingua::RU::Accent;
use ADB_File;

ADB_File::load_words($adb_file_I);

print <<HERE;
# -*- coding: utf-8; -*-
# $CURDATE $PROGRAM v$VERSION http://jurta.org/ru/nlp/rus/zaliz
HERE

my @syntax_order = qw(Ô Ô2 ÍÎ Ò ÒÍ Ï Ç× ÇÐ ÇÍÎ ÇÂÌ ÇÐÒ);
my %syntax_order = map { $syntax_order[$_] => $_ } 0 .. $#syntax_order;
my @grammar_order = qw(É Õ1 Õ2 Þ Þ2 Þ3 Þ£ ÞÏ ÇÐÓ ÏÓ ÏÓÆ ÆÐ ÆÚ ÆÎ Ò2 Ð2 Ð2Æ ÄÏ Ó2Þ);
my %grammar_order = map { $grammar_order[$_] => $_ } 0 .. $#grammar_order;
my @props_order = qw(Ó Ç Ú Ú2 Ú3 ÆË ÆÒ ÇÐÒÓ ÓÌÓÞ ÓÂ Ï Ð);
my %props_order = map { $props_order[$_] => $_ } 0 .. $#props_order;

while (<>) { # (sort (keys (%ADB_File::wordpos)))
  next if /^#/;
  chomp;
  my $w = $_;
  my @wis = ADB_File::get_wi($w);
  my $variants1 = scalar(@wis) > 1;
  my $variant1 = 0;

  print "$w:\n";


  for $wihp1 (@wis) {
    $variant1++;
    my $variants2 = scalar(@{$wihp1}) > 1;
    my $variant2 = 0;

    for $wihp2 (@{$wihp1}) {
      $variant2++;

      my @wihp2 = ($wihp2);
      my $wihp = \@wihp2;
      my ($wi, $wfh) = Lingua::RU::Zaliz::Inflect::wi2paradigm($wihp);

      my %syntax_props = map {
        $_,$wihp->[0]->{$_}
      } grep {/^(Ô2?|ÍÎ|ÒÍ?|Ï|Ç×|ÇÐ|ÇÍÎ|ÇÂÌ|ÇÐÒ)$/} keys %{$wihp->[0]};

      my %grammar_props = map {
        $_,$wihp->[0]->{$_}
      } grep {/^(É|Õ[12]|Þ[23£Ï]?|ÇÐÓ|ÏÓ[Æ]?|Æ[ÐÚÎ]|Ò2|Ð2[Æ]?|ÄÏ|Ó2Þ)$/} keys %{$wihp->[0]};

      my %props = map {
        $_,$wihp->[0]->{$_}
      } grep {!/^(Ó|Õ|ÉÓËÌ|×ÁÒ|Ô2?|ÍÎ|ÒÍ?|Ï|Ç×|ÇÐ|ÇÍÎ|ÇÂÌ|ÇÐÒ|É|Õ[12]|Þ[23£Ï]?|ÇÐÓ|ÏÓ[Æ]?|Æ[ÐÚÎ]|Ò2|Ð2[Æ]?|ÄÏ|Ó2Þ)$/} keys %{$wihp->[0]};

      if (defined $wfh) {
        my $base = $wi->[0]->{'Ó'};

        if ($wi->[0]->{'Õ'} =~ /\./) {
          # multiple accents is too complex case, so just reset base
          $base = "";
        }

        map {
          map {
            if (length($_->{'Ó'})) {
              if ($wi->[0]->{'Õ'} !~ /\./ && $_->{'Õ'} < $wi->[0]->{'Õ'}) {
                $base = substr($base, 0, $_->{'Õ'} - 1);
              }

              while ($_->{'Ó'} !~ /^$base/) { $base =~ s/.$// }
            }
          } @{$_}
        } values(%{$wfh});

        $props{'Ï'} = ($base eq "") ? '""' : Lingua::RU::Accent::accent($base, $wi->[0]->{'Õ'}, "0");
        my $pos = $wi->[0]->{'Ô'};
        $props{'Ð'} =
            join(";", map {
              join(",", map {
                (!(length($_->{'Ó'}))) ? "-" :
                ($_->{'Ó'} =~ /^$base(.*)/) ?
                ($_->{'Õ'} > length($base) ?
                 Lingua::RU::Accent::accent($1, $_->{'Õ'} - length($base), "0") :
                $1).(defined $_->{'Ú'} ? "(".$_->{'Ú'}.")" : "").
                   (defined $_->{'Ð2'} ? "[".(($_->{'Ð2'} eq "1")?"×,ÎÁ":($_->{'Ð2'}))."]" : "").
                   (defined $_->{'Ò2'} ? "[]" : "").
                   (defined $_->{'Æ'} &&
                     ($_->{'Æ'} eq "ÆÚ" && "*" || # ÆÏÒÍÁ ÚÁÔÒÕÄÎÉÔÅÌØÎÁ ("X", "!")
                      $_->{'Æ'} eq "ÆÐ" && "?" || # ÆÏÒÍÁ ÐÒÅÄÐÏÌÏÖÉÔÅÌØÎÁ ("-", "-")
                      $_->{'Æ'} eq "ÆÎ" && "-" || # ÆÏÒÍÙ ÎÅÔ ("[X]", "?")
                      defined $_->{'Æ'})) : $_->{'Ó'}
              } @{$wfh->{$_}})
            } @{$Lingua::RU::Zaliz::Inflect::paradigms{$pos}});
      }

      $props{'Ó'} = "{" . join(", ", map ({
        "$_" . (($syntax_props{$_} ne ":")
                ? (($_ eq 'ÇÐÒ' && $syntax_props{$_} =~ /[\[:\]]/)
                   ? ': "'.($syntax_props{$_} =~ s/"//g, $syntax_props{$_}).'"'
                   : ": ".($syntax_props{$_}))
                : ": t")
      } sort { $syntax_order{$a} <=> $syntax_order{$b} } (keys %syntax_props))) . "}";

      $props{'Ç'} = "{" . join(", ", map ({
        "$_" . (($grammar_props{$_} ne ":")
                ? ((($_ eq 'ÆÎ' || $_ eq 'ÆÚ') && $grammar_props{$_} =~ /[\[\]]/)
                   ? ': "'.$grammar_props{$_}.'"'
                   : ": ".$grammar_props{$_})
                : ": t")
      } sort { $grammar_order{$a} <=> $grammar_order{$b} } (keys %grammar_props))) . "}";

      my $i = 0;
      print map ({
        ($i++ == 0
         ? (!$variants1 && !$variants2
            ? " "
            : ($variants1 && !$variants2
               ? "- "
               : ($variant2 == 1 ? "- - " : "  - ")))
         : ($variants1 && !$variants2 ? "  " : ($variants2 ? "    " : " ")))
        . "$_"
        . (($props{$_} ne ":")
           ? ((($_ eq 'Ú' || $_ eq 'Ú3' || $_ eq 'ÆÒ') && $props{$_} =~ /:/)
              ? ': "'.($props{$_} =~ s/"//g, $props{$_}).'"'
              : ": ".$props{$_})
           : ": t")
        . "\n"
      } sort { $props_order{$a} <=> $props_order{$b} } (keys %props));
    }
  }
}
