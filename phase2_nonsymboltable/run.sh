#!/bin/bash

lex lex.l
yacc yacc.y -Wno-yacc
gcc y.tab.c -ll -ly -w
./a.out < input.cpp
