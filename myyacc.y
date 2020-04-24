%{
	#include "myyacc.h"
	#define YYSTYPE node
	int yyerror();
	int yyerror(char* msg);
	extern int yylex();
	codelist* list;
%}
%token BASIC NUMBER INT8 INT16 REAL ID TRUE FALSE
%token INT LONG CHAR BOOL FLOAT DOUBLE
%token REL
%token IF ELSE WHILE DO BREAK FOR SWITCH CASE DEFAULT 
%token OR AND
%left OR
%left AND
%right '!'
%left '+' '-'
%left '*' '/'
%right UMINUS
%right INC DEC
%%
program : block 		{  }
	    ;
block 	: '{' decls statementlist '}' { }
	    ;
decls	: decls decl		{  }
	    |		  	       {  }
	;
decl	: type ID ';'		{  }
	    ;
type	: type '[' NUMBER ']'	{  }
	    | BASIC			{  }
	    ;
statementlist	: statementlist M statement	{ 
	      backpatch(list, $1.nextlist, $2.instr);
					  $$.nextlist = $3.nextlist; }
	   	        | statement			{ $$.nextlist = $1.nextlist; }
		        ;
statement       : IF '(' boolean ')' M statement ELSE N M statement	 { 
		backpatch(list, $3.truelist, $5.instr);
		backpatch(list, $3.falselist, $9.instr);
		//statement1  goto
		$6.nextlist = merge($6.nextlist, $8.nextlist);
		$$.nextlist = merge($6.nextlist, $10.nextlist);
//		$$.nextlist = $8.nextlist; 
} 
                | IF '(' boolean ')' M statement		{ backpatch(list, $3.truelist, $5.instr);
			$$.nextlist = merge($3.falselist, $6.nextlist);
			//$$.nextlist = $3.falselist; 
}
	            | WHILE M '(' boolean ')' M statement		{ 
backpatch(list, $7.nextlist, $2.instr);
						  backpatch(list, $4.truelist, $6.instr);
						  $$.nextlist = $4.falselist;
						  gen_goto(list, $2.instr);
 }
 | DO M statement M WHILE '(' boolean ')' M ';'	 { backpatch(list, $3.nextlist, $4.instr);
						  backpatch(list, $7.truelist, $9.instr);
						  $$.nextlist = $7.falselist;
						  gen_goto(list, $2.instr); }
	            | FOR '(' assignment ';' M boolean ';' M assignment ')' N M statement  { backpatch(list, $6.truelist, $12.instr);
								backpatch(list, $11.nextlist, $5.instr);
								backpatch(list, $13.nextlist, $8.instr);
								$$.nextlist = $6.falselist;
								gen_goto(list, $8.instr); }
 | BREAK ';'				{  }
	            | '{' statementlist '}'			{ $$.nextlist = $2.nextlist; } 
	            | assignment ';'				{ $$.nextlist = NULL; }
	            ;
assignment	: ID '=' boolean  		{ copyaddr(&$1, $1.lexeme); gen_assignment(list, $1, $3); }
	            ;
loc	            : loc '[' boolean ']'	{  }
	            | ID			{ copyaddr(&$$, $1.lexeme); }
	            ;
boolean	        : boolean OR M boolean	{ backpatch(list, $1.falselist, $3.instr);
				  $$.truelist = merge($1.truelist, $4.truelist);
				  $$.falselist = $4.falselist; }
	            | boolean AND M boolean	{ backpatch(list, $1.truelist, $3.instr);
				  $$.truelist = $4.truelist;
				  $$.falselist = merge($1.falselist, $4.falselist); }
	             | '!' boolean		{ $$.truelist = $1.falselist;
				  $$.falselist = $1.truelist; }
	             | '(' boolean ')'		{ $$.truelist = $1.truelist; 
				  $$.falselist = $1.falselist; }
	             | expression REL expression		{ $$.truelist = new_instrlist(nextinstr(list));
				  $$.falselist = new_instrlist(nextinstr(list)+1);
				  gen_if(list, $1, $2.oper, $3);
				  gen_goto_blank(list); }
	             | TRUE			{ copyaddr(&$$, "TRUE");
				  gen_goto_blank(list); }
	             | FALSE			{ copyaddr(&$$, "FALSE");
				  gen_goto_blank(list); }
	             | expression			{ copyaddr_fromnode(&$$, $1); }
	             ;
M	             : 			{ $$.instr = nextinstr(list); }
	             ;
N	             :			{ $$.nextlist = new_instrlist(nextinstr(list));
				  gen_goto_blank(list); }
	             ;
expression	     : expression '+' expression		{ new_temp(&$$, get_temp_index(list)); gen_3addr(list, $$, $1, "+", $3); }
	             | expression '-' expression		{ new_temp(&$$, get_temp_index(list)); gen_3addr(list, $$, $1, "-", $3); }
	             | expression '*' expression		{ new_temp(&$$, get_temp_index(list)); gen_3addr(list, $$, $1, "*", $3); }
	             | expression '/' expression		{ new_temp(&$$, get_temp_index(list)); gen_3addr(list, $$, $1, "/", $3); }
	             | '-' expression %prec UMINUS	{ new_temp(&$$, get_temp_index(list)); gen_2addr(list, $$, "-", $2); }
	             | loc			{ copyaddr_fromnode(&$$, $1); }
	             | NUMBER		{ copyaddr(&$$, $1.lexeme); }
	             | REAL			{ copyaddr(&$$, $1.lexeme); }
	             | INT8		{copyaddr(&$$, $1.lexeme);}
		     | INT16		{copyaddr(&$$, $1.lexeme);}
;
%%
int yyerror(char* msg)
{
	printf("\nERROR with message: %s\n", msg);
	return 0;
}
int main()
{
	list = newcodelist();
//	freopen("text.in.txt", "rt+", stdin);
//	freopen("text.out.txt", "wt+", stdout);
	yyparse();
	print(list);
//	fclose(stdin);
//	fclose(stdout);
	return 0;
}
