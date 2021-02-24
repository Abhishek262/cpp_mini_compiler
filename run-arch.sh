#!/bin/sh

lex c.l
yacc c.y
gcc y.tab.c -lfl -ly 
./a.out $1