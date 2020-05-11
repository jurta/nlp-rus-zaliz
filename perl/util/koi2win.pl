#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>

# perl koi2win.pl zaliz.wf.sort.u.all | sort -u > zaliz.wf.win.sort.u.all
# comm -12 zaliz.wf.sort.u.all zaliz.wf.win.sort.u.all > zaliz.wf.win.sort.u.all.comm

# ва!

while (<>) {
  chomp;
  tr/абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ/юабцдеефгхийклмнопярстужвьызшэщчъюабцдеефгхийклмнопярстужвьызшэщчъ/;
  print "$_\n";
}
