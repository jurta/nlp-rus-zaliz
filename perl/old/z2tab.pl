#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# perl z2tab.pl z > z.tab 2> z.tab.err

my $vml = 0; # for multi-line variants

while (<>) {
  chomp;
  my (%props, %zprops, %nprops);
  my ($w, $a, $fr, $fk, $us, $v, $cs, $cm);
  my ($zvs, $zvp);
  my ($nmn);
  my ($vps, $vmn, $vbl);
  my ($chr, $mn, $tip, $ud);
  my ($vt, $chr2, $skl, $idx);
  $o = $_; $an = ""; # $an="н"; # $w=$s=$p=$c="";
  # undef $w; undef $a; undef $fr; undef $c; undef $fk; undef $us;
  # $w=$a=$fr=$c=$fk=$us=$v=$cs=$cm=$do="";

  if (s{(?:(//|=)>|<(=|//))}{}) { $vml++ }
#    if ($vml == 1) { }
#    s|=>||; s|<=||; s|<//||; s|//>||;

  s/\s*$//;

  if (s/^([^\d]+)\s+([\d.,]+)\s+//) { ($w,$a) = ($1,$2) }
  else { print STDERR "? $o\n"; next; }

  $ac = $a;
  
  # фразеологизмы
  if (s/\s*%\s*(.*)$//) { $fr = $1 }
  # морфологически нерегулярные формы
  if (s/\s*@\s*(.*)$//) { print STDERR "@ $o\n" }
  # слово употребляется только в приводимых словосочетаниях
  if (m/:/ && (m/^[^\(\[]*:/ || !m/[\(\[][^\)\]]*:.*[\)\]]/)
     && s/\s*:\s*(.*)$//) { $us = $1 }
  # факультативная часть индекса
  if (s|\[//(.*)\]||) { $fk = $1 }
  # глагол противоположного вида
  if (s/\s*\$\s*(.*)$//) { $v = $1 }
  # указания значения
  if (s/\(_([^\)]*?)_?\)\s*// # &&$1ne"в"&&$1ne"на"   # if(s|\(([^вн][^\)]*)\)||
    ) { $props{'c'} = $1 }
  # указания значения дополнительные
  if (s/\(_([^\)]*?)_?\)\s*// # &&$1ne"в"&&$1ne"на"   # if(s|\(([^вн][^\)]*)\)||
    ) { $props{'c2'} = $1 }
  # сведения о вариантах слова
  if (s/\[_([^\]]+)\]//) { $props{'c3'} = $1 }

  s/^\s*//; s/\s*$//;

  if (s/_Р\. мн\. затрудн\._//) { $zprops{'с-рм'} = 0 }
  if (s/_мн\. затрудн\._//) { $zprops{'с-.м'} = 0 }
  if (s/_кф м и ж затрудн\._//) { $zprops{'пк-.м'} = 0; $zprops{'пк-.ж'} = 0 }
  if (s/_кф м затрудн\._//) { $zprops{'пк-.м'} = 0 }
  if (s/_кф ж затрудн\._//) { $zprops{'пк-.ж'} = 0 }
  if (s/_сравн\. затрудн\._//) { $zprops{'пс-с'} = 0 }
  if (s/_кф и сравн\. затрудн\._//) { $zprops{'пк-..'} = 0; $zprops{'пс-с'} = 0 }
  if (s/_косв\. формы затрудн\._//) { $zprops{'с-..'} = 0 }
  if (s/_повел\. затрудн\._//) { $zprops{'гп-.'} = 0 }
  if (s/_деепр\. затрудн\._//) { $zprops{'гд-.'} = 0 }
  if (s/_наст\. 1 ед\. затрудн\._//) { $zprops{'г-н1е'} = 0 }
  if (s/_буд\. 1 ед\. затрудн\._//) { $zprops{'г-б1е'} = 0 }

  if (s/_Р\. мн\. нет_//) { $nprops{'с-рм'} = 0 }
  if (s/_кф м нет_//) { $nprops{'пк-.м'} = 0 }
  if (s/_пф нет_//) { $nprops{'пс-п'} = 0 }
  if (s/_прич\. прош\. нет_//) { $nprops{'гп-п.'} = 0 }
  if (s/_страд\. нет_//) { $nprops{'гп-.с'} = 0 }
  if (s/_буд\. нет_//) { $nprops{'г-б..'} = 0 }
  if (s/_буд\. 1 ед\. нет_//) { $nprops{'г-б1е'} = 0 }

  if (s/_прич\. страд\._ -(.+)-//) { $vps = ($1 or "") }
  if (s/,\s*многокр\.//) { $vmn = 1 }
  if (s/,\s*безл\.//) { $vbl = 1 }

  # множественное число
  if (s/^мн\.\s*(_от_|неод\.|одуш\.)?\s*//) { $mn = ($1 or "") }

  # дополнительные особенности в склонении
  if (s/(?:,)?\s*\#(\d+)\s*//) { $props{'до'} = $1 }
  # факультативные отклонения от стандартного склонения
  if (s/\[((?:"\d+")+)\]//) {
    # "1""2" -> осф("1""2") ??? -> осф([1,2])
    my $osf = $1; $osf =~ s/""/,/g;  $osf =~ s/\"//g; $osf = "[$osf]";
    $props{'осф'} = $osf;
  }
  # отклонения от стандартного склонения
  if (s/((?:"\d+")+)//) {
    # "1""2" -> ос("1""2") ??? -> ос([1,2])
    my $os = $1; $os =~ s/""/,/g;  $os =~ s/\"//g; $os = "[$os]";
    $props{'ос'} = $os;
  }
  # чередование ё/е
  if (s/,\s*Ё\s*//) { $props{'чё'} = 0 }
  # чередование о/е
  if (s/,\s*о\s*//) { $props{'чо'} = 0 }
  # 2-й родильный падеж
  if (s/,\s*[Рр]2\s*//) { $props{'р2'} = 0 }
  # 2-й предложный падеж
  if (s/,\s*[Пп]2(?: ?\((во?|на)\))?\s*//) { $props{'п2'} = ($1 or "") }
  # 2-й предложный падеж факультативный
  if (s/,\s*\[[Пп]2(?: ?\((во?|на)\))?\]\s*//) { $props{'п2ф'} = ($1 or "") }
  # определённые чередования
  if (!m/^[^*]*мн\./ && s/\*\*//) { $props{'ч2'} = 0 }
  # чередование беглой гласной с нулём
  if (!m/^[^*]*мн\./ && s/\*//)   { $props{'ч'} = 0 }
  # другие чередования
  if (s/\(-(.{1,2})-\)//) { $props{'ч3'} = $1 }
  # форма затруднительна
  if (s/\!//) { $zvs = 1 }
  # формы нет
  if (s/\?//) { $zvp = 1 }
  # сравнительной степени нет
  if (s/\~//) { $nprops{'пс-с'} = 0 }
  s/,?\s*$//;
  # форма предположительна
  if (s/\-$//) { $nmn = 1 }

  # $tip - тип склонения/спряжения, $ud - схема ударения
  if (s/0\s*$//) { $tip = 0; }
  elsif (s|(\d{1,2})([авсDеF](?:\'{1,2})?)(/[авсDеF](?:\'{1,2})?)?||) {
    $tip = $1; $ud = $2;
    if (defined $3) {
      my $ud2 = $3; $ud2 =~ s(/)();
      $ud2 =~ tr/авсDеF/abcdef/; $ud2 =~ s/\'\'/2/; $ud2 =~ s/\'/1/;
      $props{'у2'} = $ud2;
    }
    $ud =~ tr/авсDеF/abcdef/; $ud  =~ s/\'\'/2/; $ud  =~ s/\'/1/;
  }

  if (s/^(н?св(?:-нсв)?)\s*(нп)?\s*//) {
    $vt = $1; $props{'vp'} = $2;
#      if ($vt =~ /-/) { $vt = "'$vt'" }
  }

  s/,?\s*$//;
  if (s/^(мо?|жо?|со?|п|мс-п|числ\.-п) //) {
    $chr2 = $1; $chr2 =~ s/\.//;
#      if ($chr2 =~ /-/) { $chr2 = "'$chr2'" }
  }

  if (s/^([мжс](о)?)$//) {
    $chr = $1; $an = $2 if defined $2;
    # print "$w\t$chr$tip",defined$ch1?"*":" ","\n";
  } elsif(s/^мо-жо$//) {
    ($chr, $an) = ("мо-жо", "о");
  } elsif(s|^м//мо$||) {
    ($chr, $an) = ("м", "но");
  } elsif(s|^ж//жо$||||s|^жо//ж$||) {
    ($chr, $an) = ("ж", "но");
  } elsif(s/^(п|мс|мс-п)$//) {
    $chr = $1;
  } elsif(s/^(н|предик\.|межд\.|предл\.|част\.|союз|вводн\.|сравн\.)$//) {
    $chr = $1; $chr =~ s/\.$//; $tip = 0;
  }

  s/,?\s*$//;
  if ($_ ne "") { print STDERR "$o\n"; next }

  if (defined $mn) {            # pluralia tantum
    $chr2 = "мн";               # TODO: _от_
    if ($chr =~ /о$/ || $mn eq "одуш.") { $chr2 .= "о" }
  }

  my ($plm, $pla, $pos);
  $plm = "";
  $pos = $chr2||$chr||$vt||"unknown";
  if ($tip == 0) { $idx = "0" }
  else {
    $idx = "$tip$ud";

    $plm .= "\tмн:от" if (defined $mn && $mn eq "_от_");

    $plm .= "\tч" if defined $props{'ч'};
    $plm .= "\tч2" if defined $props{'ч2'};
    $plm .= "\tч3:".$props{'ч3'} if defined $props{'ч3'};

    $plm .= "\tм:$chr" if defined $chr2; # морф. характеристика
    $plm .= "\tу2:".$props{'у2'} if defined $props{'у2'};

    $plm .= "\tдо:".$props{'до'} if defined $props{'до'};
    $plm .= "\tос:".$props{'ос'} if defined $props{'ос'};
    $plm .= "\tосф:".$props{'осф'} if defined $props{'осф'};
    $plm .= "\tчо" if defined $props{'чо'};
    $plm .= "\tчё" if defined $props{'чё'};

    $plm .= "\tр2" if defined $props{'р2'};
    $plm .= "\tп2".($props{'п2'} ne "" ? ":".$props{'п2'} : "") if defined $props{'п2'};
    $plm .= "\tп2ф".($props{'п2ф'} ne "" ? ":".$props{'п2ф'} : "") if defined $props{'п2ф'};

    if (defined $nmn) {         # форма предположительна
      if ($pos eq "п") { $plm .= "\tp:пк-_м" }
      else { $plm .= "\tp:с-_м" }
    }

    my $fz = "";                # форма затруднительна
    if (defined $zvs) {
      if (defined $vt) { $fz .= "\tгп-пс" }
      elsif ($pos eq "п") { $fz .= "\tпк-.." }
    }
    $fz .= "\tс-.м"   if defined $zprops{'с-.м'};
    $fz .= "\tс-рм"   if defined $zprops{'с-рм'};
    $fz .= "\tс-.."   if defined $zprops{'с-..'};
    $fz .= "\tпк-.."  if defined $zprops{'пк-..'};
    $fz .= "\tпк-.м"  if defined $zprops{'пк-.м'};
    $fz .= "\tпк-.ж"  if defined $zprops{'пк-.ж'};
    $fz .= "\tпс-с"    if defined $zprops{'пс-с'};
    $fz .= "\tгп-."    if defined $zprops{'гп-.'};
    $fz .= "\tгд-."    if defined $zprops{'гд-.'};
    $fz .= "\tг-н1е" if defined $zprops{'г-н1е'};
    $fz .= "\tг-б1е" if defined $zprops{'г-б1е'};
    if ($fz ne "") { $fz =~ s/^\t//; $fz =~ s/\t/|/g; $plm .= "\tz:$fz" }

    my $fn = "";                # формы нет
    if (defined $zvp) {
      if (defined $vt) { $fn .= "\tгп-пс" }
      elsif ($pos eq "п") { $fn .= "\tпк-.м" }
    }
    $fn .= "\tс-рм"   if defined $nprops{'с-рм'};
    $fn .= "\tпк-.м"  if defined $nprops{'пк-.м'};
    $fn .= "\tпс-с"    if defined $nprops{'пс-с'};
    $fn .= "\tпс-п"    if defined $nprops{'пс-п'};
    $fn .= "\tгп-п."  if defined $nprops{'гп-п.'};
    $fn .= "\tгп-.с"  if defined $nprops{'гп-.с'};
    $fn .= "\tг-б.." if defined $nprops{'г-б..'};
    $fn .= "\tг-б1е" if defined $nprops{'г-б1е'};
    if ($fn ne "") { $fn =~ s/^\t//; $fn =~ s/\t/|/g; $plm .= "\tn:$fn" }
  }

  $pla = "";
  $pla .= "\tc:".$props{'c'}   if defined $props{'c'};
  $pla .= "\tc2:".$props{'c2'} if defined $props{'c2'};
  $pla .= "\tc3:".$props{'c3'} if defined $props{'c3'};
  $pla .= "\tvp:".$props{'vp'} if defined $props{'vp'};

  print "$w\t$ac\t$pos\t$idx$plm$pla\n";

  next;
}

#  вал 2 м 1с, п2(на) (_земляная насыпь, волна; стержень_)
#  вал 2 м 1а- (_общая стоимость продукции_)

#  вал	2	м	i:1	a1:c	п2:на	c:земляная насыпь, волна; стержень
#  вал	2	м	i:1	a1:a	пр:с(_,м)	c:общая стоимость продукции

#  w(вал,2,м,[i(1,c),п2(на),c('земляная насыпь, волна; стержень')]).
#  w(вал,2,м,[i(1,a),p([с(_,м)]),c('общая стоимость продукции')]).
