%{
#include <stdio.h>
#include <stdlib.h>

int fvar = 1;
void Gen_Symbol_Table(char *text,int nm,int scp);
void display();
void insert_in_st(char*, char*, int, char* );
int count = 0;
int st[100];
int top = 0;
%}

alpha [a-zA-Z]
digit [0-9]

%%
\"({alpha}|{digit}|[ ])*\" { fvar = 0;return COUTSTR; }
[ \t]		{ fvar = 0; }
[\n][ \t]*   		{ fvar = 1; yylineno = yylineno + 1;}
cout 		{ fvar = 0; return COUT; }
endl		{ fvar = 0;return ENDL;}
cin 		{ fvar = 0;return CIN;}
public|private|protected 	{ fvar = 0;return ACCESS;}
int		{ fvar = 0;return INT;}
float 		{ fvar = 0;return FLOAT;}
char 		{ fvar = 0;return CHAR;}
void 		{ fvar = 0;return VOID;}
double 		{ fvar = 0;return DOUBLE;}
fn1|fn2		{ fvar = 0;return FNAME;}
fn		{ fvar = 0;return NFNAM;}
for 		{ fvar = 0;return FOR;}
while		{ fvar = 0;return WHILE;}
if		{ fvar = 0;return IF;}
else		{ fvar = 0;return ELSE;}
else\sif 	{fvar = 0;return ELSEIF;}
printf  	{ fvar = 0;return PRINTF;}
switch    { fvar =0;return SWITCH;}
case { fvar =0;return CASE;}
break { fvar =0;return BREAK;}
default { fvar =0;return DEFAULT;}
struct 		{ fvar = 0;return STRUCT;}
class 		{ fvar = 0;return CLASS;}
^"#include ".+ ;
{digit}+       	{ fvar = 0;return NUM;}
{alpha}({alpha}|{digit})* {Gen_Symbol_Table(yytext,yylineno,st[top]);
				if (fvar) {
					yylval = *yytext - 'a';
					return CUSTOM;
				}
				fvar = 0;
				yylval = *yytext - 'a';
				return ID;
			}
"<<"		{ fvar = 0;return COUTOP;}
">>" 		{ fvar = 0;return CINOP;}
"<="    	{ fvar = 0;return LE;}
">="    	{ fvar = 0;return GE;}
"=="    	{ fvar = 0;return EQ;}
"!="    	{ fvar = 0;return NE;}
">"		{ fvar = 0;return GT;}
"<"		{ fvar = 0;return LT;}
"."     	{ fvar = 0;return DOT;}
"{"								{count=count+1;top=top+1;st[top]=count;return T_openFlowerBracket ;}
"}"								{top=top-1;return T_closedFlowerBracket ;}
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
	for(int i=0;i<=count;i++)
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