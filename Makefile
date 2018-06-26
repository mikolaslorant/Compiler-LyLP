include Makefile.inc


all: clean compiler 


compiler: 
		yacc -d grammar.y 
		flex scanner.l
		$(GCC) -o compiler lex.yy.c y.tab.c node.c node.h -ly $(GCCFLAGS)

clean: 
	rm -rf *.o y.tab.c y.tab.h compiler lex.yy.c test1.c test2.c test3.c test4.c test5.c test6.c test7.c test1 test2 test3 test4 test5 test6 test7

test1: 
	./compiler < test1.lylp > test1.c
	gcc test1.c -o test1

test2: 
	./compiler < test2.lylp > test2.c
	gcc test2.c -o test2

test3: 
	./compiler < test3.lylp > test3.c
	gcc test3.c -o test3

test4: 
	./compiler < test4.lylp > test4.c
	gcc test4.c -o test4

test5: 
	./compiler < test5.lylp > test5.c
	gcc test5.c -o test5

test6: 
	./compiler < test6.lylp > test6.c
	gcc test6.c -o test6

test7: 
	./compiler < test7.lylp > test7.c
	gcc test7.c -o test7


.PHONY: all test1 test2 test3 test4 test5 test6 test7 clean compiler