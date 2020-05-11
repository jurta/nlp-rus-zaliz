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
  $o = $_; $an = ""; # $an="�"; # $w=$s=$p=$c="";
  # undef $w; undef $a; undef $fr; undef $c; undef $fk; undef $us;
  # $w=$a=$fr=$c=$fk=$us=$v=$cs=$cm=$do="";

  if (s{(?:(//|=)>|<(=|//))}{}) { $vml++ }
#    if ($vml == 1) { }
#    s|=>||; s|<=||; s|<//||; s|//>||;

  s/\s*$//;

  if (s/^([^\d]+)\s+([\d.,]+)\s+//) { ($w,$a) = ($1,$2) }
  else { print STDERR "? $o\n"; next; }

  $ac = $a;
  
  # �������������
  if (s/\s*%\s*(.*)$//) { $fr = $1 }
  # �������������� ������������ �����
  if (s/\s*@\s*(.*)$//) { print STDERR "@ $o\n" }
  # ����� ������������� ������ � ���������� ���������������
  if (m/:/ && (m/^[^\(\[]*:/ || !m/[\(\[][^\)\]]*:.*[\)\]]/)
     && s/\s*:\s*(.*)$//) { $us = $1 }
  # �������������� ����� �������
  if (s|\[//(.*)\]||) { $fk = $1 }
  # ������ ���������������� ����
  if (s/\s*\$\s*(.*)$//) { $v = $1 }
  # �������� ��������
  if (s/\(_([^\)]*?)_?\)\s*// # &&$1ne"�"&&$1ne"��"   # if(s|\(([^��][^\)]*)\)||
    ) { $props{'c'} = $1 }
  # �������� �������� ��������������
  if (s/\(_([^\)]*?)_?\)\s*// # &&$1ne"�"&&$1ne"��"   # if(s|\(([^��][^\)]*)\)||
    ) { $props{'c2'} = $1 }
  # �������� � ��������� �����
  if (s/\[_([^\]]+)\]//) { $props{'c3'} = $1 }

  s/^\s*//; s/\s*$//;

  if (s/_�\. ��\. �������\._//) { $zprops{'�-��'} = 0 }
  if (s/_��\. �������\._//) { $zprops{'�-.�'} = 0 }
  if (s/_�� � � � �������\._//) { $zprops{'��-.�'} = 0; $zprops{'��-.�'} = 0 }
  if (s/_�� � �������\._//) { $zprops{'��-.�'} = 0 }
  if (s/_�� � �������\._//) { $zprops{'��-.�'} = 0 }
  if (s/_�����\. �������\._//) { $zprops{'��-�'} = 0 }
  if (s/_�� � �����\. �������\._//) { $zprops{'��-..'} = 0; $zprops{'��-�'} = 0 }
  if (s/_����\. ����� �������\._//) { $zprops{'�-..'} = 0 }
  if (s/_�����\. �������\._//) { $zprops{'��-.'} = 0 }
  if (s/_�����\. �������\._//) { $zprops{'��-.'} = 0 }
  if (s/_����\. 1 ��\. �������\._//) { $zprops{'�-�1�'} = 0 }
  if (s/_���\. 1 ��\. �������\._//) { $zprops{'�-�1�'} = 0 }

  if (s/_�\. ��\. ���_//) { $nprops{'�-��'} = 0 }
  if (s/_�� � ���_//) { $nprops{'��-.�'} = 0 }
  if (s/_�� ���_//) { $nprops{'��-�'} = 0 }
  if (s/_����\. ����\. ���_//) { $nprops{'��-�.'} = 0 }
  if (s/_�����\. ���_//) { $nprops{'��-.�'} = 0 }
  if (s/_���\. ���_//) { $nprops{'�-�..'} = 0 }
  if (s/_���\. 1 ��\. ���_//) { $nprops{'�-�1�'} = 0 }

  if (s/_����\. �����\._ -(.+)-//) { $vps = ($1 or "") }
  if (s/,\s*�������\.//) { $vmn = 1 }
  if (s/,\s*����\.//) { $vbl = 1 }

  # ������������� �����
  if (s/^��\.\s*(_��_|����\.|����\.)?\s*//) { $mn = ($1 or "") }

  # �������������� ����������� � ���������
  if (s/(?:,)?\s*\#(\d+)\s*//) { $props{'��'} = $1 }
  # �������������� ���������� �� ������������ ���������
  if (s/\[((?:"\d+")+)\]//) {
    # "1""2" -> ���("1""2") ??? -> ���([1,2])
    my $osf = $1; $osf =~ s/""/,/g;  $osf =~ s/\"//g; $osf = "[$osf]";
    $props{'���'} = $osf;
  }
  # ���������� �� ������������ ���������
  if (s/((?:"\d+")+)//) {
    # "1""2" -> ��("1""2") ??? -> ��([1,2])
    my $os = $1; $os =~ s/""/,/g;  $os =~ s/\"//g; $os = "[$os]";
    $props{'��'} = $os;
  }
  # ����������� �/�
  if (s/,\s*�\s*//) { $props{'ޣ'} = 0 }
  # ����������� �/�
  if (s/,\s*�\s*//) { $props{'��'} = 0 }
  # 2-� ��������� �����
  if (s/,\s*[��]2\s*//) { $props{'�2'} = 0 }
  # 2-� ���������� �����
  if (s/,\s*[��]2(?: ?\((��?|��)\))?\s*//) { $props{'�2'} = ($1 or "") }
  # 2-� ���������� ����� ��������������
  if (s/,\s*\[[��]2(?: ?\((��?|��)\))?\]\s*//) { $props{'�2�'} = ($1 or "") }
  # ������̣���� �����������
  if (!m/^[^*]*��\./ && s/\*\*//) { $props{'�2'} = 0 }
  # ����������� ������ ������� � ��̣�
  if (!m/^[^*]*��\./ && s/\*//)   { $props{'�'} = 0 }
  # ������ �����������
  if (s/\(-(.{1,2})-\)//) { $props{'�3'} = $1 }
  # ����� ��������������
  if (s/\!//) { $zvs = 1 }
  # ����� ���
  if (s/\?//) { $zvp = 1 }
  # ������������� ������� ���
  if (s/\~//) { $nprops{'��-�'} = 0 }
  s/,?\s*$//;
  # ����� ����������������
  if (s/\-$//) { $nmn = 1 }

  # $tip - ��� ���������/���������, $ud - ����� ��������
  if (s/0\s*$//) { $tip = 0; }
  elsif (s|(\d{1,2})([���D�F](?:\'{1,2})?)(/[���D�F](?:\'{1,2})?)?||) {
    $tip = $1; $ud = $2;
    if (defined $3) {
      my $ud2 = $3; $ud2 =~ s(/)();
      $ud2 =~ tr/���D�F/abcdef/; $ud2 =~ s/\'\'/2/; $ud2 =~ s/\'/1/;
      $props{'�2'} = $ud2;
    }
    $ud =~ tr/���D�F/abcdef/; $ud  =~ s/\'\'/2/; $ud  =~ s/\'/1/;
  }

  if (s/^(�?��(?:-���)?)\s*(��)?\s*//) {
    $vt = $1; $props{'vp'} = $2;
#      if ($vt =~ /-/) { $vt = "'$vt'" }
  }

  s/,?\s*$//;
  if (s/^(��?|��?|��?|�|��-�|����\.-�) //) {
    $chr2 = $1; $chr2 =~ s/\.//;
#      if ($chr2 =~ /-/) { $chr2 = "'$chr2'" }
  }

  if (s/^([���](�)?)$//) {
    $chr = $1; $an = $2 if defined $2;
    # print "$w\t$chr$tip",defined$ch1?"*":" ","\n";
  } elsif(s/^��-��$//) {
    ($chr, $an) = ("��-��", "�");
  } elsif(s|^�//��$||) {
    ($chr, $an) = ("�", "��");
  } elsif(s|^�//��$||||s|^��//�$||) {
    ($chr, $an) = ("�", "��");
  } elsif(s/^(�|��|��-�)$//) {
    $chr = $1;
  } elsif(s/^(�|������\.|����\.|�����\.|����\.|����|�����\.|�����\.)$//) {
    $chr = $1; $chr =~ s/\.$//; $tip = 0;
  }

  s/,?\s*$//;
  if ($_ ne "") { print STDERR "$o\n"; next }

  if (defined $mn) {            # pluralia tantum
    $chr2 = "��";               # TODO: _��_
    if ($chr =~ /�$/ || $mn eq "����.") { $chr2 .= "�" }
  }

  my ($plm, $pla, $pos);
  $plm = "";
  $pos = $chr2||$chr||$vt||"unknown";
  if ($tip == 0) { $idx = "0" }
  else {
    $idx = "$tip$ud";

    $plm .= "\t��:��" if (defined $mn && $mn eq "_��_");

    $plm .= "\t�" if defined $props{'�'};
    $plm .= "\t�2" if defined $props{'�2'};
    $plm .= "\t�3:".$props{'�3'} if defined $props{'�3'};

    $plm .= "\t�:$chr" if defined $chr2; # ����. ��������������
    $plm .= "\t�2:".$props{'�2'} if defined $props{'�2'};

    $plm .= "\t��:".$props{'��'} if defined $props{'��'};
    $plm .= "\t��:".$props{'��'} if defined $props{'��'};
    $plm .= "\t���:".$props{'���'} if defined $props{'���'};
    $plm .= "\t��" if defined $props{'��'};
    $plm .= "\tޣ" if defined $props{'ޣ'};

    $plm .= "\t�2" if defined $props{'�2'};
    $plm .= "\t�2".($props{'�2'} ne "" ? ":".$props{'�2'} : "") if defined $props{'�2'};
    $plm .= "\t�2�".($props{'�2�'} ne "" ? ":".$props{'�2�'} : "") if defined $props{'�2�'};

    if (defined $nmn) {         # ����� ����������������
      if ($pos eq "�") { $plm .= "\tp:��-_�" }
      else { $plm .= "\tp:�-_�" }
    }

    my $fz = "";                # ����� ��������������
    if (defined $zvs) {
      if (defined $vt) { $fz .= "\t��-��" }
      elsif ($pos eq "�") { $fz .= "\t��-.." }
    }
    $fz .= "\t�-.�"   if defined $zprops{'�-.�'};
    $fz .= "\t�-��"   if defined $zprops{'�-��'};
    $fz .= "\t�-.."   if defined $zprops{'�-..'};
    $fz .= "\t��-.."  if defined $zprops{'��-..'};
    $fz .= "\t��-.�"  if defined $zprops{'��-.�'};
    $fz .= "\t��-.�"  if defined $zprops{'��-.�'};
    $fz .= "\t��-�"    if defined $zprops{'��-�'};
    $fz .= "\t��-."    if defined $zprops{'��-.'};
    $fz .= "\t��-."    if defined $zprops{'��-.'};
    $fz .= "\t�-�1�" if defined $zprops{'�-�1�'};
    $fz .= "\t�-�1�" if defined $zprops{'�-�1�'};
    if ($fz ne "") { $fz =~ s/^\t//; $fz =~ s/\t/|/g; $plm .= "\tz:$fz" }

    my $fn = "";                # ����� ���
    if (defined $zvp) {
      if (defined $vt) { $fn .= "\t��-��" }
      elsif ($pos eq "�") { $fn .= "\t��-.�" }
    }
    $fn .= "\t�-��"   if defined $nprops{'�-��'};
    $fn .= "\t��-.�"  if defined $nprops{'��-.�'};
    $fn .= "\t��-�"    if defined $nprops{'��-�'};
    $fn .= "\t��-�"    if defined $nprops{'��-�'};
    $fn .= "\t��-�."  if defined $nprops{'��-�.'};
    $fn .= "\t��-.�"  if defined $nprops{'��-.�'};
    $fn .= "\t�-�.." if defined $nprops{'�-�..'};
    $fn .= "\t�-�1�" if defined $nprops{'�-�1�'};
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

#  ��� 2 � 1�, �2(��) (_�������� ������, �����; ��������_)
#  ��� 2 � 1�- (_����� ��������� ���������_)

#  ���	2	�	i:1	a1:c	�2:��	c:�������� ������, �����; ��������
#  ���	2	�	i:1	a1:a	��:�(_,�)	c:����� ��������� ���������

#  w(���,2,�,[i(1,c),�2(��),c('�������� ������, �����; ��������')]).
#  w(���,2,�,[i(1,a),p([�(_,�)]),c('����� ��������� ���������')]).
