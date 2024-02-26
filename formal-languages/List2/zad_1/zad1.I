
%{
#include <stdio.h>

int yywrap();
int yylex();

int line_count = 0;
int word_count = 0;
%}

WHITESPACE [[:blank:]]|\\\n
%s START
%s NEWLINE
%s WORD
%s SPACES

%%
    BEGIN(START);

<NEWLINE,START>{WHITESPACE}|\n ;
<NEWLINE,START><<EOF>> { fclose(yyout); return 0; }
<NEWLINE>. { fprintf(yyout, "\n"); REJECT; }
<NEWLINE,START>. { fprintf(yyout, "%s", yytext); BEGIN(WORD); word_count++; line_count++; }

<WORD>[[:blank:]] BEGIN(SPACES);
<WORD>\\\n ;
<WORD>\n { BEGIN(NEWLINE); }

<SPACES>{WHITESPACE} ;
<SPACES>\n { BEGIN(NEWLINE); }
<SPACES>. { fprintf(yyout, " "); ECHO; BEGIN(WORD); word_count++; }
%%

int yywrap() { 
    printf("\n");
    printf("line count: %d\n", line_count);
    printf("word count: %d\n", word_count);
    return 1; 
} 
int main() { 
    extern FILE *yyin, *yyout;
    yyin = fopen("./tests/l2z1b.txt", "r");
    yyout = fopen("out.txt", "w");
    return yylex();
}

// Biały znak lub sekwencja \\n
// WHITESPACE [[:blank:]]|\\\n
// <SPACES>{WHITESPACE} ; - zignorowanie sekwencji, obsługa kontynuuacji linii w tekście, gdzie \ na końcu linii daje znać ze linia jest kontynuacja poprzedniej
// <SPACES>\n { BEGIN(NEWLINE); } - napotkanie znaku nowej linii przejdzie do stanu, koniec białych znakow miedzy slowami
// <SPACES>. { fprintf(yyout, " "); ECHO; BEGIN(WORD); word_count++; } - Przetwarzanie dowolnego znaku(poza białymi znakami), wystepowanie znaku innego niz \n, co sugeruje nowe slowo
// Znajdując białe znaki w word, przejdź do spaces
// <WORD>[[:blank:]] BEGIN(SPACES); - Obsługa przypadku, kiedy w trakcie analizy słowa wystąpi biały znak, co oznacza koniec słowa
// <WORD>\\\n ; - Ignorowanie sekwencji, obsługa kontynuacji linii w przypadku kiedy słowo jest podzielone miedzy kilkoma liniami
// Napotkanie znaku nowej linii w stanie i przejście do stanu NEWLINE
// <WORD>\n { BEGIN(NEWLINE); } -- Znalezienie nowej linii oznacza koniec slowa 
// <NEWLINE,START>{WHITESPACE}|\n ; - analizator kontynuuje przetwrzanie w obecnym stanie, do momentu znalezienia reguły, ktora pasuje do kolejnego znaku
// <NEWLINE,START><<EOF>> { fclose(yyout); return 0; } - napotkanie konca pliku, zamkniecie pliku wyjsciowego
// <NEWLINE>. { fprintf(yyout, "\n"); REJECT; } - Wypisanie nowej linii, odrzucenie znaku(rozpoczecie analizy od stanu poczatkowego), pozostanie w stanie NEWLINE 
// <NEWLINE,START>. { fprintf(yyout, "%s", yytext); BEGIN(WORD); word_count++; line_count++; } - Napotkano znaku innego niz nowa linia, przejście do stanu

