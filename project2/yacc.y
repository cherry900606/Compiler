%{
#include <iostream>
#include <string>
#include <stdio.h>
#include "symbolTable.h"

using namespace std;

symbolTables sts;

#define Trace(t)        printf(t)

extern "C" {int yyerror(const char *s);}
extern int yylex(void);

%}

%union
{
	struct  e{
		int ival;
		float fval;
		char *sval;
		bool bval;
		int dtype;
	}Element;
}

%token<Element> INTEGER
%token<Element> IDENTIFIER
%token<Element> REAL
%token<Element> STRING
%token<Element> FALSE TRUE
%token BOOL BREAK CHAR CASE CLASS CONTINUE DECLARE DO EXIT ELSE FLOAT FOR FUN IF INT LOOP PRINT PRINTLN RETURN VAL VAR WHILE
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%token LE GE EQ NE ASSIGN AND OR NOT
%token ARROW READ IN

%type<Element> data_type optional_type 
%type<Element> constant_expression optional_assign
%type<Element> expression

%left '+' '-'
%left '*' '/' '%'
%left LE GE EQ NE '<' '>' AND OR NOT
%right ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN ASSIGN
%nonassoc UMINUS
%%
program:
	CLASS IDENTIFIER '{' {sts.push_table($2.sval);}
	declarations '}' {Trace("Reducing to program\n"); sts.dump_table();}
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
	VAL IDENTIFIER optional_type ASSIGN expression { 
		Trace("Reducing to constant_declaration\n");
		
		if($3.dtype != Non_type && $3.dtype != $5.dtype)
			yyerror("data type and expr type are not matched!");
			
		Val v;
		v.isInit = true;
		if($5.dtype == Int_type) v.ival = $5.ival;
		else if($5.dtype == Float_type) v.fval = $5.fval;
		else if($5.dtype == String_type) v.sval = $5.sval;
		else if($5.dtype == Bool_type) v.bval = $5.bval;
		
		Entry e;
		e = createEntry($2.sval, $5.dtype, Val_type, v);
		int result = sts.lookup_entry(e);
		if(result == -1)
			sts.insert_entry(e);
		else
			yyerror("this val is already existed!\n");
	}
;
var_declaration:
	VAR IDENTIFIER optional_type optional_assign {
		Trace("Reducing to var_declaration\n");
		
		if($3.dtype != Non_type && $4.dtype!= Non_type && $3.dtype != $4.dtype)
			yyerror("data type and expr type are not matched!");
			
		Val v;
		v.isInit = true;
		int type;
		if($3.dtype != Non_type) type = $3.dtype;
		else if($4.dtype != Non_type) type = $4.dtype;
		else type = Non_type;
		
		Entry e;
		e = createEntry($2.sval, type, Var_type, v);
		int result = sts.lookup_entry(e);
		if(result == -1)
			sts.insert_entry(e);
		else
			yyerror("this var is already existed!\n");
	}
;
array_declaration:
	VAR IDENTIFIER ':' data_type '[' INTEGER ']'  {
		Trace("Reducing to array_declaration\n");
		
		Entry e;
		Val v;
		e = createEntry($2.sval, $4.dtype, Arr_type, v, $6.ival);
		int result = sts.lookup_entry(e);
		if(result == -1)
			sts.insert_entry(e);
		else
			yyerror("this arr is already existed!\n");
	}
;
func_declaration:
	FUN IDENTIFIER  {
		/* add func to symbol table first */
		Entry e; Val v;
		e = createEntry($2.sval, Non_type, Func_type, v);
		int result = sts.lookup_entry(e);
		if(result == -1)
			sts.insert_entry(e);
		else
			yyerror("this arr is already existed!\n");
		
		/* then add new symbol table for new scope */
		sts.push_table($2.sval);
	}
	'(' optional_arguments ')' optional_type {
		printf("=======%d\n", $7.dtype);
	}
	block  {
		Trace("Reducing to func_declaration\n"); 
		sts.dump_table(); 
		sts.pop_table();
		}
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
	IDENTIFIER ':' data_type  { 
		Trace("Reducing to argument\n");
		
		/* add func arguments into func's own symbol table */
		Entry e; Val v;
		e = createEntry($1.sval, $3.dtype, Var_type, v);
		int result = sts.lookup_entry(e);
		if(result == -1)
			sts.insert_entry(e);
		else
			yyerror("this var is already existed!\n");
	}
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
	| expression '*' expression {Trace("Reducing to expression\n");}
	| expression '/' expression {Trace("Reducing to expression\n");}
	| expression '%' expression {Trace("Reducing to expression\n");}
	| expression '+' expression {Trace("Reducing to expression\n");}
	| expression '-' expression {Trace("Reducing to expression\n");}
	| expression '<' expression {Trace("Reducing to expression\n");}
	| expression '>' expression {Trace("Reducing to expression\n");}
	| expression LE expression {Trace("Reducing to expression\n");}
	| expression GE expression {Trace("Reducing to expression\n");}
	| expression EQ expression {Trace("Reducing to expression\n");}
	| expression NE expression {Trace("Reducing to expression\n");}
	| expression OR expression {Trace("Reducing to expression\n");}
	| expression AND expression {Trace("Reducing to expression\n");}
	| NOT expression {Trace("Reducing to expression\n");}
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
	':' data_type { 
		$$.dtype = $2.dtype;
		Trace("Reducing to optional_type\n");}
	|  {
		$$.dtype = Non_type;
		
		Trace("Reducing to optional_type\n");
		}
;
optional_assign:
	ASSIGN expression  { $$.dtype = $2.dtype; Trace("Reducing to optional_assign\n");}
	|   { $$.dtype = Non_type; Trace("Reducing to optional_assign\n");}
;
data_type:
	INT {
		$$.dtype = Int_type;
		Trace("Reducing to data_type\n");
		}
	| STRING {
		$$.dtype = String_type;
		Trace("Reducing to data_type\n");
		}
	| FLOAT {
		$$.dtype = Float_type;
		Trace("Reducing to data_type\n");
		}
	| BOOL {
		$$.dtype = Bool_type;
		Trace("Reducing to data_type\n");
		}
;
constant_expression:
	INTEGER {
		$$.ival = $1.ival;
		$$.dtype = Int_type;
		Trace("Reducing to constant_expression\n");}
	| REAL {
		$$.fval = $1.fval;
		$$.dtype = Float_type;
		Trace("Reducing to constant_expression\n");}
	| STRING{
		$$.sval = $1.sval;
		$$.dtype = String_type;
		Trace("Reducing to constant_expression\n");
		}
	| TRUE {
		$$.bval = $1.bval;
		$$.dtype = Bool_type;
		Trace("Reducing to constant_expression\n");
		}
	| FALSE {
		$$.bval = $1.bval;
		$$.dtype = Bool_type;
		Trace("Reducing to constant_expression\n");
		}

%%
int yyerror(const char *s)
{
        fprintf(stderr, "%s\n", s);
		exit(-1);
        return 0;
}
int main(void)
{
        yyparse();
         return 0;
}