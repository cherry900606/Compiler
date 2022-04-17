CC=g++

scanner: lex.yy.c symbolTable.h
	$(CC) lex.yy.c -lfl
lex.yy.c: scanner.l
	lex scanner.l
clean:
	rm *.o lex.yy.c