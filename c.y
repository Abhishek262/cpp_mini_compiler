
%{
#include <stdio.h>
#include <stdlib.h>

extern FILE *fp;
int yylex();
int yyerror();

int className[26] ={0};
%}

%token INT FLOAT CHAR DOUBLE VOID
%token FOR WHILE 
%token IF ELSE PRINTF ELSEIF
%token STRUCT CLASS
%token NUM ID
%token INCLUDE
%token DOT
%token COUTSTR COUT ENDL COUTOP
%token CIN CINOP
%token ACCESS CUSTOM FNAME NFNAM
%token SWITCH BREAK DEFAULT CASE

%right '='
%left AND OR
%left '<' '>' LE GE EQ NE LT GT

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

Arg:	Type ID 	
	;

/* Assignment block */
Assignment: ID '=' Assignment
	| ID '=' FunctionCall
	| ID '=' ArrayUsage
	| ArrayUsage '=' Assignment
	| ID ',' Assignment
	| NUM ',' Assignment
	| ID '+' Assignment
	| ID '-' Assignment
	| ID '*' Assignment
	| ID '/' Assignment	
	| NUM '+' Assignment
	| NUM '-' Assignment
	| NUM '*' Assignment
	| NUM '/' Assignment
	| '\'' Assignment '\''	
	| '(' Assignment ')'
	| '-' '(' Assignment ')'
	| '-' NUM
	| '-' ID
	|   NUM 
	|   ID
	;

/* Function Call Block */
FunctionCall : ID'('')'
	| ID'('Assignment')'
	| CUSTOM DOT FNAME '('')'
	| CUSTOM DOT NFNAM '('')' {printf("unknown function\n");return 0;}
	;

/* Array Usage */
ArrayUsage : ID'['Assignment']'
	;

/* Function block */
Function: Type ID '(' ArgListOpt ')' CompoundStmt 
	| Type FNAME '('')' CompoundStmt 
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
Type:	INT
	| FLOAT
	| CHAR
	| DOUBLE
	| VOID
	| CUSTOM {
		// printf("here\n");
			 if (className[$1] == 0) {
				printf("Error: Unknown Class ID\nQuiting!");
				return 0;
			  }
		}
	;

/* Loop Blocks */ 
WhileStmt: WHILE '(' Expr ')' Stmt  
	| WHILE '(' Expr ')' CompoundStmt 
	;

/* For Block */
ForStmt: FOR '(' Expr ';' Expr ';' Expr ')' Stmt 
       | FOR '(' Expr ';' Expr ';' Expr ')' CompoundStmt 
       | FOR '(' Expr ')' Stmt 
       | FOR '(' Expr ')' CompoundStmt 
	;

/* IfStmt Block */
IfStmt: IF '(' Expr ')' Stmt  
	| IF '(' Expr ')' CompoundStmt 
	;

/* ElseStmt Block */
ElseStmt: ELSE Stmt  
	| ELSE CompoundStmt 
	;

/* ElseIfStmt Block */
ElseIfStmt: ELSEIF '(' Expr ')' Stmt  
	| ELSEIF '(' Expr ')' CompoundStmt 
	;

/* SwitchStmt Block */
SwitchStmt:  SWITCH '(' ID|Expr ')' '{' InnerSwitchStmt '}'
	;

/* SwitchStmt Block */
InnerSwitchStmt:  SwitchCaseStmt
	| SwitchCaseStmt DefaultSwitchStmt
	;

SwitchCaseStmt: SwitchCaseStmt SwitchCaseStmt	
	| CASE NUM ':' Stmt
	| BREAK ';'
	;

DefaultSwitchStmt: DEFAULT ':' Stmt  BREAK ';'
	| DEFAULT ':' Stmt
    ;

/* Struct Statement */
StructStmt : STRUCT ID '{' Declaration '}'
	;

ClassStmt : CLASS ID '{' ACCESS ':' start  ACCESS ':' start '}' 
			{ className[$2] = 1; printf("value of classvariable = %d\n", $2);}
	   | CLASS ID ':' ACCESS ID '{' ACCESS ':' start  ACCESS ':' start '}'
	   		{ className[$2] = 1; printf("value of classvariable = %d\n", $2); }
	;

/* Print Function */
PrintFunc : PRINTF '(' Expr ')' ';'
	;

/*Expression Block*/
Expr:	
	| Expr LE Expr 
	| Expr GE Expr
	| Expr NE Expr
	| Expr EQ Expr
	| Expr GT Expr
	| Expr LT Expr
	| Assignment
	| ArrayUsage
	;
	
coutstatement:
	COUT COUTOP COUTSTR COUTOP ENDL
	| COUT COUTOP COUTSTR ';'
	;

cinstatement:
	CIN CINOP ID;

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
         

