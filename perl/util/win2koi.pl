#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>

# perl win2koi.pl zaliz.wf.win.sort.u.all.comm

# ��!

while (<>) {
  chomp;
  my $w = $_;
  tr/���������������������������������/�����ţ��������������������������/;
  print "$_ $w\n";
}

# ����� �����
# ����� �����
# ����� �����
# ����� �����

# ���� ����� - ���� �����
