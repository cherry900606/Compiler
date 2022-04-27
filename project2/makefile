CC=g++

all: lex.yy.c y.tab.c
	$(CC) lex.yy.c y.tab.c -lfl
lex.yy.c: scanner.l
	lex scanner.l
y.tab.c: yacc.y
	yacc -d yacc.y
