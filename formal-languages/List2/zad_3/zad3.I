%{
    #include <stdio.h>
    int yylex();
    int yywrap();

    int docs = 0;
%}

%x IN_COMMENT
%x IN_DOCS
%x IN_STRING
%x INCLUDE_WITH_ARROW_HEADS
%x INCLUDE_WITH_DOUBLE_QUOTES

LB  (\\\n)

escapedNewline \\\n


docSingleLine \/{escapedNewline}*\/(\/|!)({escapedNewline}|.)*
docMultilineOpen \/\*(\*|!)

singleLine \/{escapedNewline}*\/({escapedNewline}|.)*
multilineOpen {escapedNewline}*\/{escapedNewline}*\*

multilineClose {escapedNewline}*\*{escapedNewline}*\/
includeWithDoubleQuotes \#include[ \t{LB}]*\"
includeWithArrow \#include[ \t{LB}]*\< 

%%

{includeWithDoubleQuotes} { BEGIN(INCLUDE_WITH_DOUBLE_QUOTES); ECHO; }
{includeWithArrow}      { BEGIN(INCLUDE_WITH_ARROW_HEADS); ECHO; }
\"                      { ECHO; BEGIN(IN_STRING); }
\
{docSingleLine}         { if (docs) ECHO; }
{singleLine}            ;
{docMultilineOpen}      { if (docs) ECHO; BEGIN(IN_DOCS); }
{multilineOpen}         { BEGIN(IN_COMMENT); }

<IN_STRING>{
{escapedNewline}*\"     { ECHO; BEGIN(INITIAL); }
.                       ECHO;
}

<IN_DOCS>{
.|\n                    { if(docs) ECHO; }
{multilineClose}        { if(docs) ECHO; BEGIN(INITIAL); }
}

<IN_COMMENT>{
.|\n                    ;
{multilineClose}        { BEGIN(INITIAL); }
}

<INCLUDE_WITH_ARROW_HEADS>\> { BEGIN(INITIAL); ECHO; }
<INCLUDE_WITH_DOUBLE_QUOTES>\" { BEGIN(INITIAL); ECHO; }

%%

int yywrap() {
    return 1;
}

int main(int argc, char **argv) {
    extern FILE *yyin, *yyout;
    yyin = fopen("test.cpp", "r");
    yyout = fopen("result.cpp", "w");
    yylex();
    return 0;
    return yylex();
}

// include \#include[[:blank:]].*\n
// {include}               ECHO;