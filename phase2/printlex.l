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


\"[^\"]*\"						{printf("T_stringLiteral  ");}
"'"(.|\\n)"'"					{printf("T_character  ");}
"//".*\n                        {;}
"/*"[^*/]*"*/"					{;}

compl|concept|const|consteval|constexpr|constinit|const_cast|continue|co_await|co_return|co_yield|decltype|delete|do|dynamic_cast|enum|explicit|export|extern|friend|goto|inline|mutable|namespace|new|noexcept|not|not_eq|nullptr|operator|or|or_eq|private|protected|public|reflexpr|register|reinterpret_cast|requires|signed|sizeof|static|static_assert|static_cast|synchronized|template|this|thread_local|throw|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|xor|xor_e|alignas|alignof|and|and_eq|asm|atomic_cancel|atomic_commit|atomic_noexcept|bitand|bitor|catch {printf("T_keyword  ");}

"if"																{printf("T_if  ") ;}
"else"																{printf("T_else  ") ;}
bool                            {printf("T_bool  ");}
true                            {printf("T_bool_true  ");}
false                            {printf("T_bool_false  ");}
"int" 																{printf("T_int  ") ; }
"main"																{printf("T_main  ") ; }
"int"|"auto"|"char"|"char8_t"|"char16_t"|"char32_t"|"double"|"float"|"long"|"short" 	{ printf("T_type  ") ;}
"return" 																{printf("T_return  ");}
"for"							{printf("T_for  ");}
"while"							{printf("T_while  ");}
"switch"    						{ printf("T_switch  ") ;}
"case" 							{ printf("T_case  ") ;}
"break" 							{ printf("T_break  ") ;}
"default" 						{ printf("T_default  ") ;}
"struct" 							{ printf("T_struct  ") ;}
"class" 							{ printf("T_class  ") ;}

"<<"							{printf("T_InputStream  ") ;}
">>"							{printf("T_OutputStream  ") ;}
"using namespace "{letter}+		{printf("T_namespace  ")	;}

{letter}({letter}|{digit})* 	{printf("T_identifier  ") ;}

{digit}+"."{digit}+	{printf("T_floatVal  ");}
{digit}+"."{digit}+"e"(\+|\-)[4-9][4-9] 	{printf("T_doubleVal  ");}
{digit}+"."{digit}+"e"(\+|\-) 	{printf("T_floatVal  ");}
{digit}{1,10}		{printf("T_intVal  ");}
{digit}{10,100}		{printf("T_longVal  ");}
{digit}+						{printf("T_numericConstants  ") ;}


"("							  	{printf("T_openParenthesis  ") ;}		  
")"								{printf("T_closedParanthesis  ") ;}
"{"								{count=count+1;top=top+1;st[top]=count;printf("T_openFlowerBracket  ") ;}
"}"								{top=top-1;printf("T_closedFlowerBracket  ") ;}

">"								{printf("T_greater  ");}
">="							{printf("T_greater_equal  ");}
"<"								{printf("T_less  ");}
"<="							{printf("T_less_equal  ");}
"=="							{printf("T_equal_equal  ");}
"!="							{printf("T_not_equal  ");}

"&&"							{printf("T_LogicalAnd  ");}
"||"						{printf("T_LogicalOr  ");}

"["({digit}|{letter})*"]"   {printf("T_array  ");}
":"	 	{printf("T_caseop  ");}

"+="|"-="|"*="|"/="|"%="		{printf("T_shortHand  ");}

"+"								{printf("T_plus  ");}
"-"								{printf("T_minus  ");}
"/"								{printf("T_divide  ");}
"*"								{printf("T_multiply  ");}
"%"								{printf("T_mod  ");}
"="								{printf("T_AssignmentOperator  ") ;}
^"#include ".+ ;				{printf("T_include  ");}

";"								{printf("T_Semicolon  ") ;}
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
