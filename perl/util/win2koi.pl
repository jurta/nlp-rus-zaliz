#!/usr/bin/perl -w
# -*- mode: perl; coding: cyrillic-koi8; -*-
# Copyright (C) 1999-2003  Juri Linkov <juri@jurta.org>

# perl win2koi.pl zaliz.wf.win.sort.u.all.comm

# ва!

while (<>) {
  chomp;
  my $w = $_;
  tr/юабцдеефгхийклмнопярстужвьызшэщчъ/абвгдеёжзийклмнопрстуфхцчшщъыьэюя/;
  print "$_ $w\n";
}

# ухнем сумел
# упрем сопел
# уйдем сидел
# уедем седел

# фата черта - тюрю вепрю
