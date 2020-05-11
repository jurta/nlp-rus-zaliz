#!/usr/bin/perl

while(<>=~/^$/) { }
$header = <>; chomp($header); chop($header);
@headers = ($header =~ /(\S+\s*)/g);
splice(@headers,$#headers);
foreach $h (@headers) { $regex .= "("."."x(length($h)).")"; }
$regex .= "(.*)";

while($eof<2) {
    if(!$eof) { $_=<>; chomp; chop; @in = (/^$regex/); }
    if($in[0] =~ /\d/ || $eof) {
        if(defined @acc) {
            foreach (@acc) { s/(^\s*)|(\s*$)//g; s/\s\s+/ /g; }
            print join("\t",@acc), "\n";
        }
        @acc = @in;
    } else {
        for $i (0..$#acc) { $acc[$i] .= " ".$in[$i]; }
    }
    if(eof()) { $eof++; }
}
