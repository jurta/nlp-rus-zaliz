/* -*- coding: cyrillic-koi8; -*-
 * $Id$
 *
 * Copyright (c) 2000  Juri Linkov <juri@eta.org>
 * All rights reserved.
 * This file is distributed under the terms of the GNU GPL.
 * See the file LICENSE for redistribution information.
 */

/* Russian stem parser. */
     
%{
#include <stdio.h>
  int i;
  int pos;
  unsigned char *p;
#define P(x) printf("s=%s\n",x)
%}
     
%%

_start
/*  insert generated grammar here */
/*  instead of next */
: 'а' a | 'б' b | 'в' w;
a : 'а' aa | 'в' aw;
aa : 'а';
aw : 'а';
b : 'а';
w : 'а';

%%

/*  Add this before switch (yyn) */
/*    printf("*** %d\n", yyn); */

main ()
{
  p = "скована";
  pos = strlen(p);
  yydebug = 1;
  yyparse ();
}

yylex ()
{
  if (pos < 1)
    return 0;
  --pos;
  printf("c=%c,pos=%d\n", p[pos], pos);
  return p[pos];
}

/*  yylex_orig () { unsigned char ch = *p; printf("c=%c\n",ch); if (ch == '\0') return 0; ++p; return ch; } */
/*  yylex_bak () { if (*p == '\0') return 0; return *++p; } */

yyerror (s)  /* Called by yyparse on error */
char *s;
{
  printf ("%s\n", s);
}
