%{
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",#t);}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",#t,i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",#t,s);}

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];

#include <map>
#include <vector>
#include <iostream>
using namespace std;

class symbolTable
{
public:
	symbolTable() { this->count = 0; };
	void create() {}
	int lookup(string s);
	int insert(string s);
	int dump();

private:
	map<string, int> entry; // id_name, index
	int count; // the size of symbol table
	vector<string> record; // record all entries of the sybol table
};

symbolTable st;

%}
extern "C" {int yylex(void);}
%option noyywrap

%x CMNT

digit [0-9]
integer {digit}+
letter [a-zA-Z]
identifier {letter}({digit}|{letter})*
real [-+]?{integer}\.{integer}?([Ee][-+]?{digit})?
string (\"(\"\"|.)*\")
%%

 /* delimiters */
","		{token(',');}
":"		{token(':');}
";"		{token(';');}
"->"	{token('->');}
"("     {token('(');}
")"		{token(')');}
"["		{token('[');}
"]"		{token(']');}
"{"		{token('{');}
"}"		{token('}');}

 /* arithmetic & remainder */
"+"		{token('+');}
"-"		{token('-');}
"*"		{token('*');}
"/"		{token('/');}
"%"		{token('%');}

 /* relational & assignment */
"<"		{token('<');}
"<="	{token('<=');}
">="	{token('>=');}
">"		{token('>');}
"=="	{token('==');}
"!="	{token('!=');}
"="		{token('=');}

 /* logical */
"&"		{token('&');}
"|"		{token('|');}
"!"		{token('!');}

 /* compound operators */
"+="	{token('+=');}
"-="	{token('-=');}
"*="	{token('*=');}
"/="	{token('/=');}

 /* keywords & Boolean Constants */
"bool" 	{token(BOOL);}
"break"	{token(BREAK);}
"char"	{token(CHAR);}
"case"	{token(CASE);}
"class"	{token(CLASS);}
"continue"	{token(CONTINUE);}
"declare"	{token(DECLARE);}
"do"	{token(DO);}
"else"	{token(ELSE);}
"exit"	{token(EXIT);}
"false"	{token(FALSE);}
"float"	{token(FLOAT);}
"for"	{token(FOR);}
"fun"	{token(FUN);}
"if"	{token(IF);}
"int"	{token(INT);}
"loop"	{token(LOOP);}
"print"	{token(PRINT);}
"println"	{token(PRINTLN);}
"return"	{token(RETURN);}
"string"	{token(STRING);}
"true"	{token(TURE);}
"val"	{token(VAL);}
"var"	{token(VAR);}
"while"	{token(WHILE);}

 /* Integer Constants */
{integer} {tokenString(INTEGER, yytext);}
 
 /* Identifiers */
{identifier} {
	tokenString("id", yytext);
	st.insert(yytext);
}
 
  /* Real Constants */
{real} {tokenString(REAL, yytext);}
 
 /* String Constants */
{string} {
	char s[MAX_LINE_LENG];
	int index = 0;
	for(int i=1;i<yyleng-1;i++)
	{
		if(yytext[i]=='"')
			i+=1;
		s[index++]=yytext[i];
	}
	tokenString(STRING, s);
}

 /* Comments */
"/*"	{
	LIST;
	BEGIN CMNT;
}
<CMNT>\n	{
	LIST;
	printf("%d: %s", linenum++, buf);
	buf[0] = '\0';
}
<CMNT>.	{LIST;}
<CMNT>"*/"	{
	LIST;
	BEGIN INITIAL;
}

"//"[^\n]*	{LIST;}

 /* Others */

\n      {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }

[ \t]*  {LIST;}

.       {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }
%%
int symbolTable::lookup(string s)
{
	if (entry.count(s))
		return entry[s];
	return -1; // not found
}

int symbolTable::insert(string s)
{
	if(this->lookup(s)!=-1) return this->lookup(s);
	entry[s] = count;
	count++;
	record.push_back(s);
	return entry[s];
}

int symbolTable::dump()
{
	for (int i = 0; i < count; i++)
		cout << record[i] << endl;
	return 0;
}

int main()
{
	yylex();
	printf("\nSymbol Table:\n");
	st.dump();
}