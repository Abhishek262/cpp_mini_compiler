
%{
    #include <stdio.h>
    #include <stdlib.h>
	int yylex();
	int yydebug = 0;
	extern int yylineno;
	extern int st[100];
	extern int top;
	extern int count;
	extern void display();
	extern void insert_in_st(char*, char*, int, char*);
	void yyerror(const char *s);
%}

%locations

%union {
	struct parse_node
	{
		char *str;
		char *type;
		int intval;
		double floatval;
		struct ast_node * ast;
	}s;
}

%token <s> T_keyword T_int T_main T_type T_return T_for T_if T_else T_while T_InputStream T_OutputStream 
%token <s> T_openParenthesis T_closedParanthesis T_openFlowerBracket T_closedFlowerBracket 
%token <s> T_RelationalOperator T_LogicalOperator T_UnaryOperator 
%token <s> T_AssignmentOperator  T_Semicolon T_identifier T_numericConstants T_stringLiteral
%token <s> T_character T_plus T_minus T_mod T_divide T_multiply
%token <s> T_whiteSpace T_shortHand
%token <s> T_switch T_case T_break T_default T_struct T_class T_namespace T_array T_caseop T_include T_comma T_dot T_colon
%token <s> T_float T_double T_long
%token <s> T_intVal T_longVal T_doubleVal T_floatVal T_bool T_bool_true T_bool_false

%left T_LogicalAnd T_LogicalOr
%left T_less T_less_equal T_greater T_greater_equal T_equal_equal T_not_equal
%left T_plus T_minus
%left T_multiply T_divide T_mod



%%

S
      : Start {printf("Input accepted.\n");exit(0);}
      ;

Start : T_include Start
	  | Main

Main 	: T_type T_main T_openParenthesis T_closedParanthesis Body
		;

Body	: T_openFlowerBracket  T_closedFlowerBracket
		;

C 	: C statement T_Semicolon
	| C LOOPS	
	| statement


/* This production assumes flower bracket has been opened*/
block_end_flower : stmt Multiple_stmts 
				 | closeflower

/*This takes care of statements like if(...);. Note that to include multiple statements, a block has to open with a flower bracket*/
block   : openflower block_end_flower
	    | stmt
	    | T_Semicolon
		;

/* block would cover anything following statement. consider the for statement for example. All possiblities are:
for(expr;expr;expr);													(block -> ;)
for(...) stmt          , where stmt contains T_Semicolon				(block -> stmt)
for(...){}																(block -> {block_end_flower -> {})
for(...){stmt, stmt, stmt, ...}											(block -> {block_end_flower -> {smt Multiple_stmts})
for(...){stmt, if/while/for{stmt, stmt.}} , this is achieved implicity because stmt in previous can in turn be if or for while
*/


Multiple_stmts  : stmt Multiple_stmts
				| closeflower
				;

stmt    : expr T_Semicolon					{/*Statement cannot be empty, block takes care of empty string*/}
		| if_stmt
		| switch_stmt
		| while_stmt
		| for_stmt
		| Assignment_stmt T_Semicolon
		| error T_Semicolon
		;

for_stmt : T_for T_openParenthesis expr_or_empty_with_semicolon_and_assignment  expr_or_empty_with_semicolon_and_assignment  expr_or_empty_with_assignment_and_closed_parent  block	

while_stmt : T_while T_openParenthesis expr T_closedParanthesis block

switch_stmt : T_switch T_openParenthesis expr_without_constants T_closedParanthesis switch_block

switch_block_end_flower : case_stmt closeflower
						| closeflower

switch_block : openflower switch_block_end_flower
			 | case_stmt
			 | T_Semicolon
			 ;

case_stmt : T_case expr T_colon Multiple_stmts case_stmt
		  | T_default T_colon Multiple_stmts case_stmt
		  |
		  ;

if_stmt : T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty

elseif_else_empty 	: T_else T_if T_openParenthesis expr T_closedParanthesis block elseif_else_empty
					| T_else Multiple_stmts_not_if
					| T_else openflower block_end_flower
					|
					;

Multiple_stmts_not_if 	: stmt_without_if Multiple_stmts
						| T_Semicolon
						;

stmt_without_if : expr T_Semicolon
				| Assignment_stmt T_Semicolon
				| while_stmt
				| for_stmt
				;


Assignment_stmt : T_identifier T_AssignmentOperator expr
				| T_identifier T_shortHand expr
				| T_type T_identifier T_AssignmentOperator expr_without_constants   {insert_in_st($<s.str>1, $<s.str>2, st[top], "j");}	
				| T_type T_identifier T_AssignmentOperator T_stringLiteral   {insert_in_st($<s.str>1, $<s.str>2, st[top], $<s.str>4);}
				| T_type T_identifier T_AssignmentOperator T_numericConstants   {insert_in_st($<s.str>1, $<s.str>2, st[top], $<s.str>4);}
				| T_int T_identifier T_AssignmentOperator expr_without_constants    {insert_in_st($<s.str>1, $<s.str>2, st[top], "j");}
				| T_int T_identifier T_AssignmentOperator T_numericConstants    {insert_in_st($<s.str>1, $<s.str>2, st[top], $<s.str>4);}
				;


expr_or_empty_with_semicolon_and_assignment : expr_or_empty T_Semicolon
	                                        | Assignment_stmt T_Semicolon

expr_or_empty_with_assignment_and_closed_parent : expr_or_empty T_closedParanthesis
	                                            | Assignment_stmt T_closedParanthesis

expr_without_constants  : T_identifier
						| expr T_plus expr
						| expr T_minus expr
						| expr T_divide expr
						| expr T_multiply expr
						| expr T_mod expr
						| expr T_LogicalAnd expr
						| expr T_LogicalOr expr
						| expr T_less expr
						| expr T_less_equal expr
						| expr T_greater expr
						| expr T_greater_equal expr
						| expr T_equal_equal expr
						| expr T_not_equal expr
						;


expr    : T_numericConstants
		| T_stringLiteral
		| T_identifier
		| expr T_plus expr
		| expr T_minus expr
		| expr T_divide expr
		| expr T_multiply expr
		| expr T_mod expr
		| expr T_LogicalAnd expr
		| expr T_LogicalOr expr
		| expr T_less expr
		| expr T_less_equal expr
		| expr T_greater expr
		| expr T_greater_equal expr
		| expr T_equal_equal expr
		| expr T_not_equal expr
		;

expr_or_empty   : expr
				| 
				;

openflower : T_openFlowerBracket {};

closeflower : T_closedFlowerBracket {};
*/

%%

void yyerror(const char *str) 
{ 
	printf("Error | Line: %d\n%s\n",yylineno,str);
} 


int main()
{
	yyparse();
	printf("\n*************************************************************************************************\n");
	display();
	printf("\n*************************************************************************************************\n");
	return 0;
}
