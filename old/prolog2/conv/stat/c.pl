# cut -f 1 ../z.tab | perl c.pl | sort | uniq -c | sort -nr
#  $nc="[�ţ�������]"; # not consonant
$nc="[����ţ�������]"; # not consonant
while(<>) {
  chomp;
  s/$nc//g;
  print "$_\n";
}
