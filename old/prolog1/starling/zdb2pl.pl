#!/usr/bin/perl -w
# -*- mode: Perl; coding: cyrillic-koi8; -*-
# $Id$
# Copyright (c) 2000  Juri Linkov <juri@eta.org>
# This file is distributed under the terms of the GNU GPL.

while(<>) {
    ($accent, $comments, $fak, $symbol, $num) = (0, "", "", "", 0);
    ($recno,$word,$grammar,$trans) = split /\t/;
    $word =~ s/\s+//g; if($trans =~ s/^\)//) { $grammar .= ")"; } # hacks
    if($grammar =~ s/^([0-9,.]+)\s*//) { $accent = $1; }
    if($grammar =~ s/\(_(.*)_\)//) { $comments = $1; }
    if($grammar =~ s/\[(.*)\]//) { $fak = $1; }
    if($grammar =~ s/^(\S+)\s*//) { $symbol = $1; }
    if($grammar =~ s/^(\d+)\s*//) { $num = $1; }
#      print "$word : $accent : $symbol : $num : $grammar : $fak : $comments\n";
    print "w('$word',a($accent),'$symbol',$num,a(а),\"*\",1,'#9').";
    if($comments) { print " % $comments"; }
    print "\n";

}

#  w('авторизованный',a(8),'п',1,a(а),"*",1,'#9').
#      374 авторизованный       8 п 1*а"1", #9       authorized           
