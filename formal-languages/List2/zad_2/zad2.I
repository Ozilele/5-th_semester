
%{
#include<stdio.h>
#include <string.h>
int in_comment = 0;
int commentDone = 0;
int hyphenCount = 0;
int in_xml_tag = 0;
int doubleQuote = 0;
int i = 0;
int invalid_com = 0;
char saved_comment_text[1024];
char beg[4] = { '<', '!', '-', '-' };
%}

%option noyywrap

%%
"<!--" {
    if(!in_xml_tag) {
        in_comment = 1;
        commentDone = 0;
        i = 0;
        for(int a = 0; a < strlen(saved_comment_text); a++) {
            saved_comment_text[a] = '\0';
        }
        for(int k = 0; k < strlen(beg); k++) {
            saved_comment_text[k] = beg[k];
            i++;
        }
        saved_comment_text[i] = '\0';
        // printf("len is %lu", strlen(saved_comment_text));
    } else {
        printf("<!--");
    }
}
"-->" { 
    if(in_comment) {
        in_comment = 0;
        commentDone = 1;
    } else {
        if(in_xml_tag || invalid_com) {
            printf("-->");
        }
    }
}
"<" {   /* Znak "<" wewnątrz komentarza XML */
    if(!in_comment) {
        in_xml_tag = 1;
        putchar('<');
    }
}

">" {   /* Znak ">" wewnątrz komentarza XML */
    if(in_xml_tag && !doubleQuote) {
        putchar('>');
        in_xml_tag = 0;
    } else if(doubleQuote) {
        putchar('>');
    }
}

"\"" {
    if(!doubleQuote) {
        doubleQuote = 1;
    } else {
        doubleQuote = 0;
    }
    printf("\"");
}

"-" { // hyphen sign
    hyphenCount++;
    if(hyphenCount == 2 && in_comment) {
        in_comment = 0;
        invalid_com = 1;
        for(int i = 0; i < strlen(saved_comment_text); i++) {
            printf("%c", saved_comment_text[i]);
        }
        putchar('-');
        putchar('-');
    }
}


[^<>"\""-]+ {
    if(!in_comment) {
        if(!commentDone) {
            printf("%s", yytext);
        } else {
            for(int i = 0; i < yyleng; i++) {
                putchar(' ');
            }
            putchar('\n');
            commentDone = 0;
        }
    } else { // current lexem is in comment
        for(int j = 0; j < strlen(yytext); j++) {
            saved_comment_text[i] = yytext[j];
            i++;
        }
        saved_comment_text[i] = '\0';
        i++;
        // printf("Lenght of doc is %lu", strlen(saved_comment_text));
        for(int z = 0; z <= strlen(saved_comment_text); z++) {
            // printf("%c\n", saved_comment_text[z]);
        }
        putchar(' ');
    }
}
%%

// the string -- must not occur within comments, W komentarzach nie można rozpoznawać odwołań do encji parametrów.
int main(int argc, char **argv) {
    extern FILE *yyin, *yyout;
    yyin = fopen("test.xml", "r");
    yyout = fopen("out.xml", "w");
    yylex();
    return 0;
}

