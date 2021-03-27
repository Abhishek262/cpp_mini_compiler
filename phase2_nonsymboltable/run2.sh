yacc -d --debug --verbose yacc.y -Wno-yacc
lex lex.l
gcc y.tab.c lex.yy.c
./a.out < $1