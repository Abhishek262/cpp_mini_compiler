digit [0-9]
letter [A-Za-z_]

%{
	#include "y.tab.h"
	#include<stdio.h>
	#include<stdlib.h>
	#include<ctype.h>
	int yyerror(char*);
	int st[100];
	int top = 0;
	int count = 0;
	int line = 0;
	int column = 0;
	void Gen_Symbol_Table(char *text,int nm,int scp);
	void display();
	void insert_in_st(char*, char*, int, char* );


	// char Global_Type_Array[100];
%}



%option yylineno

%%


\"[^\"]*\"						{yylval.s.str = strdup(yytext);yylval.s.type = "string";return T_stringLiteral;}
"'"(.|\\n)"'"					{yylval.s.str = strdup(yytext);yylval.s.type = "character";return T_character;}
"//".*\n                        {;}
"/*"[^*/]*"*/"					{;}

compl|concept|const|consteval|constexpr|constinit|const_cast|continue|co_await|co_return|co_yield|decltype|delete|do|dynamic_cast|enum|explicit|export|extern|friend|goto|inline|mutable|namespace|new|noexcept|not|not_eq|nullptr|operator|or|or_eq|private|protected|public|reflexpr|register|reinterpret_cast|requires|signed|sizeof|static|static_assert|static_cast|synchronized|template|this|thread_local|throw|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|xor|xor_e|alignas|alignof|and|and_eq|asm|atomic_cancel|atomic_commit|atomic_noexcept|bitand|bitor|catch {return T_keyword;}

"if"																{return T_if ;}
"else"																{return T_else ;}
bool                            {return T_bool;}
true                            {yylval.s.str = strdup(yytext);yylval.s.type = "bool";return T_bool_true;}
false                            {yylval.s.str = strdup(yytext);yylval.s.type = "bool";return T_bool_false;}
"main"																{return T_main ; }
"int"|"auto"|"char"|"char8_t"|"char16_t"|"char32_t"|"double"|"float"|"long"|"short" 	{ return T_type ;}
"return" 																{return T_return;}
"for"							{return T_for;}
"while"							{return T_while;}
"switch"    						{ return T_switch ;}
"case" 							{ return T_case ;}
"break" 							{ return T_break ;}
"default" 						{ return T_default ;}
"struct" 							{ return T_struct ;}
"class" 							{ return T_class ;}

"<<"							{return T_InputStream ;}
">>"							{return T_OutputStream ;}
"using namespace "{letter}+		{return T_namespace	;}

{letter}({letter}|{digit})* 	{Gen_Symbol_Table(yytext,yylineno,st[top]);yylval.s.str = strdup(yytext);yylval.s.type = "Identifier";return T_identifier ;}

{digit}+"."{digit}+	{yylval.s.floatval = atof(yytext);yylval.s.type = "float";return T_floatVal;}
{digit}{1,10}		{yylval.s.intval = atoi(yytext);yylval.s.type = "int";return T_intVal;}
{digit}{10,100}		{yylval.s.intval = atoi(yytext);yylval.s.type = "long";return T_longVal;}
{digit}+"."{digit}+"e"(\+|\-)[4-9][4-9] 	{yylval.s.floatval = atof(yytext);yylval.s.type = "double";return T_doubleVal;}
{digit}+"."{digit}+"e"(\+|\-) 	{yylval.s.floatval = atof(yytext);yylval.s.type = "float";return T_floatVal;}
{digit}+						{return T_numericConstants ;}


"("							  	{return T_openParenthesis ;}		  
")"								{return T_closedParanthesis ;}
"{"								{count=count+1;top=top+1;st[top]=count;return T_openFlowerBracket ;}
"}"								{top=top-1;return T_closedFlowerBracket ;}

">"								{return T_greater;}
">="							{return T_greater_equal;}
"<"								{return T_less;}
"<="							{return T_less_equal;}
"=="							{return T_equal_equal;}
"!="							{return T_not_equal;}

"&&"							{return T_LogicalAnd;}
"||"						{return T_LogicalOr;}

"["({digit}|{letter})*"]"   {return T_array;}
":"	 	{return T_caseop;}

"+="|"-="|"*="|"/="|"%="		{return T_shortHand;}

"+"								{return T_plus;}
"-"								{return T_minus;}
"/"								{return T_divide;}
"*"								{return T_multiply;}
"%"								{return T_mod;}
"="								{return T_AssignmentOperator ;}
^"#include ".+ ;				{return T_include;}

";"								{return T_Semicolon ;}
","								{T_comma;}
"."								{T_dot;}	
[ \t]                          {;}
[\n]							{line++;column = 0;}
.								{printf("Invalid character found, Abort!!!");}


%%
// Variable structure that consists of - :
// + Variable name
// + Line number to assosciate particual variable with - Line_T
// + scope - Each opened block is assosciated with a scope number
//
struct var
{
	char var_name[20];
	char Line_t[100];
	char type[100];
	char value[100];
	int scope;
};
struct scope
{
	struct var arr[20];
	int up;
};

struct scope Symbol_Table[100];


void Gen_Symbol_Table(char *text,int nm,int scp)
{
	int flag=0;
	for(int i=0;i<=Symbol_Table[scp].up;i++)
	{
		if(strcmp(Symbol_Table[scp].arr[i].var_name,text)==0)
		{
			char buffer[20];
			sprintf(buffer,"%d",nm);
			flag=1;
			strcat(Symbol_Table[scp].arr[i].Line_t,",");
			strcat(Symbol_Table[scp].arr[i].Line_t,buffer);	
			Symbol_Table[scp].arr[i].scope=scp;		
			break;
		}
	}
	if(flag==0)
	{
		char buffer[20];
		sprintf(buffer,"%d",nm);
		Symbol_Table[scp].up++;
		int p=Symbol_Table[scp].up;
		strcpy(Symbol_Table[scp].arr[p].var_name,text);
		strcpy(Symbol_Table[scp].arr[p].Line_t,"");
		strcat(Symbol_Table[scp].arr[p].Line_t,buffer);
		Symbol_Table[scp].arr[p].scope=scp;
	}
	
}

void display()
{
	for(int i=0;i<=count;i++)
	{
		int h=Symbol_Table[i].up;
		for (int j=1;j<=h;j++)
		{
			printf("Symbol:%s \t Scope:%d \t Line number: %s \t Type: %s \t Value: %s\n",Symbol_Table[i].arr[j].var_name,Symbol_Table[i].arr[j].scope,Symbol_Table[i].arr[j].Line_t, Symbol_Table[i].arr[j].type, Symbol_Table[i].arr[j].value);
		}
	}	
}

void insert_in_st(char* type, char* id, int scp, char* value)
{
	
	for(int i=0;i<=Symbol_Table[scp].up;i++)
	{
		if(strcmp(Symbol_Table[scp].arr[i].var_name,id)==0)
		{
			strcpy(Symbol_Table[scp].arr[i].type, type);
			strcpy(Symbol_Table[scp].arr[i].value, value);
		}
	}
}

int yywrap()
{
	return 1;
}
