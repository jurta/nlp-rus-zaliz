# perl gettype.pl ~/doc/lang/rus/zaliz/zaliz/zaliz | sort | uniq -c | sort -n -r > types

while(<>) {
    chomp;
#      s/^[^\d.,]*[\d.,]+\s*//; s/\s*\d+.*$//;
    s/^[^\d.,]*[\d.,]+\s*//;
    s/\s*\$.*$//;
    s/\s*\(.*\)\s*//;
#      s/.*(\d+)/\1/;
#      s/.*(\d.*)$/\1/;
    print "$_\n";
}

#  бежать 4 нсв ???
#  варить 4 нсв 4c ???
