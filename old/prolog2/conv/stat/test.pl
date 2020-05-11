#!/usr/bin/perl -w

while(<DATA>) {
  chomp;
  if(m|^[^*]*мн\.|) { print "ok\n"; } else { print "no\n"; }
}

__DATA__
мн. ж 3*а
