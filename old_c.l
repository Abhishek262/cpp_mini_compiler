%{
#include <stdio.h>
#include <stdlib.h>

int fvar = 1;
void Gen_Symbol_Table(char *text,int nm,int scp);
void display();
void insert_in_st(char*, char*, int, char* );
int s_count = 0;
int st[100];
int top = 0;
%}

alpha [a-zA-Z]
digit [0-9]

%%
\"({alpha}|{digit}|[ ])*\" { fvar = 0;return T_COUTSTR; }
[ \t]		{ fvar = 0; }
[\n][ \t]*   		{ fvar = 1; yylineno = yylineno + 1;}
cout 		{ fvar = 0; return T_COUT; }
endl		{ fvar = 0;return T_ENDL;}
cin 		{ fvar = 0;return T_CIN;}
public|private|protected 	{ fvar = 0;return T_ACCESS;}
int		{ fvar = 0;return T_INT;}
float 		{ fvar = 0;return T_FLOAT;}
char 		{ fvar = 0;return T_CHAR;}
void 		{ fvar = 0;return T_VOID;}
double 		{ fvar = 0;return T_DOUBLE;}
fn1|fn2		{ fvar = 0;return T_FNAME;}
fn		{ fvar = 0;return T_NFNAM;}
for 		{ fvar = 0;return T_FOR;}
while		{ fvar = 0;return T_WHILE;}
if		{ fvar = 0;return T_IF;}
else		{ fvar = 0;return T_ELSE;}
else\sif 	{fvar = 0;return T_ELSEIF;}
printf  	{ fvar = 0;return T_PRINTF;}
switch    { fvar =0;return T_SWITCH;}
case { fvar =0;return T_CASE;}
break { fvar =0;return T_BREAK;}
default { fvar =0;return T_DEFAULT;}
struct 		{ fvar = 0;return T_STRUCT;}
class 		{ fvar = 0;return T_CLASS;}
^"#include ".+ ;
{digit}+       	{ fvar = 0;return T_NUM;}
{alpha}({alpha}|{digit})* {Gen_Symbol_Table(yytext,yylineno,st[top]);
				if (fvar) {
					yylval = *yytext - 'a';
					return T_CUSTOM;
				}
				fvar = 0;
				yylval = *yytext - 'a';
				return T_ID;
			}
"<<"		{ fvar = 0;return T_COUTOP;}
">>" 		{ fvar = 0;return T_CINOP;}
"<="    	{ fvar = 0;return T_LE;}
">="    	{ fvar = 0;return T_GE;}
"=="    	{ fvar = 0;return T_EQ;}
"!="    	{ fvar = 0;return T_NE;}
">"		{ fvar = 0;return T_GT;}
"<"		{ fvar = 0;return T_LT;}
"."     	{ fvar = 0;return T_DOT;}
"{"			{s_count=s_count+1;top=top+1;st[top]=s_count;return T_OPENFLOWERBRACKET ;}
"}"				{top=top-1;return T_CLOSEFLOWERBRACKET ;}
\/\/.* ;	
\/\*(.*\n)*.*\*\/ ;
.       return yytext[0];
%%

// Variable structure that consists of - :
// + Variable name
// + Line number to assosciate particual variable with - Line_T
// + scope - Each opened block is assosciated with a scope number
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
	for(int i=0;i<=s_count;i++)
	{
		int h=Symbol_Table[i].up;
		for (int j=1;j<=h;j++)
		{
			printf("Symbol:%s \t Scope:%d \t Line number: %s \t Type: %s \t Value: %s\n ",Symbol_Table[i].arr[j].var_name,Symbol_Table[i].arr[j].scope,Symbol_Table[i].arr[j].Line_t, Symbol_Table[i].arr[j].type, Symbol_Table[i].arr[j].value);
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