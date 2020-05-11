# perl revdic.pl z | sortkoi8 | perl revdic.pl > zrev
while(<>) {
  chomp;
  ($first, $remainder) = split(/[ \t\n]+/, $_, 2);
  $first = join('', reverse split(/ */, $first));
  print "$first $remainder\n";
}
