all: parser

parser.tab.c parser.tab.h: parser.y asa.h
	bison -vd parser.y -W

lex.yy.c: lexer.l parser.tab.h asa.h
	flex lexer.l

parser: lex.yy.c parser.tab.c parser.tab.h asa.c asa.h
	gcc parser.tab.c lex.yy.c asa.c -lfl -o parser

clean:
	rm parser{,.output,.tab*} lex.yy.c
