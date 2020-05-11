#!/usr/bin/perl
# decoder -c=ak < ~/doc/lang/rus/star/m_a | perl -p acc.pl | less

%acca = (
        "�" => "�",
        "�" => "�",
        "�" => "�",
        "�" => "�",
        "�" => "�",
        "�" => "�",
        "�" => "�",
        "�" => "�",
        "�" => "�",
        "�" => "�"
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
#    if($ret =~ s/�/�/) { $ret = "$ret ".(length($`)+1); }
#    elsif($ret =~ s/�/�/) { $ret = "$ret ".(length($`)+1); }
  $ret;
}

print acc("����������ˑ�")."\n";
print acc("���׍�������")."\n";
print acc("���׍����Α�")."\n";
