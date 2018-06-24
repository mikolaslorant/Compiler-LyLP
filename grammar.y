/*https://www.tutorialspoint.com/cprogramming/c_variable_arguments.htm*/
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>

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
	char* string;
}


%start<string> PROGRAM
%token<string> BLOCK
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
PROGRAM		: STEND {printf("%s",strcatN(3,"int main(void)\n{",$1,"\n}"));};

/* Defino block como un bloque generico de codigo */
BLOCK 	: LINE END_STATEMENT {$$ = strcatN(2, $1, ";");}
	| IF LOGEXP STEND {$$ = strcatN(4, "if(", $2,")\n", $3);}
	| IF LOGEXP STEND ELSE STEND {$$ = strcatN(6, "if(", $2,")\n", $3, "else\n", $5);}
	| DO STEND WHILE LOGEXP {$$ = strcatN(5, "do\n", $2,"while(", $4, ");\n");}
	| LINE END_STATEMENT BLOCK {$$ = strcatN(3, $1, ";\n", $3);};

LINE	: ASSIGNMENT {$$ = $1}
	| DECLARATION {$$ = $1}
	| DEFINITION {$$ = $1}
	;

STEND	: START BLOCK END {$$ = strcatN(3,"{\n", $2,"}\n")};

ASSIGNMENT	: ID IS EXPRESSION {$$ = strcatN(4,$1,"=",$3,";");};

DECLARATION	: NUMBER_T ID { insertSymbol((char*)$2, TYPE_NUMBER);
}
		| TEXT_T ID { insertSymbol((char*)$2, TYPE_TEXT); };

DEFINITION	: NUMBER_T ID IS EXPRESSION { insertSymbol((char*)$2, TYPE_NUMBER); $2->ivalue = $4->ivalue; }
		| TEXT_T ID IS TEXT_C { insertSymbol((char*)$2, TYPE_TEXT); $2->svalue = $4->svalue; };

EXPRESSION	: LPARENT EXPRESSION RPARENT {$$ = strcatN(3,"(",$2,")");}
		| EXPRESSION PLUS EXPRESSION {$$ = strcatN(5,"(",$1,")+(",$3,")";}
		| EXPRESSION MINUS EXPRESSION {$$ = strcatN(5,"(",$1,")-(",$3,")";}
		| EXPRESSION MUL EXPRESSION {$$ = strcatN(5,"(",$1,")*(",$3,")";}
		| EXPRESSION DIV EXPRESSION {if(atoi($3) == 0)
																	yerror("divide by zero error");
																		else
																$$ = {$$ = strcatN(5,"(",$1,")/(",$3,")";};
		| EXPRESSION MOD EXPRESSION {if(atoi($3) == 0)
																		yerror("division by zero not defined");
																		else
																$$ = {$$ = strcatN(5,"(",$1,")%(",$3,")";};

		| TERM  {$$ = $1;};

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

TERM	: ID {$$ = $1;}
	| NUM_C {$$ = $1;}
	| TEXT_C {$$ = $1;};

%%

void yyerror(char const* s)
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
	ret = (char*)malloc(sizeof(char) * length));
	strcpy(ret, toAdd);
	for(i = 1; i < num ; i++)
	{
		toAdd = va_arg(strings, char*);
		length += strlen(toAdd);
		ret = (char*)realloc(args, length * sizeof(char));
		strcat(args, toAdd);
	}
	va_end(strings);
	return ret;
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

int main(void){
	yyparse();
}
