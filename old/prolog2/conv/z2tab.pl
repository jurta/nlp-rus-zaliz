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
  $o = $_; $an = ""; # $an="�"; # $w=$s=$p=$c="";
  # undef $w; undef $a; undef $fr; undef $c; undef $fk; undef $us;
  # $w=$a=$fr=$c=$fk=$us=$v=$cs=$cm=$do="";
  if (s/^([^\d]+)\s+([\d.,]+)\s+//) { ($w,$a) = ($1,$2) }
  else { print STDERR "!!! $o\n"; next; }
  
  #  ������ 5                 5              e   �����'�
  #  �������� 5,5             e(5)           E   ���ԣ���
  #  ����������� 9.3          a(9,3)         ic  ���`������'��
  #  ��������������� 12.5,5   a(12,e(5))     lE  ���ң�������'���
  #  ������-������� 11,11.3   a(e(11),3)     Kc  ���`���-��̣���
  #  �����-������� 10,10.2,2  a(e(10),e(2))  JB  ԣ���-��̣���
  #  ����-����-��������� 14.7 a(14,7,2) ???  ngb ��`��-��`��-����'����� ???
  if (   $a =~ /^(\d+)\,(\d+)\.(\d+)\,(\d+)$/
         && $1 eq $2 && $3 eq $4)                   { $ac = "a(e($1),e($3))"; }
  elsif ($a =~ /^(\d+)\.(\d+)\,(\d+)$/ && $2 eq $3) { $ac = "a($1,e($2))"; }
  elsif ($a =~ /^(\d+)\.(\d+)\,(\d+)$/ && $1 eq $3) { $ac = "a(e($1),$2)"; }
  elsif ($a =~ /^(\d+)\,(\d+)\.(\d+)$/ && $1 eq $2) { $ac = "a(e($2),$3)"; }
  elsif ($a =~ /^(\d+)\,(\d+)$/        && $1 eq $2) { $ac = "e($1)"   ; }
  elsif ($a =~ /^(\d+)\.(\d+)$/                   ) { $ac = "a($1,$2)"; }
  elsif ($a =~ /^(\d+)$/                          ) { $ac = "$1"      ; }
  else                                              { $ac = "unknown" ; }

  # �������������
  if (s/\s*%\s*(.*)$//) { $fr = $1 }
  # �������������� ������������ �����
  if (s/\s*@\s*(.*)$//) { print STDERR "$o\n" }
  # ����� ������������� ������ � ���������� ���������������
  if (m/:/ && (m/^[^\(\[]*:/ || !m/[\(\[][^\)\]]*:.*[\)\]]/)
     && s/\s*:\s*(.*)$//) { $us = $1 }
  # �������������� ����� �������
  if (s|\[//(.*)\]||) { $fk = $1 }
  # ������ ���������������� ����
  if (s/\s*\$\s*(.*)$//) { $v = $1 }
  # �������� ��������
  if (s/\(_([^\)]*?)_?\)\s*// # &&$1ne"�"&&$1ne"��"   # if(s|\(([^��][^\)]*)\)||
    ) { $c = $1 }
  # �������� �������� ��������������
  if (s/\(_([^\)]*?)_?\)\s*// # &&$1ne"�"&&$1ne"��"   # if(s|\(([^��][^\)]*)\)||
    ) { $c2 = $1 }
  # �������� � ��������� �����
  if (s/\[_([^\]]+)\]//) { $c3 = $1 }

  s/^\s*//; s/\s*$//;

  if (s/_�\. ��\. �������\._//) { $zrmn = 1 }
  if (s/_��\. �������\._//) { $zmn = 1 }
  if (s/_�� � � � �������\._//) { $zkfm = 1; $zkfv = 1 }
  if (s/_�� � �������\._//) { $zkfm = 1 }
  if (s/_�� � �������\._//) { $zkfv = 1 }
  if (s/_�����\. �������\._//) { $zsr = 1 }
  if (s/_�� � �����\. �������\._//) { $zkf = 1; $zsr = 1 }
  if (s/_����\. ����� �������\._//) { $zkof = 1 }
  if (s/_�����\. �������\._//) { $zp = 1 }
  if (s/_�����\. �������\._//) { $zd = 1 }
  if (s/_����\. 1 ��\. �������\._//) { $zn1e = 1 }
  if (s/_���\. 1 ��\. �������\._//) { $zb1e = 1 }

  if (s/_�\. ��\. ���_//) { $nrmn = 1 }
  if (s/_�� � ���_//) { $nkfm = 1 }
  if (s/_�� ���_//) { $npf = 1 }
  if (s/_����\. ����\. ���_//) { $npp = 1 }
  if (s/_�����\. ���_//) { $nsv = 1 }
  if (s/_���\. ���_//) { $nbv = 1 }
  if (s/_���\. 1 ��\. ���_//) { $nb1ev = 1 }

  if (s/_����\. �����\._ -(.+)-//) { $vps = $1 }
  if (s/,\s*�������\.//) { $vmn = $1 }
  if (s/,\s*����\.//) { $vbl = $1 }

  if (s/^��\.\s*(_��_)?\s*//) { $mn = $1 }

  # �������������� ����������� � ���������
  if (s/(?:,)?\s*\#(\d+)\s*//) { $do = $1 }
  # �������������� ���������� �� ������������ ���������
  if (s/\[((?:"\d+")+)\]//) { $osf = $1 }
  # ���������� �� ������������ ���������
  if (s/((?:"\d+")+)//) { $os = $1 }
  # ����������� �/�
  if (s/,\s*�\s*//) { $chjo = 1 }
  # ����������� �/�
  if (s/,\s*�\s*//) { $cho = 1 }
  # 2-� ��������� �����
  if (s/,\s*[��]2\s*//) { $r2 = 1 }
  # 2-� ���������� �����
  if (s/,\s*[��]2(?: ?\((��?|��)\))?\s*//) { $p2 = ($1 or "") }
  # 2-� ���������� ����� ��������������
  if (s/,\s*\[[��]2(?: ?\((��?|��)\))?\]\s*//) { $p2f = ($1 or "") }
  # ������̣���� �����������
  if (!m/^[^*]*��\./ && s/\*\*//) { $ch2 = 1 }
  # ����������� ������ ������� � ��̣�
  if (!m/^[^*]*��\./ && s/\*//)   { $ch1 = 1 }
  # ������ �����������
  if (s/\(-(.{1,2})-\)//) { $ch3 = $1 }
  # ����� ��������������
  if (s/\!//) { $zvs = 1 }
  # ����� ���
  if (s/\?//) { $zvp = 1 }
  # ������������� ������� ���
  if (s/\~//) { $ztl = 1 }
  s/,?\s*$//;
  # ����� ����������������
  if (s/\-$//) { $nmn = 1 }

  # $tip - ��� ���������/���������, $ud - ����� ��������
  if (s/0\s*$//) { $tip=0; }
  elsif (s|(\d{1,2})([���D�F](?:\'{1,2})?)(/[���D�F](?:\'{1,2})?)?||) {
    $tip = $1; $ud = $2;
    if (defined $3) {
      $ud2 = $3; $ud2 =~ s|/||;
      $ud2 =~ tr/���D�F/abcdef/; $ud2 =~ s/\'\'/2/; $ud2 =~ s/\'/1/;
    }
    $ud =~ tr/���D�F/abcdef/; $ud  =~ s/\'\'/2/; $ud  =~ s/\'/1/;
#      if ($ud  =~ /\'/) { $ud  =~ s/\'/''/g; $ud  = "'$ud'" }
#      if ($ud2 =~ /\'/) { $ud2 =~ s/\'/''/g; $ud2 = "'$ud2'" }
  }

  if (s/^(�?��(?:-���)?)\s*(��)?\s*//) {
    $vt = $1; $vp = $2;
    if ($vt =~ /-/) { $vt = "'$vt'" }
  }

  s/,?\s*$//;
  if (s/^(��?|��?|��?|�|��-�|����\.-�) //) {
    $chr2 = $1; $chr2 =~ s/\.//;
  }

  if (s/^([���](�)?)$//) {
    $chr = $1; $an = $2 if defined $2;
    # print "$w\t$chr$tip",defined$ch1?"*":" ","\n";
  } elsif(s/^��-��$//) {
    $chr = "'�-�'"; $an = "�";
  } elsif(s|^�//��$||) {
    $chr = "�"; $an = "��";
  } elsif(s|^�//��$||||s|^��//�$||) {
    $chr = "�"; $an = "��";
  } elsif(s/^(�|��|��-�)$//) {
    $chr = $1;
  } elsif(s/^(�|������\.|����\.|�����\.|����\.|����|�����\.|�����\.)$//) {
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

    $plm .= "�," if defined $ch1;
    $plm .= "�2," if defined $ch2;
    $plm .= "�3($ch3)," if defined $ch3;

    $plm .= "mi($chr)," if defined $chr2;
    $plm .= "�($ud2)," if defined $ud2;

    $plm .= "��($do)," if defined $do;
    $plm .= "��($os)," if defined $os;
    $plm .= "���($osf)," if defined $osf;
    $plm .= "��," if defined $cho;
    $plm .= "ޣ," if defined $chjo;

    $plm .= "�2," if defined $r2;
    $plm .= "�2".($p2 ne "" ? "($p2)" : "(_)")."," if defined $p2;
    $plm .= "�2f".($p2f ne "" ? "($p2f)" : "(_)")."," if defined $p2f;

    if (defined $nmn) {         # ����� ����������������
      if ($pos eq "�") { $plm .= "p([��(_,�)])," }
      else { $plm .= "p([�(_,�)])," }
    }

    my $fz = "";                # ����� ��������������
    if (defined $zvs) {
      if (defined $vt) { $fz .= "��(�,�)," }
      elsif ($pos eq "�") { $fz .= "��(_,_)," }
    }
    $fz .= "�(_,�),"   if defined $zmn;
    $fz .= "�(�,�),"   if defined $zrmn;
    $fz .= "�(_,_),"   if defined $zkof;
    $fz .= "��(_,_),"  if defined $zkf;
    $fz .= "��(_,�),"  if defined $zkfm;
    $fz .= "��(_,�),"  if defined $zkfv;
    $fz .= "��(�),"    if defined $zsr;
    $fz .= "��(_),"    if defined $zp;
    $fz .= "��(_),"    if defined $zd;
    $fz .= "�(�,1,�)," if defined $zn1e;
    $fz .= "�(�,1,�)," if defined $zb1e;
    if ($fz ne "") { $fz =~ s/,$//; $plm .= "z([$fz])," }

    my $fn = "";                # ����� ���
    if (defined $zvp) {
      if (defined $vt) { $fn .= "��(�,�)," }
      elsif ($pos eq "�") { $fn .= "��(_,�)," }
    }
    $fn .= "�(�,�),"   if defined $nrmn;
    $fn .= "��(_,�),"  if defined $nkfm;
    $fn .= "��(�),"    if defined $ztl;
    $fn .= "��(�),"    if defined $npf;
    $fn .= "��(�,_),"  if defined $npp;
    $fn .= "��(_,�),"  if defined $nsv;
    $fn .= "�(�,_,_)," if defined $nbv;
    $fn .= "�(�,1,�)," if defined $nb1ev;
    if ($fn ne "") { $fn =~ s/,$//; $plm .= "n([$fn])," }

#      $idx = "i($tip,$ud$plm)";

#      if (defined $vt) {
#        $pls = "$vt"; if ($pls =~ /-/) { $pls = "'$pls'" }
#      } elsif ($chr =~ /^[���]$/) {
#        $pls = "$chr$an";
#      } elsif ($chr =~ /^�$/) {
#        $pls = "$chr"
#      } elsif ($chr =~ /^(?:��|��-�)$/) {
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
  s|�� ��|��_��|;
  s|��\. |��._|;
  s|� ��|�_��|;
  s|��-� �|��-�_�|;
  s|([���]�?) ([�����]+)|$1_$2|;
  s/_��_ //;
  s/, \[?[����]2//;
  s/, _(�\. ?)?(��|�����|�����\.)\._�������\._?//;
  s/_(��|�� �|�����\.|�����\.) ���_//;
  s/, [��\#]//;
  s/, ����.//;
  s/, �������.//;
  s/\$ ?[�-�]+(\s*)$/$1/;
  s/\$[IV\d]+//;
  s/[IV\d]+\s*$//;
  s/:.*$//;
  s/@.*$//;
  s/, (\#\d+)/$1/;
  s/ (\#\d+\s*)$/$1/;
  s/ (\"\d+\")/$1/;
  
  if(s/(.*?)\s+([\d.,]+)\s+(�|����|����\.|����\.|�����\.|������\.|�����\.|�����\.)\s*$//) {
    print "$1 $2 $3\n";
  } elsif(s/(.*?)\s+([\d.,]+)\s+(\S+?)\s+([]\d�����D*!?~\"\#-[]+)?\s*$//) {
    print "$1 $2 $3 $4\n";
  } else {
    print STDERR "$_\n";
  }
}

#  #    if(s/^(�|����|����\.|����\.|�����\.|������\.|�����\.|�����\.)\s*$//) {
#  #  #      print "$1 $2 $3\n";
#  #    } elsif(s/^(\S+?)\s+([]\d�����D*!?~\"\#-[]+)?\s*$//) {
#  #  #      print "$1 $2 $3 $4\n";
#  #    } else {
#  #      print "$_\n";
#  #    }
#  #    next;

#    if(m/^\s*(\S+)/) { print "$1\n"; }
#    if(m/^\s*(.*?)\s*\d/) { print "$1\n"; } # don't work for all
#    s/^([^\d]+)\s+([\d.,]+)\s+//;

#  #    s/\s*\d.*//; print "$_\n"; next;

#  #  #    if(s/^(�����\.|����\.|�|������\.|�����\.|����|�����\.|����\.)\s*//) {
#  #  #      $cs=$cm=$1;
#  #  #    } elsif() {
#  #  #    }

__DATA__

�����.

�
� ��
� �
�//��
�//�
��
�� �
��//�

�
� ��
� �
� �
�//�, �
�//��
�//�

��
�� ��
�� ��
�� ��-�
�� �
�� ��
��-��
��-�� ��
��//��
��//��, ��
��//�
��//��, ��

�
� ��
� �
�//�
�//�
�//��
��
�� �
��//�

  �|�|�
  ��|���
