include Makefile.inc


all: parser 


parser: clean
		yacc -d grammar.y 
		flex scanner.l
		$(GCC) -o parser lex.yy.c y.tab.c node.c node.h -ly $(GCCFLAGS)

clean:
	rm -rf *.o y.tab.c y.tab.h parser lex.yy.c

test: ./parser < test.lylp > test.out

.PHONY: all test clean