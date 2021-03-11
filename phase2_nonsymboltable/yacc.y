%{
#include <stdio.h>
#include <stdlib.h>

%}
%token ID NUM T_lt T_gt T_lteq T_gteq T_neq T_eqeq T_pl T_min T_mul T_div T_and T_or T_incr T_decr T_not T_eq T_col SWITCH CASE DEFAULT INT CHAR FLOAT VOID H MAINTOK INCLUDE BREAK IF ELSE COUT STRING CHARAC ENDL

%%
S
      : START {printf("Input accepted.\n");exit(0);}
      ;

START
      : INCLUDE T_lt H T_gt MAIN
      | INCLUDE "\"" H "\"" MAIN
      ;

MAIN
      : VOID MAINTOK BODY
      | INT MAINTOK BODY
      ;

BODY
      : '{' C '}'
      ;

C
      : C statement ';'
      | C LOOPS
      | statement ';'
      | LOOPS
      | '{' C '}'
      ;

LOOPS
      : IF '(' COND ')' LOOPBODY ELSECHAIN
      | SWITCH '(' COND ')' SWITCHBODY
      ;
ELSECHAIN
      : ELSE IF '(' COND ')' LOOPBODY ELSECHAIN
      | ELSE LOOPBODY
      |
      ;

LOOPBODY
  	  : '{' C '}'
  	  | ';'
  	  | statement ';'
  	  ;

SWITCHBODY
  	  : '{' CASES '}'
  	  | ';'
  	  | statement ';'
  	  ;

CASES
  	  : CASE CASEVAL
        | ';'
  	  | statement ';'
        | DEFAULT T_col DEFCASEC
  	  |
  	  ;

statement
      : ASSIGN_EXPR
      | ARITH_EXPR
      | PRINT
      | BREAK
      ;

COND
      : LIT RELOP LIT
      | LIT
      | LIT RELOP LIT bin_boolop LIT RELOP LIT
      | un_boolop '(' LIT RELOP LIT ')'
      | un_boolop LIT RELOP LIT
      | LIT bin_boolop LIT
      | un_boolop '(' LIT ')'
      | un_boolop LIT
      ;

ASSIGN_EXPR
      : ID T_eq ARITH_EXPR
      | TYPE ID T_eq ARITH_EXPR
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
      : COUT T_lt T_lt STRING
      | COUT T_lt T_lt STRING T_lt T_lt ENDL
      ;

CASEVAL
      : NUM T_col CASEC
      | STRING T_col CASEC 
      | CHARAC T_col CASEC 
      ;

CASEC
      : C
      | CASE CASEVAL
      | C CASE CASEVAL
      | DEFAULT T_col DEFCASEC
      | C DEFAULT T_col DEFCASEC
      ;
DEFCASEVAL
      : NUM T_col DEFCASEC
      | STRING T_col DEFCASEC 
      | CHARAC T_col DEFCASEC 
      ;

DEFCASEC
      : C
      | CASE DEFCASEVAL
      | C CASE DEFCASEVAL
      ;
LIT
      : ID
      | NUM
      ;
TYPE
      : INT
      | CHAR
      | FLOAT
      ;
RELOP
      : T_lt
      | T_gt
      | T_lteq
      | T_gteq
      | T_neq
      | T_eqeq
      ;

bin_arop
      : T_pl
      | T_min
      | T_mul
      | T_div
      ;

bin_boolop
      : T_and
      | T_or
      ;

un_arop
      : T_incr
      | T_decr
      ;

un_boolop
      : T_not
      ;



%%

#include "lex.yy.c"

int yyerror(){
  printf("ERROR\n");
}

int main(int argc, char* args[])
{
  yyin=fopen(args[1],"r");
  //yyout=fopen("output.c","w");
  yyparse();
  return 0;
}
