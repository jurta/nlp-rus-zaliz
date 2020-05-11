# cut -f 1 ../z.tab | perl c.pl | sort | uniq -c | sort -nr
#  $nc="[¡≈£…œ’Ÿ‹¿—]"; # not consonant
$nc="[ÿﬂ ¡≈£…œ’Ÿ‹¿—]"; # not consonant
while(<>) {
  chomp;
  s/$nc//g;
  print "$_\n";
}
