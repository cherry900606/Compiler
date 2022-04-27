%{
#include <iostream>
#include <stdio.h>
using namespace std;


#define Trace(t)        printf(t)

extern "C" {int yyerror(const char *s);}
extern int yylex(void);
%}
%token INTEGER
%token IDENTIFIER
%token REAL
%token BOOL BREAK CHAR CASE CLASS CONTINUE DECLARE DO EXIT ELSE FALSE FLOAT FOR FUN IF INT LOOP PRINT PRINTLN RETURN TRUE VAL VAR WHILE STRING
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%token LE GE EQ NE ASSIGN AND OR NOT
%token ARROW READ IN

%left '+' '-'
%left '*' '/' '%'
%left LE GE EQ NE '<' '>' AND OR NOT
%left ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%nonassoc UMINUS
%%
program:
	CLASS IDENTIFIER '{' declarations '}' {Trace("Reducing to program\n");}
;
declarations:
	declaration {Trace("Reducing to declarations\n");}
	| declaration declarations {Trace("Reducing to declarations\n");}
;
declaration:
	constant_declaration {Trace("Reducing to declaration\n");}
	| var_declaration  {Trace("Reducing to declaration\n");}
	| array_declaration {Trace("Reducing to declaration\n");}
	| func_declaration  {Trace("Reducing to declaration\n");}
;

constant_declaration: 
	VAL IDENTIFIER optional_type ASSIGN expression {Trace("Reducing to constant_declaration\n");}
;
var_declaration:
	VAR IDENTIFIER optional_type optional_assign {Trace("Reducing to var_declaration\n");}
;
array_declaration:
	VAR IDENTIFIER ':' data_type '[' INTEGER ']'  {Trace("Reducing to array_declaration\n");}
;
func_declaration:
	FUN IDENTIFIER '(' optional_arguments ')' optional_type block  {Trace("Reducing to func_declaration\n");}
;

optional_arguments:
	arguments   {Trace("Reducing to optional_arguments\n");}
	|   {Trace("Reducing to optional_arguments\n");}
;
arguments:
	argument   {Trace("Reducing to arguments\n");}
	| argument ',' arguments    {Trace("Reducing to arguments\n");}
;
argument:
	IDENTIFIER ':' data_type  {Trace("Reducing to argument\n");}
;
block: 
	'{' statements '}'  {Trace("Reducing to block\n");}
;
statements:
	statement {Trace("Reducing to statements\n");}
	| statement statements  {Trace("Reducing to statements\n");}
;
statement:
	simple  {Trace("Reducing to statement\n");}
	| expression {Trace("Reducing to statement\n");}
	| declaration {Trace("Reducing to statement\n");}
	| conditional_statement  {Trace("Reducing to statement\n");}
	| loop_statement {Trace("Reducing to statement\n");}
;
simple: IDENTIFIER ASSIGN expression {Trace("Reducing to simple\n");}
        | IDENTIFIER '[' expression ']' ASSIGN expression{Trace("Reducing to simple\n");}
        | PRINT expression {Trace("Reducing to simple\n");}
        | PRINT '(' expression ')' {Trace("Reducing to simple\n");}
		| PRINTLN expression {Trace("Reducing to simple\n");}
		| PRINTLN '(' expression ')' {Trace("Reducing to simple\n");}
        | READ IDENTIFIER{Trace("Reducing to simple\n");}
        | RETURN {Trace("Reducing to simple\n");}
        | RETURN expression {Trace("Reducing to simple\n");}
;
expression:
	'-' expression %prec UMINUS{Trace("Reducing to expression\n");}
	| expression '*' expression { $$ = $1 * $3; Trace("Reducing to expression\n");}
	| expression '/' expression { $$ = $1 / $3; Trace("Reducing to expression\n");}
	| expression '%' expression { $$ = $1 % $3; Trace("Reducing to expression\n");}
	| expression '+' expression { $$ = $1 + $3; Trace("Reducing to expression\n");}
	| expression '-' expression { $$ = $1 - $3; Trace("Reducing to expression\n");}
	| expression '<' expression { $$ = $1 < $3; Trace("Reducing to expression\n");}
	| expression '>' expression { $$ = $1 > $3; Trace("Reducing to expression\n");}
	| expression LE expression {$$ = $1 <= $3; Trace("Reducing to expression\n");}
	| expression GE expression {$$ = $1 >= $3; Trace("Reducing to expression\n");}
	| expression EQ expression {$$ = $1 == $3; Trace("Reducing to expression\n");}
	| expression NE expression {$$ = $1 != $3; Trace("Reducing to expression\n");}
	| expression OR expression {$$ = $1 || $3; Trace("Reducing to expression\n");}
	| expression AND expression {$$ = $1 && $3; Trace("Reducing to expression\n");}
	| NOT expression {$$ = !$2; Trace("Reducing to expression\n");}
	| func_invocation {Trace("Reducing to expression\n");}
	| constant_expression {Trace("Reducing to expression\n");}
	| IDENTIFIER '[' expression ']'  {Trace("Reducing to expression\n");}
	| IDENTIFIER {Trace("Reducing to expression\n");}
; 
loop_statement:
	while_statement {Trace("Reducing to loop_statement\n");}
	| for_statement {Trace("Reducing to loop_statement\n");}
;
while_statement:
	WHILE '(' expression ')' block_or_simple {Trace("Reducing to while_statement\n");}
;
for_statement:
	FOR '(' IDENTIFIER IN INTEGER '.' '.' INTEGER ')' block_or_simple
	{Trace("Reducing to for_statement\n");}
;
conditional_statement:
	IF '(' expression ')' block_or_simple optional_else {Trace("Reducing to conditional_statement\n");}
;
optional_else:
	ELSE block_or_simple {Trace("Reducing to optional_else\n");}
	| {Trace("Reducing to optional_else\n");}
;
block_or_simple:
	block {Trace("Reducing to block_or_simple\n");}
	| simple {Trace("Reducing to block_or_simple\n");}
;
func_invocation:
		IDENTIFIER '(' optional_parameters ')'  {Trace("Reducing to func_invocation\n");}
;
optional_parameters:
	parameters {Trace("Reducing to optional_parameters\n");}
	|  {Trace("Reducing to optional_parameters\n");}
;
parameters:
	parameter {Trace("Reducing to parameters\n");}
	| parameter ',' parameters {Trace("Reducing to parameters\n");}
;
parameter:
	expression {Trace("Reducing to parameter\n");}
;
	
optional_type:
	':' data_type {Trace("Reducing to optional_type\n");}
	|
;
optional_assign:
	ASSIGN expression  {Trace("Reducing to optional_assign\n");}
	|
;
data_type:
	INT {Trace("Reducing to data_type\n");}
	| STRING {Trace("Reducing to data_type\n");}
	| FLOAT {Trace("Reducing to data_type\n");}
	| BOOL {Trace("Reducing to data_type\n");}
;
constant_expression:
	INTEGER { $$ = $1; Trace("Reducing to constant_expression\n");}
	| REAL{ $$ = $1; Trace("Reducing to constant_expression\n");}
	| STRING{ $$ = $1; Trace("Reducing to constant_expression\n");}
	| TRUE {Trace("Reducing to constant_expression\n");}
	| FALSE {Trace("Reducing to constant_expression\n");}

%%
int yyerror(const char *s)
{
        fprintf(stderr, "%s\n", s);
        return 0;
}
int main(void)
{
        yyparse();
         return 0;
}