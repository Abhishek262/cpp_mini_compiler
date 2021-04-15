yacc -d --warning=none Yacc.y
lex lex.l
gcc -w y.tab.c lex.yy.c
./a.out < $1 > icg_store
python3 optimizer.py < icg_store