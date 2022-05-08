%{
#include <iostream>
#include <string>
#include <stdio.h>
#include <vector>
#include "symbolTable.h"

using namespace std;

symbolTables sts;
map<string, vector<int>> funcArgs; /* func name, args type */

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

 /* token with type (to store info) */
%token<Element> INTEGER
%token<Element> IDENTIFIER
%token<Element> REAL
%token<Element> STRING
%token<Element> FALSE TRUE
%token BOOL BREAK CHAR CASE CLASS CONTINUE DECLARE DO EXIT ELSE FLOAT FOR FUN IF INT LOOP PRINT PRINTLN RETURN VAL VAR WHILE
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%token LE GE EQ NE ASSIGN AND OR NOT
%token ARROW READ IN

 /* non-terminal with type (to store info) */
%type<Element> data_type optional_type 
%type<Element> constant_expression optional_assign
%type<Element> expression

 /* operator with precedence */
%left OR
%left AND
%left NOT
%left LE GE EQ NE '<' '>'
%left '+' '-'
%left '*' '/' '%'

%right ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN ASSIGN

%nonassoc UMINUS
%%
program:
	CLASS IDENTIFIER '{' {
		/* initilize system table */
		sts.push_table($2.sval);
	}
	declarations '}' {
		Trace("Reducing to program\n"); 
		sts.dump_table();
		
		if(sts.allFuncCount == 0)
			yyerror("program must have at least one method");
	}
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
		/* make sure the ID is not exist, and then insert into symbol table */
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
		
		/* if the statment specify the data type, then it must be correct */ 
		if($3.dtype != Non_type && $4.dtype!= Non_type && $3.dtype != $4.dtype)
			yyerror("data type and expr type are not matched!");
			
		/* The default data type is int */
		int type;
		if($3.dtype != Non_type) type = $3.dtype;
		else if($4.dtype != Non_type) type = $4.dtype;
		else type = Int_type;
		
		Val v;
		if($4.dtype == Non_type) v.isInit = false;
		else
		{
			v.isInit = true;
			if($4.dtype == Int_type) v.ival = $4.ival;
			else if($4.dtype == Float_type) v.fval = $4.fval;
			else if($4.dtype == String_type) v.sval = $4.sval;
			else if($4.dtype == Bool_type) v.bval = $4.bval;
		}
		
		
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
			yyerror("this func is already existed!\n");
		sts.nowFuncName = $2.sval;
		
		/* then add new symbol table for new scope */
		sts.push_table($2.sval);
		/* now is in the function declartion */
		sts.nowIsFunc = true;
	}
	'(' optional_arguments ')' optional_type {
		/* record the function return type */
		sts.setFuncTpye($7.dtype);
		sts.nowFuncType = $7.dtype;
	}
	block {
			Trace("Reducing to func_declaration\n"); 
			/* leave the block, and then dump the local symbol table */
			sts.dump_table(); 
			sts.pop_table();
			
			sts.nowIsFunc = false;
			sts.allFuncCount += 1;
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
		if(result == -1) {
			sts.insert_entry(e);
			funcArgs[sts.nowFuncName].push_back($3.dtype);
		}
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
simple: IDENTIFIER ASSIGN expression {
			Trace("Reducing to simple\n");
			
			int result = sts.lookup_entry_global($1.sval);
			if(result == -1)
				yyerror("the identifier is not defined!\n");
			
			Entry* ptr = sts.getEntry($1.sval);
			if(ptr->dataType != $3.dtype)
				yyerror("type match error\n");
			if(ptr->entryType == Val_type)
				yyerror("val constant can't be reassigned\n");
			}
        | IDENTIFIER '[' expression ']' ASSIGN expression{
			Trace("Reducing to simple\n");
			
			int result = sts.lookup_entry_global($1.sval);
			if(result == -1)
				yyerror("the identifier is not defined!\n");
				
			Entry* ptr = sts.getEntry($1.sval);
			if(ptr->dataType != $6.dtype)
				yyerror("type match error\n");
			if($3.dtype != Int_type)
			yyerror("array index must be integer!\n");
		}
        | PRINT expression {Trace("Reducing to simple\n");}
        | PRINT '(' expression ')' {Trace("Reducing to simple\n");}
		| PRINTLN expression {Trace("Reducing to simple\n");}
		| PRINTLN '(' expression ')' {Trace("Reducing to simple\n");}
        | READ IDENTIFIER{
			Trace("Reducing to simple\n");
			
			int result = sts.lookup_entry_global($2.sval);
			if(result == -1)
				yyerror("the identifier is not defined!\n");
		}
        | RETURN {
			Trace("Reducing to simple\n");
			if(sts.nowIsFunc && sts.nowFuncType != Non_type)
				yyerror("func return type error\n");
		}
        | RETURN expression {
				Trace("Reducing to simple\n");
				
				if(sts.nowIsFunc)
				{
					if(sts.nowFuncType == Non_type)
						yyerror("func doesn't return\n");
					if(sts.nowFuncType != $2.dtype)
						yyerror("func return type error\n");
				}
			}
;
expression:
	'-' expression %prec UMINUS{
			Trace("Reducing to expression\n");
			
			if($2.dtype != Int_type && $2.dtype != Float_type)
				yyerror("type error\n");
			$$.ival = -1 * $2.ival;
		}
	| expression '*' expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			if($1.dtype == String_type || $1.dtype == Bool_type || $3.dtype == String_type || $3.dtype == Bool_type)
				yyerror("type error\n");
			$$.ival = $1.ival * $3.ival;
		}
	| expression '/' expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			if($1.dtype == String_type || $1.dtype == Bool_type || $3.dtype == String_type || $3.dtype == Bool_type)
				yyerror("type error\n");
			$$.ival = $1.ival / $3.ival;
		}
	| expression '%' expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			if($1.dtype == String_type || $1.dtype == Bool_type || $3.dtype == String_type || $3.dtype == Bool_type)
				yyerror("type error\n");
			$$.ival = $1.ival % $3.ival;
		}
	| expression '+' expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			$$.ival = $1.ival + $3.ival;
		}
	| expression '-' expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			$$.ival = $1.ival - $3.ival;
		}
	| expression '<' expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			if($1.dtype == String_type || $1.dtype == Bool_type || $3.dtype == String_type || $3.dtype == Bool_type)
				yyerror("type error\n");
			$$.ival = $1.ival < $3.ival;
		}
	| expression '>' expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			if($1.dtype == String_type || $1.dtype == Bool_type || $3.dtype == String_type || $3.dtype == Bool_type)
				yyerror("type error\n");
			$$.ival = $1.ival > $3.ival;
		}
	| expression LE expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			if($1.dtype == String_type || $3.dtype == String_type)
				yyerror("type error");
		}
	| expression GE expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			if($1.dtype == String_type || $3.dtype == String_type)
				yyerror("type error");
		}
	| expression EQ expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			$$.dtype = Bool_type;
		}
	| expression NE expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != $3.dtype)
				yyerror("types are not the same\n");
			$$.dtype = Bool_type;
		}
	| expression OR expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != Bool_type || $3.dtype != Bool_type)
				yyerror("type error\n");
		}
	| expression AND expression {
			Trace("Reducing to expression\n");
			
			if($1.dtype != Bool_type || $3.dtype != Bool_type)
				yyerror("type error\n");
		}
	| NOT expression {
		Trace("Reducing to expression\n");
		if($2.dtype != Bool_type)
			yyerror("type error\n");
		$$.dtype = Bool_type;
		}
	| func_invocation { Trace("Reducing to expression\n"); }
	| constant_expression {
			Trace("Reducing to expression(constant)\n");
			$$.dtype = $1.dtype;
		}
	| IDENTIFIER '[' expression ']'  {
		Trace("Reducing to expression\n");
		
		int result = sts.lookup_entry_global($1.sval);
		if(result == -1)
			yyerror("the identifier is not defined!\n");
		if($3.dtype != Int_type)
			yyerror("array index must be integer!\n");
	}
	| IDENTIFIER {
		Trace("Reducing to expression\n");
		
		bool ForCondition = false;
		if(sts.nowIsFor && $1.sval == sts.forID) ForCondition = true;
		int result = sts.lookup_entry_global($1.sval);
		if(result == -1 && ForCondition == false)
			yyerror("the identifier is not defined!\n");
			
		Entry* ptr = sts.getEntry($1.sval);
		$$.dtype = ptr->dataType;
		if($$.dtype == Int_type) $$.ival = ptr->val.ival;
		else if($$.dtype == Float_type) $$.fval = ptr->val.fval;
		else if ($$.dtype == Bool_type) $$.bval = ptr->val.bval;
		else if($$.dtype == String_type) $$.sval = ptr->val.sval;
	}
; 
loop_statement:
	while_statement {Trace("Reducing to loop_statement\n");}
	| for_statement {Trace("Reducing to loop_statement\n");}
;
while_statement:
	WHILE '(' expression ')' block_or_simple {
		Trace("Reducing to while_statement\n");
		if($3.dtype == String_type)
			yyerror("WHILE statement condition type error\n");
	}
;
for_statement:
	FOR '(' IDENTIFIER IN INTEGER '.' '.' INTEGER ')' {
		/* now is in the for statement */
		sts.nowIsFor = true;
		/* record the id, and push it into symbol table later */
		sts.forID = $3.sval;
	}
	block_or_simple {
		Trace("Reducing to for_statement\n");
		/* leave the for statment */
		sts.nowIsFor = false;
	}
;
conditional_statement:
	IF '(' expression ')' block_or_simple optional_else {
		Trace("Reducing to conditional_statement\n");
		if($3.dtype == String_type)
			yyerror("IF statement condition type error\n");
	}
;
optional_else:
	ELSE block_or_simple {Trace("Reducing to optional_else\n");}
	| {Trace("Reducing to optional_else\n");}
;
block_or_simple:
	{
		/* create the symbol table for any block */
		sts.push_table("block");
		/* if it is FOR block, then insert the ID record before into symbol table */
		if(sts.nowIsFor == true)
		{
			Entry e; Val v;
			e = createEntry(sts.forID, Non_type, Var_type, v);
			int result = sts.lookup_entry(e);
			if(result == -1)
				sts.insert_entry(e);
		}
			
	} 
	block {
			Trace("Reducing to block_or_simple\n");
			sts.dump_table(); 
			sts.pop_table();
		}
	| simple { Trace("Reducing to block_or_simple\n");}
;
func_invocation:
		IDENTIFIER   {
			Trace("Reducing to func_invocation\n");
			
			int result = sts.lookup_entry_global($1.sval);
			if(result == -1)
				yyerror("the identifier is not defined!\n");
			
			Entry* ptr = sts.getEntry($1.sval);
			if(ptr->dataType == Non_type)
				yyerror("procedure cannot be used in expression\n");
			sts.nowFuncName = $1.sval;
		}'(' optional_parameters ')' {
			if(sts.nowFuncArgCount < funcArgs[sts.nowFuncName].size())
				yyerror("func invocation argument number error\n");
			sts.nowFuncArgCount = 0;
		}
;
optional_parameters:
	parameters { Trace("Reducing to optional_parameters\n");}
	|  {Trace("Reducing to optional_parameters\n");}
;
parameters:
	parameter { Trace("Reducing to parameters\n");	}
	| parameter ',' parameters {Trace("Reducing to parameters\n");}
;
parameter:
	expression {
		Trace("Reducing to parameter\n");
		sts.nowFuncArgCount += 1;
		if(sts.nowFuncArgCount > funcArgs[sts.nowFuncName].size())
			yyerror("func invocation argument number error\n");
		int t = $1.dtype;
		if(funcArgs[sts.nowFuncName][sts.nowFuncArgCount - 1] != t)
			yyerror("func invocation argument error\n");
	}
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
	ASSIGN expression  { 
			Trace("Reducing to optional_assign\n");
			$$.dtype = $2.dtype; 
			
			if($$.dtype == Int_type) $$.ival = $2.ival;
			else if($$.dtype == Float_type) $$.fval = $2.fval;
			else if ($$.dtype == Bool_type) $$.bval = $2.bval;
			else if($$.dtype == String_type) $$.sval = $2.sval;
		}
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
		Trace("Reducing to constant_expression(string)\n");
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