#include<stdio.h>

typedef struct parse_node{
		char *str;
		char *type;
		int intval;
		float floatval;
		struct ast_node * ast;
}s;