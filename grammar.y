%{
	#include <stdio.h>
	#include <stdlib.h>
	
	extern int yylex();
	extern int linenum;
	
	void yyerror(cont char* s);


%}

%union {int num;} /*Aca creo que van los atributos de la gramatica*/
%start BLOCK
%token NUMBER
%token TEXT
%token IS
%token PLUS
%token MINUS
%token MUL
%token DIV
%token LPARENT
%token RPARENT
%token GT
%token LT
%token GE
%token LE
%token EQ
%token NE
%token AND
%token OR
%token IF
%token ELSE
%token DO
%token UNTIL
%token NOT
%token END
%token ID
%token NUM
%token TEXT_LITERAL

%%
/* Producciones */
/* Defino block como un bloque generico de codigo */
BLOCK 	: LINE END_STATEMENT 
	| IF EXPRESSION STEND
	| IF EXPRESSION STEND ELSE BLOCK
	| DO START BLOCK END UNTIL EXPRESION
	| LINE BLOCK;

LINE	: ASSIGNMENT
	| DECLARATION
	| DEFINITION;

STEND	: START BLOCK END;

ASSIGNMENT	: ID IS EXPRESSION;

DECLARATION	: NUMBER ID
		| TEXT ID;

DEFINITION	: NUMBER ID IS EXPRESSION
		| TEXT ID IS TEXT_LITERAL;

EXPRESSION	: LPARENT EXPRESSION RPARENT
		| EXPRESSION PLUS EXPRESSION
		| EXPRESSION MINUS EXPRESSION
		| EXPRESSION MUL EXPRESSION
		| EXPRESSION DIV EXPRESSION /* no falta modulo? */
		| TERM PLUS TERM
		| TERM MINUS TERM
		| TERM MUL TERM
		| TERM DIV TERM
		| TERM ;

/* En C es lo mismo una expresion o una expresion logica pero 
quizas aca como es mas verborragico convenga separarlas*/

LOGEXP	: NOT LOGEXP
	| LOGEXP AND LOGEXP
	| LOGEXP OR LOGEXP
	| LPARENT LOGEXP RPARENT
	| EXPRESSION GT EXPRESSION
	| EXPRESSION LT EXPRESSION
	| EXPRESSION LE EXPRESSION
	| EXPRESSION EQ EXPRESSION
	| EXPRESSION NE EXPRESSION;

TERM	: ID
	| NUM;

%%

void yyerror(char const* s)
{
	printf(stderr, "ERROR: %s on line %d\n", s, linenum);
	exit(1);
}
