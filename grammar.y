/*https://www.tutorialspoint.com/cprogramming/c_variable_arguments.htm*/
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include "node.h"

	#define MAX_SYMBOLS 100
	#define MAX_SYMBOL_LENGTH 100

	#define TYPE_NUMBER 1
	#define TYPE_TEXT 2

	extern int yylex();
	extern int linenum;

	char symbolsTable[MAX_SYMBOL_LENGTH][MAX_SYMBOLS];
	int symbols = 0, symbolsType[MAX_SYMBOLS];

	void yyerror(const char * s);
	char* strcatN(int num, ...);
	void insertSymbol(char * symbol, int symbolType);

%}

%union
{
	Node* node;
}


%token<string> NUMBER_T
%token<string> TEXT_T

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
%token<string> IF
%token<string> ELSE
%token<string> DO
%token<string> WHILE
%token<string> NOT
%token<string> START
%token<string> END
%token<string> ID
%token<string> NUM_C
%token<string> TEXT_C
%token<string> END_STATEMENT

%right IS
%left PLUS MINUS
%left MUL DIV MOD
%left OR
%left AND
%left NOT
%left GT LT
%left GE LE EQ NE

%type<string> PROGRAM
%type<string> BLOCK
%type<string> LINE
%type<string> STEND
%type<string> ASSIGNMENT
%type<string> EXPRESSION
%type<string> DECLARATION
%type<string> DEFINITION
%type<string> LOGEXP
%type<string> TERM
%start PROGRAM

%%

/* Producciones */
PROGRAM		: STEND {printf("%s",strcatN(3,"int main(void)\n{",$1->string,"\n}"));};

/* Defino block como un bloque generico de codigo */
BLOCK 	: LINE END_STATEMENT {$$ = newNode(STRING, strcatN(,2, $1, "\n"));}
	| IF LOGEXP STEND {$$ = newNode(STRING,strcatN(4, "if(", $2,")\n", $3));}
	| IF LOGEXP STEND ELSE STEND {$$ = newNode(STRING, strcatN(6, "if(", $2,")\n", $3, "else\n", $5));}
	| DO STEND WHILE LOGEXP {$$ = newNode(STRING,strcatN(5, "do\n", $2,"while(", $4, ");\n"));}
	| LINE END_STATEMENT BLOCK {$$ = newNode(STRING, strcatN(3, $1, "\n", $3));};

LINE	: ASSIGNMENT {$$ = newNode(STRING, $1);}
	| DECLARATION {$$ = newNode(STRING, $1);}
	| DEFINITION {$$ = newNode(STRING, $1);};

STEND	: START BLOCK END {$$ = strcatN(3,"{\n", $2,"}\n");};
STEND	: START BLOCK END {$$ = newNode(STRING, strcatN(3,"{\n", $2,"}\n"))};

ASSIGNMENT	: ID IS EXPRESSION {$$ = newNode($3->type,strcatN(4,$1,"=",$3,";"));};

DECLARATION	: NUMBER_T ID { insertSymbol((char*)$2, TYPE_NUMBER); $$ = newNode(INTEGER,strcatN(3,"int ",$2,";")); }
		| TEXT_T ID { insertSymbol((char*)$2, TYPE_TEXT); $$ = newNode(STRING, strcatN(3,"char* ",$2,";")); };

DEFINITION	: NUMBER_T ID IS EXPRESSION { insertSymbol((char*)$2, TYPE_NUMBER);
										if($4->type == STRING)
											yyerror("Cant assign text to integer");
										$$ = strcatN(5,"int ",$2,"=",$4,";"); }
		| TEXT_T ID IS EXPRESSION { insertSymbol((char*)$2, TYPE_TEXT);
								if($4->type == INTEGER)
									yyerror("Cant assign integer to text");
								$$ = strcatN(5,"char* ",$2,"=",$4,";"); };

EXPRESSION	: LPARENT EXPRESSION RPARENT {$$ = newNode($2->type, strcatN(3,"(",$2,")"));}
		| EXPRESSION PLUS EXPRESSION {checkType($1->type, $3->type); 
									if($1->type == STRING)
									{
										$$ = newNode(STRING, strcatN(2,$1,$3));
									}
									else
										$$ = newNode($1->type, $2->strcatN(5,"(",$1,")+(",$3,")"));
									}
		| EXPRESSION MINUS EXPRESSION {if($1->type == STRING || $3->type == STRING)
									{
										yyerror("invalid operation - requires number type.")
									}
									else
										$$ = newNode(INTEGER,strcatN(5,"(",$1,")-(",$3,")"));
									}
		| EXPRESSION MUL EXPRESSION {if($1->type == STRING || $3->type == STRING)
									{
										yyerror("invalid operation * requires number type.")
									}
									else
										$$ = newNode(INTEGER, strcatN(5,"(",$1,")*(",$3,")"));
									}
		| EXPRESSION DIV EXPRESSION {if($1->type == STRING || $3->type == STRING)
									{
										yyerror("invalid operation / requires number type.")
									}
									else{
										if(atoi($3) == 0)
											yerror("divide by zero error");
										else
											$$ = newNode(INTEGER, strcatN(5,"(",$1,")/(",$3,")"));

									}};

		| EXPRESSION MOD EXPRESSION {if($1->type == STRING || $3->type == STRING)
									{
										yyerror("invalid operation % requires number type.")
									}
									else
									{
										if(atoi($3) == 0)
											yerror("division by zero not defined");
										else
											$$ = newNode(INTEGER, strcatN(5,"(",$1,")%(",$3,")"));
									}};
									

		| TERM  {$$ = newNode($1->type,$1);};

/* En C es lo mismo una expresion o una expresion logica pero
quizas aca como es mas verborragico convenga separarlas*/

LOGEXP	: NOT LOGEXP {$$ = strcatN(3,"(!(",$2,"))");}
	| LOGEXP AND LOGEXP {$$ = strcatN(5,"(",$1,"&&",$3,")");}
	| LOGEXP OR LOGEXP {$$ = strcatN(5,"(",$1,"||",$3,")");}
	| LPARENT LOGEXP RPARENT {$$ = strcatN(3,"(",$2,")");}
	| LPARENT LOGEXP RPARENT EQ LPARENT LOGEXP RPARENT {$$ = strcatN(5,"(",$2,"==",$6,")");}
	| LPARENT LOGEXP RPARENT NE LPARENT LOGEXP RPARENT {$$ = strcatN(5,"(",$2,"!=",$6,")");}
	| EXPRESSION GT EXPRESSION {$$ = strcatN(5,"(",$1,">",$3,")");}
	| EXPRESSION LT EXPRESSION {$$ = strcatN(5,"(",$1,"<",$3,")");}
	| EXPRESSION LE EXPRESSION {$$ = strcatN(5,"(",$1,"<=",$3,")");}
	| EXPRESSION GE EXPRESSION {$$ = strcatN(5,"(",$1,">=",$3,")");}
	| EXPRESSION EQ EXPRESSION {$$ = strcatN(5,"(",$1,"==",$3,")");}
	| EXPRESSION NE EXPRESSION {$$ = strcatN(5,"(",$1,"!=",$3,")");};

TERM	: ID {$$ = newNode(,$1);}
	| NUM_C {$$ = newNode(INTEGER, $1);}
	| TEXT_C {$$ = newNode(STRING, $1);};

%%

void yyerror(const char * s)
{
	printf(stderr, "ERROR: %s on line %d\n", s, linenum);
	exit(1);
}

char* strcatN(int num, ...)
{
	int i, length;
	char* toAdd, ret;

	va_list strings;
	va_start(strings, num);
	toAdd = va_arg(strings, char*);

	length = strlen(toAdd + 1);
	ret = (char*)malloc(sizeof(char) * length);
	strcpy(ret, toAdd);
	for(i = 1; i < num ; i++)
	{
		toAdd = va_arg(strings, char*);
		length += strlen(toAdd);
		ret = (char*)realloc(ret, length * sizeof(char));
		strcat(ret, toAdd);
	}
	va_end(strings);
	return ret;
}

void checkType(int t1, int t2)
{
	if(t1 != t2)
		yyerror("Diferent datatypes error");
}


void insertSymbol(char * symbol, int symbolType)
{
	int index;
 	for(index = 0; index < symbols; index++) {
		if(strcmp(symbol, symbolsTable[index]) == 0) {
			if(symbolsType[index] == symbolType)
				yyerror("Redeclaration of variable");
			else
				yyerror("Multiple Declaration of Variable");
		}
	}

	symbolsType[symbols] = symbolType;
	strcpy(symbolsTable[symbols], symbol);
	symbols++;
}

int main(void){
	yyparse();
}
