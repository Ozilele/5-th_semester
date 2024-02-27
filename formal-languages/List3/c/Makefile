main: parser.y lexer.l
		bison -d parser.y
		flex -o zad1.c lexer.l
		gcc -o zad1 parser.tab.c zad1.c

clean:
		rm parser.tab.c parser.tab.h zad1.c zad1
