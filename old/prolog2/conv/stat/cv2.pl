# cut -f 1 ../z.tab | perl -s cv2.pl -s=cccccc
# perl -s cv2.pl -s=cccccc ../z

# perl -s cv2.pl -s=^cvcvc$ ../z.tab > cv2
# cut -f 2 cv2 | sort | uniq -c | sort -nr
# perl ../revdic.pl cv2 | sort -k 2 | perl ../revdic.pl

$v="[¡≈£…œ’Ÿ‹¿—]";
$c="[^vÿﬂ ¡≈£…œ’Ÿ‹¿—]";
#  $s="cvcvvvcvc";
$s=~s/v/\$v/g; $s=~s/c/\$c/g; $s=~s/(\$\w+)/$1/eeg;
while(<>) {
  chomp;
#    if(/$s/o) {print "$_\n"}
  split; if($_[0]=~/$s/o) {print "$_[0]\t$_[1]\n"}
}
