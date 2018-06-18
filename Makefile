include Makefile.inc


all: parser 


parser: clean
		yacc -d grammar.y 
		flex scanner.l
		$(GCC) -o parser lex.yy.c y.tab.c -ly $(GCCFLAGS)

clean:
	rm -rf *.o *.c *.h

test: ./parser < test.lylp > test.out

.PHONY: all test clean