#!/usr/bin/perl -w

use GDBM_File;

$word = shift;
$dicfile = "zaliz.dbm";

tie(%dict, 'GDBM_File', $dicfile, 0, 0640);
if($value = $dict{lc $word}) {
  print "$value\n";
} else {
  print "not found\n";
}
#  while (($key,$val) = each %dict) {
#    print $key, '=', $val, "\n";
#  }
untie(%dict);
