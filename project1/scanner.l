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
string \"(\"\"|.)*\"
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
[bB][oO][oO][lL]                {token(BOOL);}
[bB][rR][eE][aA][kK]            {token(BREAK);}
[cC][hH][aA][rR]                {token(CHAR);}
[cC][aA][sS][eE]                {token(CASE);}
[cC][lL][aA][sS][sS]            {token(CLASS);}
[cC][oO][nN][tT][iI][nN][uU][eE]        {token(CONTINUE);}
[dD][eE][cC][lL][aA][rR][eE]    {token(DECLARE);}
[dD][oO]                        {token(DO);}
[eE][lL][sS][eE]                {token(ELSE);}
[eE][xX][iI][tT]                {token(EXIT);}
[fF][aA][lL][sS][eE]            {token(FALSE);}
[fF][lL][oO][aA][tT]            {token(FLOAT);}
[fF][oO][rR]                    {token(FOR);}
[fF][uU][nN]                    {token(FUN);}
[iI][fF]                        {token(IF);}
[iI][nN][tT]                    {token(INT);}
[lL][oO][oO][pP]                {token(LOOP);}
[pP][rR][iI][nN][tT]            {token(PRINT);}
[pP][rR][iI][nN][tT][lL][nN]    {token(PRINTLN);}
[rR][eE][tT][uU][rR][nN]        {token(RETURN);}
[sS][tT][rR][iI][nN][gG]        {token(STRING);}
[tT][rR][uU][eE]		{token(TRUE);}
[vV][aA][lL]                    {token(VAL);}
[vV][aA][rR]                    {token(VAR);}
[wW][hH][iI][lL][eE]            {token(WHILE);}

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
	s[index]='\0';
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