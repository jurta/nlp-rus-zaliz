#!/usr/bin/perl -w
# -*- mode: perl; coding: utf-8; perl-indent-level: 2; -*-

use utf8;
binmode(STDIN, ":encoding(koi8-r)");
binmode(STDOUT, ":utf8");

while (<>) {
  s/'/́/g;
  s/`/̀/g;
  print;
}
