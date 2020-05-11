#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>
# License: GNU GPL 2 (see the file README)

# ��������������� ��������� �������� ������:
# �������������� �������� ������ � ������ Z_<�����>
# � ���� ��������� ���� zaliz.txt.

# perl z2txt.pl Z_* > z.txt

use POSIX qw(locale_h strftime);
my $CURDATE = strftime('%Y-%m-%d', localtime);
my $PROGRAM = ($0 =~ /([^\/]*)$/)[0];
my $VERSION = "0.0.1";

print <<HERE;
# -*- mode: text; coding: cyrillic-koi8; -*-
# $CURDATE $PROGRAM v$VERSION http://jurta.org/ru/nlp/rus/zaliz
HERE

# ����: $currtime
# ���������: $PROGRAM v$VERSION http://.../zaliz/index.ru.html

# ;; Date: $currtime
# ;; Generator: ell.pl v$version from http://.../ee/
# ;; Source: http://www/ell.html ($filetime)

# ������������� (���������������, ���������, �����������) 2003-03-12
# ����������� (��������������) http://.../zaliz/conv/ version: 0.0.1
# �� http://starling.rinet.ru/download/dicts.EXE (����: 2003-01-05, ������: 3964665)
# ��������: http://starling.rinet.ru/download/dicts.EXE (����: 2003-01-05, ������: 3964665)

my %seen;

while (<>) {
  chomp;
  s/\r$//o;                     # ������� ������ \r (CR, return) � ����� ������
  s/\004.*$//;                  # ������� ������� ����� �� ���������� ����
  s/^\*//;                      # ������� �ף������ � ������ ������
  s/\s+$//;                     # ������� ������� � ����� ������
  next if/^$/;                  # ���������� ������ ������
  next if $seen{$_}++;          # ���������� ���������
  # ��������� ����� � ��������� � ��������� �����
  tr(���������ʱ�����)
    (����������������);
  # ������� ��������� � CP866 �� KOI8-R
  tr(���������������������������������������񦧨�����������������������)
    (�������������������������������������ţ��������������������������);
  print "$_\n";
}
