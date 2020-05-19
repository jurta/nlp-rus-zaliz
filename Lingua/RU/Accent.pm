# -*- mode: Perl; coding: cyrillic-koi8; -*-
# Copyright (c) 2000  Juri Linkov <juri@eta.org>

# Examples:
# move this to Makefile
# perl -F\\t -MLingua::RU::Accent -alne '$F[0]=Lingua::RU::Accent::accent($F[0],$F[1],"u");splice(@F,1,1);print join("\t",@F)' z.tab > z.tab.accented
# for testing:
# perl -MLingua::RU::Accent -e 'print Lingua::RU::Accent::raccent(Lingua::RU::Accent::accent("ÓÅÒÏ-ÂÕÒÏ-ÍÁÌÉÎÏ×ÙÊ","14.7.2,2","u"),"u")'
# for statistics:
# perl -F\\t -MLingua::RU::Accent -alne 'print join("\n",Lingua::RU::Accent::get_accent_letters($F[0],$F[1]));' z.tab | sort | uniq -c | sort -nr > z.tab.accents
# find wrong accented consonants:
# perl -F\\t -MLingua::RU::Accent -alne 'print if(join("",Lingua::RU::Accent::get_accent_letters($F[0],$F[1]))=~/[^ÁÅ£ÉÏÕÙÜÀÑ]/);' z.tab
# perl -I.. -MLingua::RU::Accent -e 'print Lingua::RU::Accent::raccent("ÍåÄÓÅÓÔ³Ò","u")'

package Lingua::RU::Accent;

my $vowel = "ÁÅ£ÉÏÕÙÜÀÑ";
# my $upper_case = "áâ÷çäå³öúéêëìíîïğòóôõæèãşûıøùÿüàñ"; # not used
# my $lower_case = "ÁÂ×ÇÄÅ£ÖÚÉÊËÌÍÎÏĞÒÓÔÕÆÈÃŞÛİØÙßÜÀÑ"; # not used

sub accent {
  my $word = shift;
  my $acc = shift;
  my $acctype = shift;          # 0 or 1 or a or u

  # TODO: try use "use locale RU_RU" and "uc"
  # uc(substr($word,$acc-1,1));
  # substr($word,$acc-1,1) =~ tr/$lower_case/$upper_case/;
  # old: ($acc =~ s/(\d+),\1/\1/)

  return $word if $acc eq "0";
  return $word if $word !~ /[$vowel].*[$vowel]/; # TODO: should be optional

  while ($acc =~ s(,(\d+))()) {
    substr($word,$1-1,1) =~ tr(Å)(£);
  }

  if ($acctype eq "0" or $acctype eq "1") {
#      ($a, @accents) = ($acc =~ /(\d+)/g);
#      if (substr($word,$a-1,1) ne "£") { substr($word,$a-$acctype,0) = "'"; }
#      foreach $a (@accents) { substr($word,$a-$acctype,0) = "`"; }
    my @accents = ($acc =~ /(\d+)/g);
    for (my $i = 0; $i <= $#accents; $i++) {
      next if (length($word) < $accents[$i]);
      next if (substr($word,$accents[$i]-1,1) eq "£");
      substr($word,$accents[$i]-$acctype,0) = ($i==0) ? "'" : "`";
    }
  } elsif ($acctype eq "a") {
    while ($acc =~ /(\d+)/g) {
      (length($word) >= $1) && (substr($word,$1-1,1) =~ tr/ÁÅ£ÉÏÕÙÜÀÑ/ˆŠ‘–šœ /)
    }
  } elsif ($acctype eq "u") {
    while ($acc =~ /(\d+)/g) {
      (length($word) >= $1) && (substr($word,$1-1,1) =~ tr(ÁÅ£ÉÏÕÙÜÀÑ)(áå³éïõùüàñ))
    }
  }
  $word
}

# raccent - reversed accent

sub raccent {
  my $word = shift;
  my $acctype = shift;   # 0 or 1 or a or u
  my $rword = reverse $word;

  if ($acctype eq "u") {
    my $acc = "0";         # by default
    if (($word !~ m([áå³£éïõùüàñ])) && ($word =~ m([ÁÅ£ÉÏÕÙÜÀÑ]))) {
      return length($`) + 1
    }

    while ($rword =~ m([áå³£éïõùüàñ])g) {
      my $accn = length($word) - length($`);
      $acc .= "." . $accn;
      substr($word,$accn-1,1) =~ tr(áå³éïõùüàñ)(ÁÅ£ÉÏÕÙÜÀÑ);
    }
    $rword = reverse $word;
    while ($rword =~ m(£)g) {
      my $accn = length($word) - length($`);
      $acc .= "," . $accn;
      substr($word,$accn-1,1) =~ tr(£)(Å);
    }
    $acc =~ s(^0?\.)();
    $acc
  } else {
    my $accent = "'";
    if ($word !~ m([£$accent])) {
      if ($word =~ m([$vowel])) {
        return [$word, length($`) + 1, $word, length($`) + 1];
      } else {
        return [$word, 0, $word, 0];
      }
    }

    my @parts = split(/([£$accent])/, $word);
    my ($acc, $word1, $word2, $wacc1, $wacc2) = (0, "", "", "", "");
    foreach my $part (@parts) {
      if ($part eq "£") {
        $acc++;
        $word1 .= "£";
        $word2 .= "Å";
        $wacc1 = ".$acc" . $wacc1;
        $wacc2 = ",$acc" . $wacc2;
      } elsif ($part eq $accent) {
        $wacc1 = ".$acc" . $wacc1;
      } else {
        $acc += length($part);
        $word1 .= $part;
        $word2 .= $part;
      }
    }
    $wacc1 =~ s(^\.)();
    return [$word1, $wacc1, $word2, $wacc1.$wacc2];
  }
}

sub get_accent_letters {
  my $word = shift;
  my $acc = shift;
  my @retacc = ();

  return if $acc eq "0";

  while ($acc =~ s(,(\d+))()) {
    substr($word,$1-1,1) =~ tr/Å/£/;
  }
  while ($acc =~ m((\d+))g) {
    push @retacc, substr($word,$1-1,1);
  }
  @retacc;
}

# isplit returns array of beginning positions of splitted fields
# perl -MLingua::RU::Accent -e 'print join(":",Lingua::RU::Accent::isplit(" +","a b  c   d    e"))'
sub isplit {
  my $pattern = shift;
  my $expr = shift;
  my @res;
  while ($expr =~ /$pattern/g) { push @res, length($`)+length($&); }
  @res
}

1;
