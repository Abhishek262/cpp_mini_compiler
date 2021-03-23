yacc -d --debug -v Yacc.y -Wcounterexamples
lex lex.l
gcc y.tab.c lex.yy.c
./a.out < $1