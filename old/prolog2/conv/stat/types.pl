#!/usr/bin/perl
# perl -p types.pl ../z | sort | uniq -c | sort -nr > types

  s/^([^\d]+)\s+([\d.,]+)\s+//;
#    s/\s*\d.*//;
