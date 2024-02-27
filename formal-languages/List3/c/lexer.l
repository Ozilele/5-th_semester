%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"

extern int yylex();
%}

%%
[ \t]             ;
^#(.|\\\n)*\n     ;
\\\n              ;
[[:blank:]]+      ;
[0-9]+            { yylval = atoi(yytext); return NUM; }
"("               { return '('; }
")"               { return ')'; }
"+"               { return '+'; }
"-"               { return '-'; }
"*"               { return '*'; }
"/"               { return '/'; }
"^"               { return '^'; }
\n                { return '\n'; }
.                 { return ERR; }
%%
