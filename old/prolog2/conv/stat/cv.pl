# cut -f 1 ../z.tab | perl cv.pl | sort | uniq -c | sort -nr
$v="[�ţ�������]";
$c="[^v����ţ�������]";
while(<>) {
  chomp;
  s/$v/v/g; s/$c/c/g;
  print "$_\n";
}
