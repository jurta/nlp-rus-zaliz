#!/usr/bin/perl -w

while(<DATA>) {
  chomp;
  if(m|^[^*]*��\.|) { print "ok\n"; } else { print "no\n"; }
}

__DATA__
��. � 3*�
