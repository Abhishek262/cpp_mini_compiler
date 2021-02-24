#!/bin/sh

lex c.l
yacc c.y
gcc y.tab.c -ll -ly 
./a.out $1