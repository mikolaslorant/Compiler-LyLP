%{
	#include <stdio.h>
	#include <stdlib.h>

	#define MAX_SYMBOLS 100
	#define MAX_SYMBOL_LENGTH 100

	#define TYPE_NUMBER 1
	#define TYPE_TEXT 2
	
	extern int yylex();
	extern int linenum;

	char symbolTable[MAX_SYMBOL_LENGTH][MAX_SYMBOLS];
	int symbols = 0, symbolType[MAX_SYMBOLS];
	int index;
	
	void yyerror(cont char* s);
%}

%union 
{
	int ivalue;
	char * svalue;
} 

%start PROGRAM
%token BLOCK
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

%right IS
%left PLUS MINUS
%left MUL DIV MOD
%left OR
%left AND
%left NOT
%left GT LT 
%left GE LE EQ NE

%%

/* Producciones */
PROGRAM		: BLOCK {printf("%s\n", $1);};

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

ASSIGNMENT	: ID IS EXPRESSION {$$ = $3;};

DECLARATION	: NUMBER ID { insertSymbol((char*)$2, TYPE_NUMBER); }
		| TEXT ID { insertSymbol((char*)$2, TYPE_TEXT); };

DEFINITION	: NUMBER ID IS EXPRESSION { insertSymbol((char*)$2, TYPE_NUMBER); $2->ivalue = $4->ivalue; }
		| TEXT ID IS TEXT_LITERAL { insertSymbol((char*)$2, TYPE_TEXT); $2->svalue = $4->svalue; };

EXPRESSION	: LPARENT EXPRESSION RPARENT {$$ = $2;}
		| EXPRESSION PLUS EXPRESSION {$$ =$1 + $3;}
		| EXPRESSION MINUS EXPRESSION {$$ = $1 - $3;}
		| EXPRESSION MUL EXPRESSION {$$ = $1 * $3;}
		| EXPRESSION DIV EXPRESSION {if($3 == 0)
										yerror("divide by zero");
									else
										$$ = $1 / $3;
		| TERM PLUS TERM {$$ =$1 + $3;}
		| TERM MINUS TERM {$$ = $1 - $3;}
		| TERM MUL TERM {$$ = $1 * $3;}
		| TERM DIV TERM {if($3 == 0)
							yerror("divide by zero");
						else
							$$ = $1 / $3;}
		| TERM MOD TERM {$$ = $1 % $3;}
		| TERM  {$$ = $1;};

/* En C es lo mismo una expresion o una expresion logica pero 
quizas aca como es mas verborragico convenga separarlas*/

LOGEXP	: NOT LOGEXP {$$ = !$1;}
	| LOGEXP AND LOGEXP {$$ = $1 && $3;}
	| LOGEXP OR LOGEXP {$$ = $1 || $3;}
	| LPARENT LOGEXP RPARENT {($$ = $2;)}
	| EXPRESSION GT EXPRESSION {$$ = ($1 > $3);}
	| EXPRESSION LT EXPRESSION {$$ = ($1 < $3);}
	| EXPRESSION LE EXPRESSION {$$ = ($1 <= $3);}
	| EXPRESSION GE EXPRESSION {$$ = ($1 >= $3);}
	| EXPRESSION EQ EXPRESSION {$$ = ($1 == $3);}
	| EXPRESSION NE EXPRESSION {$$ = ($1 != $3);};

TERM	: ID {$$ = $1;}
	| NUM {$$ = $1;};

%%

void yyerror(char const* s)
{
	printf(stderr, "ERROR: %s on line %d\n", s, linenum);
	exit(1);
}

void insertSymbol(char * symbol, int symbolType)
{
 	for(index = 0; index < symbols; index++) {
		if(strcmp(symbol, symbolTable[index]) == 0) {
			if(type[i] == symbolType) 
				yyerror("Redeclaration of variable");
			else
				yyerror("Multiple Declaration of Variable");
		}
	}

	symbolType[symbols] = symbolType;
	strcpy(symbolTable[symbols], symbol);
	symbols++;
}