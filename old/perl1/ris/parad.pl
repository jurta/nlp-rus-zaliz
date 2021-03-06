#!/usr/bin/perl -w
# perl parad.pl in

$v     = '�ţ�������';            # $�������
$c = '���������������������'; # $���������
$k = "���";
$sh = "����";

while (<>) {
  chomp;
  # my ($w, $a) = split /\t/; $w = accent($w, $a); print "$w,$a\n";
  $r = razrjad($_); # �������������� ������
  # ������� ���������
  $mc = mclass ($_, $r); # ��������������� �����
  $t = tip_sklonenija($_,$r,$mc); # ��� ���������
  $w = split_oo($_, $t);
  $uw = c_du($w);
#  print "$uw:$mc:$t\n";
  $uw =~ s/\|.*/\|���/;
#    $uw =~ s/\|.*/\|�/;
  $dw = c_ud($uw);
print "$dw:$mc:$t\n";
}

sub accent {
  my ($w, $a) = @_;
  if ($a =~ /a\((\d+)/) { $a = $1 }
  elsif ($a =~ /e\((\d+)/) { $a = $1; substr($w, $a-1, 1) = '�' }
  substr($w, $a-1, 1) =~ tr/�ţ�������/��������� /;
  $w
}

sub razrjad {
  local ($_) = @_;
  return "sb" if (/^(����|���|���|������|������|���|����|����|�������|������|�������|������|��������|��������|��������)$/);
  return "sb" if (/^(�������|�������|���������)$/);
  return "sb" if (/^(���|���������|������|��������|������)$/);
  return "nb" if (/^(���|����|�����|����|������|������|������|�����������|����������|����������|������������|����������|�����������|����������|������������|������������|��������|��������|�����|����������|����������|���������|�����������|���������|���|����������|������|������|���������|�������|��������|�������|���������|���������|������)$/);
  return "nb" if (/^(�������|�������|���������|�����|�������|����|������)$/);
  return "nb" if (/^(�|��|��|���|���|��|��|���|����|���� �����|���|���|�����|�����|�����|�����|������|������)$/);
  return "nb" if (/^(���|���������|������|������|������|���������)$/);
  if (/(��|��|��|����|��|��|��|��|��)$/) {
    return "pril";
  } else {
    return "susch";
  }
}

sub tip_sklonenija {
  local ($_) = shift;
  my ($r) = shift;
  my ($mc) = shift;
  if ($r eq "sb" or $r eq "nb") { return "1�"; }
  if ($r eq "pril") { return "��"; }
  if ($r eq "susch") {
    if (/�$/) {
      if ($mc eq "�" && $_ ne "����") { return "1�" } else { return "2�" }
    }
    return "1�";
  }
}

sub mclass {
  local ($_) = shift;
  my ($r) = shift;
  if (/�$/) { return "�" }
  if (/[�ţ]$/ or /��|����|����$/) { return "�" }
  if (/[��]$/) { return "�" }
  if (/�$/) {
    if (/[$sh]�$/ or /[�����]�$/) { return "�" }
    return "�";
  }
  return "�";
}

sub split_oo {
  local ($_) = shift;
  my ($t) = shift;
  if ($t eq "��") { s/(.*)(..)$/$1|$2/; }
  else {
    if (/([$v��])$/) { s/(.)$/|$1/; }
    else { $_ .= "|" }
  }
  $_
}

sub c_du {
  local ($_) = shift;
  s/�/\'�/; s/�/\'�/; s/�/\'�/;
  s/�\|/�j\|/;
  s/�(?![j])/j/;
  s/\'/j/;
  s/�(?![�])/\'/;
  s/\|j/j\|/;
  s/\|\'/\'\|/;
  $_
}

sub c_ud {
  local ($_) = shift;
  s/([^�])\'([������])/$1$2/;
  s/([$c])(j|\|j)/$1\'/;
  s/([$k$sh])�/$1�/;
  s/j\|/\|j/;
  s/\'\|/\|\'/;
  s/[j\']�/�/;
  s/[j\']�/�/;
  s/[j\']�/�/;
  s/[j\']�/�/;
  s/[j\']�/�/;
  s/j/�/;
  s/\'/�/;
  s/\|//g;
  $_
}
