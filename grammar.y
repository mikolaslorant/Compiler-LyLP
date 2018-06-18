%{
	#include <stdio.h>
	#include <stdlib.h>
	
	extern int yylex();
	extern int linenum;
	
	void yyerror(cont char* s);


%}

%%

%%

void yyerror(char const* s)
{
	printf(stderr, "ERROR: %s on line %d\n", s, linenum);
	exit(1);
}