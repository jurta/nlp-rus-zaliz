#!/usr/bin/perl
# decoder -c=ak < ~/doc/lang/rus/star/m_a | perl -p acc.pl | less

%acca = (
        "┬" => "а",
        "┼" => "е",
        "█" => "ё",
        "▐" => "и",
        "▒" => "о",
        "√" => "у",
        " " => "ы",
        "°" => "э",
        "·" => "ю",
        "╒" => "я"
       );

sub acc {
  my($word) = @_;
  my($ret) = $word;
  while (($key,$value) = each %acca) {
#      print "$key/$value\n";
    if($ret =~ s/$key/$value/) {
      $ret = "$ret ".(length($`)+1);
    }
  }
#    if($ret =~ s/┬/а/) { $ret = "$ret ".(length($`)+1); }
#    elsif($ret =~ s/▒/о/) { $ret = "$ret ".(length($`)+1); }
  $ret;
}

print acc("автозаводск▒й")."\n";
print acc("безв█сельный")."\n";
print acc("безв█сельн▒й")."\n";
