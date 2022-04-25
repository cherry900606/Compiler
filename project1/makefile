CC=g++

scanner: lex.yy.c
	$(CC) lex.yy.c -ll
lex.yy.c: scanner.l
	lex scanner.l
clean:
	rm lex.yy.c
