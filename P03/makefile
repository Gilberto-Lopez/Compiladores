all: parser

parser.tab.c parser.tab.h: parser.y asa.h
	bison -vd parser.y

lex.yy.c: lexer.l parser.tab.h asa.h
	flex lexer.l

parser: lex.yy.c parser.tab.c parser.tab.h asa.c asa.h
	gcc parser.tab.c lex.yy.c asa.c -lfl -lm -o parser

asa.o: asa.c asa.h
	gcc -g -c asa.c

parser.tab.o: parser.tab.c
	gcc -g -c parser.tab.c

lex.yy.o: lex.yy.c asa.h parser.tab.h
	gcc -g -c lex.yy.c

debug: asa.o parser.tab.o lex.yy.o
	gcc -g -o parser_gdb asa.o parser.tab.o lex.yy.o -lfl -lm

clean:
	rm parser{,.output,.tab*} lex.yy.c

clean-debug:
	rm parser{_gdb,.output,.tab.{c,h}} lex.yy.c *.o