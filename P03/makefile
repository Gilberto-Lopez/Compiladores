
all: parser

parser.tab.c parser.tab.h:	parser.y
	bison -vd parser.y -W

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser: lex.yy.c parser.tab.c parser.tab.h
	gcc parser.tab.c lex.yy.c -lfl -o parser

clean:
	rm parser{,.output,.tab*} lex.yy.c
