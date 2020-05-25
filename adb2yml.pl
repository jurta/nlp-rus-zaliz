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
������: $PROGRAM zaliz.adb zaliz.lst > zaliz.yml 2> zaliz.yml.err
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

my @syntax_order = qw(� �2 �� � �� � �� �� ��� ��� ���);
my %syntax_order = map { $syntax_order[$_] => $_ } 0 .. $#syntax_order;
my @grammar_order = qw(� �1 �2 � �2 �3 ޣ �� ��� �� ��� �� �� �� �2 �2 �2� �� �2�);
my %grammar_order = map { $grammar_order[$_] => $_ } 0 .. $#grammar_order;
my @props_order = qw(� � � �2 �3 �� �� ���� ���� �� � �1 �2 �3 �4 �5 �);
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

      # Make array of one element (wi2paradigm supports more than one element,
      # but for clarity we output separate entries for each variant here)
      my @wihp2 = ($wihp2);
      my $wihp = \@wihp2;
      my ($wi, $wfh) = Lingua::RU::Zaliz::Inflect::wi2paradigm($wihp);

      my %syntax_props = map {
        $_, $wihp->[0]->{$_}
      } grep {/^(�2?|��|��?|�|��|��|���|���|���)$/} keys %{$wihp->[0]};

      my %grammar_props = map {
        $_, $wihp->[0]->{$_}
      } grep {/^(�|�[12]|�[23��]?|���|��[�]?|�[���]|�2|�2[�]?|��|�2�)$/} keys %{$wihp->[0]};

      my %props = map {
        $_, $wihp->[0]->{$_}
      } grep {!/^(�|�|����|���|�2?|��|��?|�|��|��|���|���|���|�|�[12]|�[23��]?|���|��[�]?|�[���]|�2|�2[�]?|��|�2�)$/} keys %{$wihp->[0]};

      if (defined $wfh) {
        # For each accent find minimal wordform root
        my %accents;
        my %freq;

        map {
          map {
            if (length($_->{'�'})) {
              # Add fake vowel "�" to force adding accents even for 1-vowel words
              my $wf = substr(Lingua::RU::Accent::accent($_->{'�'} . "�", $_->{'�'}, "0"), 0, -1);
              my $base = exists($accents{$_->{'�'}}) ? $accents{$_->{'�'}} : $wf;
              while ($wf !~ /^$base/) { $base =~ s/.$// }
              $accents{$_->{'�'}} = $base;
              $freq{$_->{'�'}}++;
            }
          } @{$_}
        } values(%{$wfh});

        my $indexes;
        my $i = 0;
        foreach my $acckey (sort { $freq{$b} <=> $freq{$a} } (keys %accents)) {
          my $base = $accents{$acckey};
          $props{'�'.($i == 0 ? "" : $i)} = $base || '""';
          $indexes{$base} = $i;
          $i++;
        };

        $props{'�'} =
            join(";", map {
              join(",", map {
                my $accent = $_->{'�'};
                my $base = $accents{$accent};
                my $wf = "-";

                if (!length($_->{'�'})) {
                  $wf = "-";
                } else {
                  $wf = $_->{'�'};

                  foreach my $acckey (keys %accents) {
                    my $base = $accents{$acckey};
                    my $word = substr(Lingua::RU::Accent::accent($_->{'�'} . "�", $_->{'�'}, "0"), 0, -1);

                    if ($word =~ /^$base(.*)/) {
                      my $suffix = $1;
                      my $i = $indexes{$base};
                      $wf = ($i == 0 ? "" : $i) . $suffix;
                      last;
                    }
                  }

                  $wf = $wf
                         . (defined $_->{'�'} ? "(".$_->{'�'}.")" : "")
                         . (defined $_->{'�2'} ? "[".(($_->{'�2'} eq "1")?"�,��":($_->{'�2'}))."]" : "")
                         . (defined $_->{'�2'} ? "[]" : "")
                         . (defined $_->{'�'} &&
                            ($_->{'�'} eq "��" && "*" || # ����� �������������� ("X", "!")
                             $_->{'�'} eq "��" && "?" || # ����� ���������������� ("-", "-")
                             $_->{'�'} eq "��" && "-" || # ����� ��� ("[X]", "?")
                             defined $_->{'�'}));
                }
                $wf
              } @{$wfh->{$_}})
            } @{$Lingua::RU::Zaliz::Inflect::paradigms{$wi->[0]->{'�'}}});
      }

      $props{'�'} = "{" . join(", ", map ({
        "$_" . (($syntax_props{$_} ne ":")
                ? (($_ eq '���' && $syntax_props{$_} =~ /[\[:\]]/)
                   ? ': "'.($syntax_props{$_} =~ s/"//g, $syntax_props{$_}).'"'
                   : ": ".($syntax_props{$_}))
                : ": t")
      } sort { $syntax_order{$a} <=> $syntax_order{$b} } (keys %syntax_props))) . "}";

      $props{'�'} = "{" . join(", ", map ({
        "$_" . (($grammar_props{$_} ne ":")
                ? ((($_ eq '��' || $_ eq '��') && $grammar_props{$_} =~ /[\[\]]/)
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
           ? ((($_ eq '�' || $_ eq '�3' || $_ eq '��') && $props{$_} =~ /:/)
              ? ': "'.($props{$_} =~ s/"//g, $props{$_}).'"'
              : ": ".$props{$_})
           : ": t")
        . "\n"
      } sort { $props_order{$a} <=> $props_order{$b} } (keys %props));
    }
  }
}
