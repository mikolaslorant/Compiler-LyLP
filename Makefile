include Makefile.inc


all: clean compiler 


compiler: 
		yacc -d grammar.y 
		flex scanner.l
		$(GCC) -o compiler lex.yy.c y.tab.c node.c node.h -ly $(GCCFLAGS)

clean: 
	rm -rf *.o y.tab.c y.tab.h compiler lex.yy.c test.c

test: 
	./compiler < testcode.lylp > test.c

.PHONY: all test clean compiler