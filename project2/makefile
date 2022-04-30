CC=g++

all: lex.yy.c y.tab.c
	$(CC) lex.yy.c y.tab.c symbolTable.h -lfl
lex.yy.c: scanner.l
	lex scanner.l
y.tab.c: yacc.y
	yacc -d yacc.y
