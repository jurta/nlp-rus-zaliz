#!/usr/bin/perl -w
# perl tab2dbm.pl /root/usr/lang/rus/starling/z/conv/z.tab

use GDBM_File;

$dicfile = "../zaliz.dbm";

tie(%dict, 'GDBM_File', $dicfile, &GDBM_WRCREAT|&GDBM_FAST, 0640);
while(<>) {
  chomp;
  if (/^(\S+)\s+(.*)/) {
    $dict{$1} = $2;
#      my $val = $dict{$1};
#      if (defined $val) { $dict{$1} = $val."	".$2; }
#      else { $dict{$1} = $2; }
#      print "dict{$1} = $2\n";
  }
}
untie(%dict);
