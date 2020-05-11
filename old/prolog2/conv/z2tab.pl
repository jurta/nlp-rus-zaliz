#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

# perl z2tab.pl z > z.tab 2> z.err

print ":-module(z0,[w/4]).\n";
while (<>) {
  chomp;
  s|=>||; s|<=||; s|<//||; s|//>||;
  s/\s*$//;
  
  my ($w, $a, $fr, $c, $c2, $c3, $fk, $us, $v, $cs, $cm, $do, $os, $osf);
  my ($chjo, $cho, $r2, $p2, $p2f, $ch1, $ch2, $ch3);
  my ($zvs, $zvp, $ztl);
  my ($zrmn, $zmn, $zkfm, $zkfv, $zsr, $zkf, $zkof, $zp, $zd, $zn1e, $zb1e);
  my ($nmn, $nrmn, $nkfm, $npf, $npp, $nsv, $nbv, $nb1ev);
  my ($vps, $vmn, $vbl);
  my ($chr, $mn, $tip, $ud, $ud2);
  my ($vt, $vp, $chr2, $skl, $idx);
  $o = $_; $an = ""; # $an="н"; # $w=$s=$p=$c="";
  # undef $w; undef $a; undef $fr; undef $c; undef $fk; undef $us;
  # $w=$a=$fr=$c=$fk=$us=$v=$cs=$cm=$do="";
  if (s/^([^\d]+)\s+([\d.,]+)\s+//) { ($w,$a) = ($1,$2) }
  else { print STDERR "!!! $o\n"; next; }
  
  #  абажур 5                 5              e   абажу'р
  #  аистенок 5,5             e(5)           E   аистёнок
  #  агитбригада 9.3          a(9,3)         ic  аги`тбрига'да
  #  впередсмотрящий 12.5,5   a(12,e(5))     lE  вперёдсмотря'щий
  #  светло-зеленый 11,11.3   a(e(11),3)     Kc  све`тло-зелёный
  #  темно-зеленый 10,10.2,2  a(e(10),e(2))  JB  тёмно-зелёный
  #  серо-буро-малиновый 14.7 a(14,7,2) ???  ngb се`ро-бу`ро-мали'новый ???
  if (   $a =~ /^(\d+)\,(\d+)\.(\d+)\,(\d+)$/
         && $1 eq $2 && $3 eq $4)                   { $ac = "a(e($1),e($3))"; }
  elsif ($a =~ /^(\d+)\.(\d+)\,(\d+)$/ && $2 eq $3) { $ac = "a($1,e($2))"; }
  elsif ($a =~ /^(\d+)\.(\d+)\,(\d+)$/ && $1 eq $3) { $ac = "a(e($1),$2)"; }
  elsif ($a =~ /^(\d+)\,(\d+)\.(\d+)$/ && $1 eq $2) { $ac = "a(e($2),$3)"; }
  elsif ($a =~ /^(\d+)\,(\d+)$/        && $1 eq $2) { $ac = "e($1)"   ; }
  elsif ($a =~ /^(\d+)\.(\d+)$/                   ) { $ac = "a($1,$2)"; }
  elsif ($a =~ /^(\d+)$/                          ) { $ac = "$1"      ; }
  else                                              { $ac = "unknown" ; }

  # фразеологизмы
  if (s/\s*%\s*(.*)$//) { $fr = $1 }
  # морфологически нерегулярные формы
  if (s/\s*@\s*(.*)$//) { print STDERR "$o\n" }
  # слово употребляется только в приводимых словосочетаниях
  if (m/:/ && (m/^[^\(\[]*:/ || !m/[\(\[][^\)\]]*:.*[\)\]]/)
     && s/\s*:\s*(.*)$//) { $us = $1 }
  # факультативная часть индекса
  if (s|\[//(.*)\]||) { $fk = $1 }
  # глагол противоположного вида
  if (s/\s*\$\s*(.*)$//) { $v = $1 }
  # указания значения
  if (s/\(_([^\)]*?)_?\)\s*// # &&$1ne"в"&&$1ne"на"   # if(s|\(([^вн][^\)]*)\)||
    ) { $c = $1 }
  # указания значения дополнительные
  if (s/\(_([^\)]*?)_?\)\s*// # &&$1ne"в"&&$1ne"на"   # if(s|\(([^вн][^\)]*)\)||
    ) { $c2 = $1 }
  # сведения о вариантах слова
  if (s/\[_([^\]]+)\]//) { $c3 = $1 }

  s/^\s*//; s/\s*$//;

  if (s/_Р\. мн\. затрудн\._//) { $zrmn = 1 }
  if (s/_мн\. затрудн\._//) { $zmn = 1 }
  if (s/_кф м и ж затрудн\._//) { $zkfm = 1; $zkfv = 1 }
  if (s/_кф м затрудн\._//) { $zkfm = 1 }
  if (s/_кф ж затрудн\._//) { $zkfv = 1 }
  if (s/_сравн\. затрудн\._//) { $zsr = 1 }
  if (s/_кф и сравн\. затрудн\._//) { $zkf = 1; $zsr = 1 }
  if (s/_косв\. формы затрудн\._//) { $zkof = 1 }
  if (s/_повел\. затрудн\._//) { $zp = 1 }
  if (s/_деепр\. затрудн\._//) { $zd = 1 }
  if (s/_наст\. 1 ед\. затрудн\._//) { $zn1e = 1 }
  if (s/_буд\. 1 ед\. затрудн\._//) { $zb1e = 1 }

  if (s/_Р\. мн\. нет_//) { $nrmn = 1 }
  if (s/_кф м нет_//) { $nkfm = 1 }
  if (s/_пф нет_//) { $npf = 1 }
  if (s/_прич\. прош\. нет_//) { $npp = 1 }
  if (s/_страд\. нет_//) { $nsv = 1 }
  if (s/_буд\. нет_//) { $nbv = 1 }
  if (s/_буд\. 1 ед\. нет_//) { $nb1ev = 1 }

  if (s/_прич\. страд\._ -(.+)-//) { $vps = $1 }
  if (s/,\s*многокр\.//) { $vmn = $1 }
  if (s/,\s*безл\.//) { $vbl = $1 }

  if (s/^мн\.\s*(_от_)?\s*//) { $mn = $1 }

  # дополнительные особенности в склонении
  if (s/(?:,)?\s*\#(\d+)\s*//) { $do = $1 }
  # факультативные отклонения от стандартного склонения
  if (s/\[((?:"\d+")+)\]//) { $osf = $1 }
  # отклонения от стандартного склонения
  if (s/((?:"\d+")+)//) { $os = $1 }
  # чередование ё/е
  if (s/,\s*█\s*//) { $chjo = 1 }
  # чередование о/е
  if (s/,\s*о\s*//) { $cho = 1 }
  # 2-й родильный падеж
  if (s/,\s*[Рр]2\s*//) { $r2 = 1 }
  # 2-й предложный падеж
  if (s/,\s*[Пп]2(?: ?\((во?|на)\))?\s*//) { $p2 = ($1 or "") }
  # 2-й предложный падеж факультативный
  if (s/,\s*\[[Пп]2(?: ?\((во?|на)\))?\]\s*//) { $p2f = ($1 or "") }
  # определённые чередования
  if (!m/^[^*]*мн\./ && s/\*\*//) { $ch2 = 1 }
  # чередование беглой гласной с нулём
  if (!m/^[^*]*мн\./ && s/\*//)   { $ch1 = 1 }
  # другие чередования
  if (s/\(-(.{1,2})-\)//) { $ch3 = $1 }
  # форма затруднительна
  if (s/\!//) { $zvs = 1 }
  # формы нет
  if (s/\?//) { $zvp = 1 }
  # сравнительной степени нет
  if (s/\~//) { $ztl = 1 }
  s/,?\s*$//;
  # форма предположительна
  if (s/\-$//) { $nmn = 1 }

  # $tip - тип склонения/спряжения, $ud - схема ударения
  if (s/0\s*$//) { $tip=0; }
  elsif (s|(\d{1,2})([авсDеF](?:\'{1,2})?)(/[авсDеF](?:\'{1,2})?)?||) {
    $tip = $1; $ud = $2;
    if (defined $3) {
      $ud2 = $3; $ud2 =~ s|/||;
      $ud2 =~ tr/авсDеF/abcdef/; $ud2 =~ s/\'\'/2/; $ud2 =~ s/\'/1/;
    }
    $ud =~ tr/авсDеF/abcdef/; $ud  =~ s/\'\'/2/; $ud  =~ s/\'/1/;
#      if ($ud  =~ /\'/) { $ud  =~ s/\'/''/g; $ud  = "'$ud'" }
#      if ($ud2 =~ /\'/) { $ud2 =~ s/\'/''/g; $ud2 = "'$ud2'" }
  }

  if (s/^(н?св(?:-нсв)?)\s*(нп)?\s*//) {
    $vt = $1; $vp = $2;
    if ($vt =~ /-/) { $vt = "'$vt'" }
  }

  s/,?\s*$//;
  if (s/^(мо?|жо?|со?|п|мс-п|числ\.-п) //) {
    $chr2 = $1; $chr2 =~ s/\.//;
  }

  if (s/^([мжс](о)?)$//) {
    $chr = $1; $an = $2 if defined $2;
    # print "$w\t$chr$tip",defined$ch1?"*":" ","\n";
  } elsif(s/^мо-жо$//) {
    $chr = "'м-ж'"; $an = "о";
  } elsif(s|^м//мо$||) {
    $chr = "м"; $an = "но";
  } elsif(s|^ж//жо$||||s|^жо//ж$||) {
    $chr = "ж"; $an = "но";
  } elsif(s/^(п|мс|мс-п)$//) {
    $chr = $1;
  } elsif(s/^(н|предик\.|межд\.|предл\.|част\.|союз|вводн\.|сравн\.)$//) {
    $chr = $1; $chr =~ s/\.$//; $tip = 0;
  }

  s/,?\s*$//;
  if ($_ ne "") { print STDERR "$o\n"; next }

  my ($plm, $pla, $pos);
  $plm = "";
  $pos = $chr2||$chr||$vt||"unknown";
  if ($tip == 0) { $idx = "i(0)" }
  else {
    $idx = "i($tip,$ud)";

    $plm .= "ч," if defined $ch1;
    $plm .= "ч2," if defined $ch2;
    $plm .= "ч3($ch3)," if defined $ch3;

    $plm .= "mi($chr)," if defined $chr2;
    $plm .= "у($ud2)," if defined $ud2;

    $plm .= "до($do)," if defined $do;
    $plm .= "ос($os)," if defined $os;
    $plm .= "осф($osf)," if defined $osf;
    $plm .= "чо," if defined $cho;
    $plm .= "чё," if defined $chjo;

    $plm .= "р2," if defined $r2;
    $plm .= "п2".($p2 ne "" ? "($p2)" : "(_)")."," if defined $p2;
    $plm .= "п2f".($p2f ne "" ? "($p2f)" : "(_)")."," if defined $p2f;

    if (defined $nmn) {         # форма предположительна
      if ($pos eq "п") { $plm .= "p([пк(_,м)])," }
      else { $plm .= "p([с(_,м)])," }
    }

    my $fz = "";                # форма затруднительна
    if (defined $zvs) {
      if (defined $vt) { $fz .= "гп(п,с)," }
      elsif ($pos eq "п") { $fz .= "пк(_,_)," }
    }
    $fz .= "с(_,м),"   if defined $zmn;
    $fz .= "с(р,м),"   if defined $zrmn;
    $fz .= "с(_,_),"   if defined $zkof;
    $fz .= "пк(_,_),"  if defined $zkf;
    $fz .= "пк(_,м),"  if defined $zkfm;
    $fz .= "пк(_,ж),"  if defined $zkfv;
    $fz .= "пс(с),"    if defined $zsr;
    $fz .= "гп(_),"    if defined $zp;
    $fz .= "гд(_),"    if defined $zd;
    $fz .= "г(н,1,е)," if defined $zn1e;
    $fz .= "г(б,1,е)," if defined $zb1e;
    if ($fz ne "") { $fz =~ s/,$//; $plm .= "z([$fz])," }

    my $fn = "";                # формы нет
    if (defined $zvp) {
      if (defined $vt) { $fn .= "гп(п,с)," }
      elsif ($pos eq "п") { $fn .= "пк(_,м)," }
    }
    $fn .= "с(р,м),"   if defined $nrmn;
    $fn .= "пк(_,м),"  if defined $nkfm;
    $fn .= "пс(с),"    if defined $ztl;
    $fn .= "пс(п),"    if defined $npf;
    $fn .= "гп(п,_),"  if defined $npp;
    $fn .= "гп(_,с),"  if defined $nsv;
    $fn .= "г(б,_,_)," if defined $nbv;
    $fn .= "г(б,1,е)," if defined $nb1ev;
    if ($fn ne "") { $fn =~ s/,$//; $plm .= "n([$fn])," }

#      $idx = "i($tip,$ud$plm)";

#      if (defined $vt) {
#        $pls = "$vt"; if ($pls =~ /-/) { $pls = "'$pls'" }
#      } elsif ($chr =~ /^[мжс]$/) {
#        $pls = "$chr$an";
#      } elsif ($chr =~ /^п$/) {
#        $pls = "$chr"
#      } elsif ($chr =~ /^(?:мс|мс-п)$/) {
#        $pls = "$chr"
#      } else  { $skl = "0" }
  }

#    $plm = "$skl";
  $pla = "";
#    $pla .= "[";
#    $pla .= "t($tip)," if defined $tip;
#    $pla .= "ch1('$ch1')," if defined $ch1;
#    $pla .= "ch2('$ch2')," if defined $ch2;
  $c   =~ s/\'/\'\'/, $pla .= ",c('$c')"   if defined $c;
  $c2  =~ s/\'/\'\'/, $pla .= ",c2('$c2')" if defined $c2;
  $c3  =~ s/\'/\'\'/, $pla .= ",c3('$c3')" if defined $c3;
  $pla .= ",vp($vp)" if defined $vp;
#    $pla =~ s/,$//; $pla .= "]"; $pla =~ s/\[\]/''/;
#?  if ($pla ne "") { $pls = "[$pls$pla]"; }
#??    if ($pla ne "") { $pos = "[$pos$pla]"; }

  if ($plm ne "" || $pla ne "") {
    if ($plm ne "") { $plm =~ s/,$//; $idx = "$idx,$plm" }
    if ($pla ne "") { $idx = "$idx$pla" }
    $idx = "[$idx]"
  }
#    $pls =~ s/\[/s\(/; $pls =~ s/\]$/\)/;
#    $plm =~ s/\[/m\(/; $plm =~ s/\]$/\)/;

  if ($w =~ /-/) { $w = "'$w'" }
  print "w($w,$ac,$pos,$idx).\n";
#    print "wi(w('$w',$ac),$pls,$plm).\n";
#    print "w($w,$ac";
#    print ",[x";
#    print ",c('$c')" if defined $c;
#    print ",c2('$c2')" if defined $c2;
#    print "]).\n";
  next;

  # print "$w\t$ac\t$_\t$c\n";
  print "$_\n";
  next;

#    print "$w\t$ac\t$fr\t$c\t$fk\t$_\n";
  print "$w\t$ac";
  if($fr||$c||$fk||$us||$v) # NB! memory leak in table.so:
    { print "\t$fr\t$c\t$fk\t$us\t$v"; }
  print "\n";

  next;
  
  s/\([^\)]*\)//;
  s|\[[^\]]*\]||;
  s|св нп|св_нп|;
  s|мн\. |мн._|;
  s|п мс|п_мс|;
  s|мс-п п|мс-п_п|;
  s|([жмс]о?) ([пмсжо]+)|$1_$2|;
  s/_от_ //;
  s/, \[?[РрПп]2//;
  s/, _(Р\. ?)?(мн|сравн|деепр\.)\._затрудн\._?//;
  s/_(пф|кф м|деепр\.|страд\.) нет_//;
  s/, [█о\#]//;
  s/, безл.//;
  s/, многокр.//;
  s/\$ ?[─-Ъ]+(\s*)$/$1/;
  s/\$[IV\d]+//;
  s/[IV\d]+\s*$//;
  s/:.*$//;
  s/@.*$//;
  s/, (\#\d+)/$1/;
  s/ (\#\d+\s*)$/$1/;
  s/ (\"\d+\")/$1/;
  
  if(s/(.*?)\s+([\d.,]+)\s+(н|союз|межд\.|част\.|вводн\.|предик\.|предл\.|сравн\.)\s*$//) {
    print "$1 $2 $3\n";
  } elsif(s/(.*?)\s+([\d.,]+)\s+(\S+?)\s+([]\dавсдеD*!?~\"\#-[]+)?\s*$//) {
    print "$1 $2 $3 $4\n";
  } else {
    print STDERR "$_\n";
  }
}

#  #    if(s/^(н|союз|межд\.|част\.|вводн\.|предик\.|предл\.|сравн\.)\s*$//) {
#  #  #      print "$1 $2 $3\n";
#  #    } elsif(s/^(\S+?)\s+([]\dавсдеD*!?~\"\#-[]+)?\s*$//) {
#  #  #      print "$1 $2 $3 $4\n";
#  #    } else {
#  #      print "$_\n";
#  #    }
#  #    next;

#    if(m/^\s*(\S+)/) { print "$1\n"; }
#    if(m/^\s*(.*?)\s*\d/) { print "$1\n"; } # don't work for all
#    s/^([^\d]+)\s+([\d.,]+)\s+//;

#  #    s/\s*\d.*//; print "$_\n"; next;

#  #  #    if(s/^(вводн\.|межд\.|н|предик\.|предл\.|союз|сравн\.|част\.)\s*//) {
#  #  #      $cs=$cm=$1;
#  #  #    } elsif() {
#  #  #    }

__DATA__

вводн.

ж
ж мс
ж п
ж//жо
ж//с
жо
жо п
жо//ж

м
м мс
м п
м с
м//ж, ж
м//мо
м//с

мо
мо жо
мо мс
мо мс-п
мо п
мо со
мо-жо
мо-жо жо
мо//жо
мо//жо, жо
мо//м
мо//со, со

с
с мс
с п
с//ж
с//м
с//со
со
со п
со//с

  п|ж|м
  св|нсв
