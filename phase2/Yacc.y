
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
		char *type ;
		int intval;
		double floatval;
		struct ast_node * ast;
	}s;
}

%token <s> T_keyword T_main T_type T_if T_else T_InputStream T_OutputStream T_cout T_endl T_cin
%token <s> T_openParenthesis T_closedParanthesis T_openFlowerBracket T_closedFlowerBracket 
%token <s> T_AssignmentOperator  T_Semicolon T_identifier T_numericConstants T_stringLiteral
%token <s> T_character T_plus T_minus T_mod T_divide T_multiply T_incr T_decr
%token <s> T_switch T_case T_break T_default T_namespace T_array T_include T_comma T_dot T_colon
%token <s> T_intVal T_longVal T_doubleVal T_floatVal T_bool T_bool_true T_bool_false

%left T_LogicalAnd T_LogicalOr T_LogicalNot
%left T_less T_less_equal T_greater T_greater_equal T_equal_equal T_not_equal
%left T_plus T_minus T_incr T_decr
%left T_multiply T_divide T_mod



%%

S
      : Start {printf("Reading input");}
      ;

Start : T_include Start
      | T_include T_namespace Start
      | Main

Main 	: T_type T_main T_openParenthesis T_closedParanthesis Body
		;

Body	: T_openFlowerBracket C T_closedFlowerBracket
		;

C 	: C statement T_Semicolon
	| C LOOPS	
	| statement T_Semicolon
	| LOOPS
	| T_openFlowerBracket C T_closedFlowerBracket
	;

LOOPS
      : T_if T_openParenthesis COND T_closedParanthesis LOOPBODY ELSECHAIN
      | T_switch T_openParenthesis COND T_closedParanthesis SWITCHBODY
      ;

ELSECHAIN
      : T_else T_if T_openParenthesis COND T_closedParanthesis LOOPBODY ELSECHAIN
      | T_else LOOPBODY
      |
      ;

LOOPBODY
  	  : T_openFlowerBracket C T_closedFlowerBracket
  	  | T_Semicolon
  	  | statement T_Semicolon
  	  ;

SWITCHBODY
  	  : T_openFlowerBracket CASES T_closedFlowerBracket
  	  | T_Semicolon
  	  | statement T_Semicolon
  	  ;

CASES
	: T_case CASEVAL
	| T_Semicolon
	| statement T_Semicolon
	| T_default T_colon DEFCASEC
	|
	;

statement
      : ASSIGN_EXPR
      | ARITH_EXPR
      | PRINT
      | INPUT
      | T_break
      ;

COND
      : LIT RELOP LIT
      | LIT
      | LIT RELOP LIT bin_boolop LIT RELOP LIT
      | un_boolop T_openParenthesis LIT RELOP LIT T_closedParanthesis
      | un_boolop LIT RELOP LIT
      | LIT bin_boolop LIT
      | un_boolop T_openParenthesis LIT T_closedParanthesis
      | un_boolop LIT
      ;

ASSIGN_EXPR
      : T_identifier T_AssignmentOperator ARITH_EXPR 
      | T_type T_identifier T_AssignmentOperator ARITH_EXPR {insert_in_st($<s.type>1, $<s.str>2, st[top], "j");}
      ;

ARITH_EXPR
      : LIT
      | LIT bin_arop ARITH_EXPR
      | LIT bin_boolop ARITH_EXPR
      | LIT un_arop
      | un_arop ARITH_EXPR
      | un_boolop ARITH_EXPR
      ;

PRINT
      : T_cout T_OutputStream T_stringLiteral
      | T_cout T_OutputStream T_stringLiteral T_OutputStream T_endl
      ;

INPUT
      : T_cin INPUTS
      ;

INPUTS
      : T_InputStream T_identifier INPUTS
      | T_InputStream T_identifier
      ;

CASEVAL
      : LIT T_colon CASEC
      ;

CASEC
      : C
      | T_case CASEVAL
      | C T_case CASEVAL
      | T_default T_colon DEFCASEC
      | C T_default T_colon DEFCASEC
      ;

DEFCASEVAL
      : LIT T_colon DEFCASEC
      ;

DEFCASEC
      : C
      | T_case DEFCASEVAL
      | C T_case DEFCASEVAL
      ;

LIT
	: T_identifier
	| T_numericConstants
	| T_intVal
	| T_floatVal
	| T_doubleVal
	| T_longVal
	| T_stringLiteral
	| T_character
	;

/* use T_type for types */

RELOP
      : T_less
      | T_greater
      | T_less_equal
      | T_greater_equal
      | T_not_equal
      | T_equal_equal
      ;

bin_arop
      : T_plus
      | T_minus
      | T_multiply
      | T_divide
      | T_mod
      ;

bin_boolop
      : T_LogicalAnd
      | T_LogicalOr
      ;

un_arop
      : T_incr
      | T_decr
      ;

un_boolop	: T_LogicalNot
			;

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
