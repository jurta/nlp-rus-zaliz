#!/usr/bin/perl
# decoder -c=ak < ~/doc/lang/rus/star/m_a | perl -p acc.pl | less

    s/ˆ/Á\'/g;
    s/Š/Å\'/g;
    s//£\'/g;
    s//É\'/g;
    s/‘/Ï\'/g;
    s/–/Õ\'/g;
    s/š/Ù\'/g;
    s/œ/Ü\'/g;
    s//À\'/g;
    s/¢/Ñ\'/g;
