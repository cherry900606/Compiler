%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",#t); return t;};
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",#t,i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",#t,s);}

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];

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

","             {token(',');}
":"             {token(':');}
";"             {token(';');}
"->"    {token(ARROW);}
"("     {token('(');}
")"             {token(')');}
"["             {token('[');}
"]"             {token(']');}
"{"             {token('{');}
"}"             {token('}');}

"+"     {token('+');}
"-"     {token('-');}
"*"     {token('*');}
"/"     {token('/');}
"%"     {token('%');}

"<"     {token('<');}
"<="    {token(LE);}
">="    {token(GE);}
">"     {token('>');}
"=="    {token(EQ);}
"!="    {token(NE);}
"="     {token(ASSIGN);}

"&"     {token(AND);}
"|"     {token(OR);}
"!"     {token(NOT);}

"+="    {token(ADD_ASSIGN);}
"-="    {token(SUB_ASSIGN);}
"*="    {token(MUL_ASSIGN);}
"/="    {token(DIV_ASSIGN);}

"."		{token('.');}

[bB][oO][oO][lL]                {token(BOOL);}
[bB][rR][eE][aA][kK]    {token(BREAK);}
[cC][hH][aA][rR]                {token(CHAR);}
[cC][aA][sS][eE]                {token(CASE);}
[cC][lL][aA][sS][sS]    {token(CLASS);}
[cC][oO][nN][tT][iI][nN][uU][eE]        {token(CONTINUE);}
[dD][eE][cC][lL][aA][rR][eE]    {token(DECLARE);}
[dD][oO]                                {token(DO);}
[eE][lL][sS][eE]                {token(ELSE);}
[eE][xX][iI][tT]                {token(EXIT);}
[fF][aA][lL][sS][eE]    {token(FALSE); yylval.Element.bval = false;}
[fF][lL][oO][aA][tT]    {token(FLOAT);}
[fF][oO][rR]                    {token(FOR);}
[fF][uU][nN]                    {token(FUN);}
[iI][fF]                                {token(IF);}
[iI][nN][tT]                    {token(INT);}
[lL][oO][oO][pP]                {token(LOOP);}
[pP][rR][iI][nN][tT]    {token(PRINT);}
[pP][rR][iI][nN][tT][lL][nN]    {token(PRINTLN);}
[rR][eE][tT][uU][rR][nN]        {token(RETURN);}
[sS][tT][rR][iI][nN][gG]        {token(STRING);}
[tT][rR][uU][eE]                {token(TRUE); yylval.Element.bval = true;}
[vV][aA][lL]                    {token(VAL);}
[vV][aA][rR]                    {token(VAR);}
[wW][hH][iI][lL][eE]    {token(WHILE);}
[iI][nN]				{token(IN);}
[rR][eE][aA][dD]	{token(READ);}


{integer} {
        tokenString(INTEGER, yytext);
        yylval.Element.ival = atoi(yytext);
        return INTEGER;
 }
{identifier} {
        tokenString(IDENTIFIER, yytext);
		yylval.Element.sval = strdup(yytext);
        return IDENTIFIER;
}
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
		yylval.Element.sval = strdup(s);
        return STRING;
}
{real} {
        tokenString(REAL, yytext);
		yylval.Element.fval = atof(yytext);
        return REAL;
}



"/*"    {
        LIST;
        BEGIN CMNT;
}
<CMNT>\n        {
        LIST;
		        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
}
<CMNT>. {LIST;}
<CMNT>"*/"      {
        LIST;
        BEGIN INITIAL;
}

"//"[^\n]*      {LIST;}

\n {

        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
}
[ \t]*  {LIST;}
. {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
}
%%
