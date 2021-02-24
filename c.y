
%{
#include <stdio.h>
#include <stdlib.h>

extern FILE *fp;
int yylex();
int yyerror();

int className[26] ={0};
%}

%token T_INT T_FLOAT T_CHAR T_DOUBLE T_VOID
%token T_FOR T_WHILE 
%token T_IF T_ELSE T_PRINTF T_ELSEIF
%token T_STRUCT T_CLASS
%token T_NUM T_ID
%token T_INCLUDE
%token T_DOT
%token T_COUTSTR T_COUT T_ENDL T_COUTOP
%token T_CIN T_CINOP
%token T_OPENFLOWERBRACKET T_CLOSEFLOWERBRACKET
%token T_ACCESS T_CUSTOM T_FNAME T_NFNAM
%token T_SWITCH T_BREAK T_DEFAULT T_CASE

%right '='
%left T_AND T_OR
%left '<' '>' T_LE T_GE T_EQ T_NE T_LT T_GT

%%

start:    Declaration 
	| Function
	| start Function
	| start Declaration
	;

/* Declaration block */
Declaration: Type Assignment ';' 
	| Assignment ';'  	
	| FunctionCall ';' 	
	| ArrayUsage ';'	
	| Type ArrayUsage ';'   
	| StructStmt ';'
	| ClassStmt ';'
	| error	
	;

Arg:	Type T_ID 	
	;

/* Assignment block */
Assignment: T_ID '=' Assignment
	| T_ID '=' FunctionCall
	| T_ID '=' ArrayUsage
	| ArrayUsage '=' Assignment
	| T_ID ',' Assignment
	| T_NUM ',' Assignment
	| T_ID '+' Assignment
	| T_ID '-' Assignment
	| T_ID '*' Assignment
	| T_ID '/' Assignment	
	| T_NUM '+' Assignment
	| T_NUM '-' Assignment
	| T_NUM '*' Assignment
	| T_NUM '/' Assignment
	| '\'' Assignment '\''	
	| '(' Assignment ')'
	| '-' '(' Assignment ')'
	| '-' T_NUM
	| '-' T_ID
	|   T_NUM 
	|   T_ID
	;

/* Function Call Block */
FunctionCall : T_ID'('')'
	| T_ID'('Assignment')'
	| T_CUSTOM T_DOT T_FNAME '('')'
	| T_CUSTOM T_DOT T_NFNAM '('')' {printf("unknown function\n");return 0;}
	;

/* Array Usage */
ArrayUsage : T_ID'['Assignment']'
	;

/* Function block */
Function: Type T_ID '(' ArgListOpt ')' CompoundStmt 
	| Type T_FNAME '('')' CompoundStmt 
	;
	
ArgListOpt: ArgList
	|
	;
ArgList:  ArgList ',' Arg
	| Arg
	;

CompoundStmt:	'{' StmtList '}'
	;
StmtList:	StmtList Stmt
	|
	;
Stmt:	WhileStmt
	| Declaration
	| ForStmt
	| IfStmt
	| ElseStmt
	| ElseIfStmt
	| PrintFunc
	| SwitchStmt
	| coutstatement
	| cinstatement
	| ';'
	;

/* Type Identifier block */
Type:	T_INT
	| T_FLOAT
	| T_CHAR
	| T_DOUBLE
	| T_VOID
	| T_CUSTOM {
		// printf("here\n");
			 if (className[$1] == 0) {
				printf("Error: Unknown Class ID\nQuiting!");
				return 0;
			  }
		}
	;

/* Loop Blocks */ 
WhileStmt: T_WHILE '(' Expr ')' Stmt  
	| T_WHILE '(' Expr ')' CompoundStmt 
	;

/* For Block */
ForStmt: T_FOR '(' Expr ';' Expr ';' Expr ')' Stmt 
       | T_FOR '(' Expr ';' Expr ';' Expr ')' CompoundStmt 
       | T_FOR '(' Expr ')' Stmt 
       | T_FOR '(' Expr ')' CompoundStmt 
	;

/* IfStmt Block */
IfStmt: T_IF '(' Expr ')' Stmt  
	| T_IF '(' Expr ')' CompoundStmt 
	;

/* ElseStmt Block */
ElseStmt: T_ELSE Stmt  
	| T_ELSE CompoundStmt 
	;

/* ElseIfStmt Block */
ElseIfStmt: T_ELSEIF '(' Expr ')' Stmt  
	| T_ELSEIF '(' Expr ')' CompoundStmt 
	;

/* SwitchStmt Block */
SwitchStmt:  T_SWITCH '(' T_ID|Expr ')' '{' InnerSwitchStmt '}'
	;

/* SwitchStmt Block */
InnerSwitchStmt:  SwitchCaseStmt
	| SwitchCaseStmt DefaultSwitchStmt
	;

SwitchCaseStmt: SwitchCaseStmt SwitchCaseStmt	
	| T_CASE T_NUM ':' Stmt
	| T_BREAK ';'
	;

DefaultSwitchStmt: T_DEFAULT ':' Stmt  T_BREAK ';'
	| T_DEFAULT ':' Stmt
    ;

/* Struct Statement */
StructStmt : T_STRUCT T_ID '{' Declaration '}'
	;

ClassStmt : T_CLASS T_ID '{' T_ACCESS ':' start  T_ACCESS ':' start '}' 
			{ className[$2] = 1; printf("value of classvariable = %d\n", $2);}
	   | T_CLASS T_ID ':' T_ACCESS T_ID '{' T_ACCESS ':' start  T_ACCESS ':' start '}'
	   		{ className[$2] = 1; printf("value of classvariable = %d\n", $2); }
	;

/* Print Function */
PrintFunc : T_PRINTF '(' Expr ')' ';'
	;

/*Expression Block*/
Expr:	
	| Expr T_LE Expr 
	| Expr T_GE Expr
	| Expr T_NE Expr
	| Expr T_EQ Expr
	| Expr T_GT Expr
	| Expr T_LT Expr
	| Assignment
	| ArrayUsage
	;
	
coutstatement:
	T_COUT T_COUTOP T_COUTSTR T_COUTOP T_ENDL
	| T_COUT T_COUTOP T_COUTSTR ';'
	;

cinstatement:
	T_CIN T_CINOP T_ID;

%%
#include"lex.yy.c"
#include<ctype.h>
int count=0;

int yyerror(char *s) {
	printf("%d : %s %s\n", yylineno, s, yytext );
}

int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");
	
   if(!yyparse())
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");
	
	fclose(yyin);
    return 0;
}
         

