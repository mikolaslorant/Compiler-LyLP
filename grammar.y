%{
	#include "node.h"
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include <string.h>
	

	#define MAX_SYMBOLS 100
	#define MAX_SYMBOL_LENGTH 100

	#define TYPE_NOTFOUND 0
	#define TYPE_NUMBER 1
	#define TYPE_TEXT 2

	extern int yylex();
	extern int linenum;

	char symbolsTable[MAX_SYMBOL_LENGTH][MAX_SYMBOLS];
	int symbols = 0, symbolsType[MAX_SYMBOLS];

	void yyerror(const char * s);
	char* strcatN(int num, ...);
	void insertSymbol(char * symbol, int symbolType);
	int getType(char * symbol);
	void checkType(int t1, int t2);

%}

%union
{
	Node *node;
}


%token<node> NUMBER_T
%token<node> TEXT_T

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
%token SEE
%token<node> IF
%token<node> ELSE
%token<node> DO
%token<node> WHILE
%token<node> NOT
%token<node> START
%token<node> END
%token<node> ID
%token<node> NUM_C
%token<node> TEXT_C
%token<node> END_STATEMENT

%right IS
%left PLUS MINUS
%left MUL DIV MOD
%left OR
%left AND
%left NOT
%left GT LT
%left GE LE EQ NE

%type<node> PROGRAM
%type<node> BLOCK
%type<node> LINE
%type<node> STEND
%type<node> ASSIGNMENT
%type<node> EXPRESSION
%type<node> DECLARATION
%type<node> DEFINITION
%type<node> LOGEXP
%type<node> TERM
%start PROGRAM

%%

/* Producciones */
PROGRAM		: STEND {printf("%s",strcatN(3,"#include <stdio.h>\nint main(void)\n",$1->string,"\n"));};

/* Defino block como un bloque generico de codigo */
BLOCK 	: LINE END_STATEMENT {$$ = newNode(TYPE_TEXT, strcatN(2, $1->string, "\n"));}
	| IF LOGEXP STEND {$$ = newNode(TYPE_TEXT,strcatN(4, "if(", $2->string,")\n", $3->string));}
	| IF LOGEXP STEND ELSE STEND {$$ = newNode(TYPE_TEXT, strcatN(6, "if(", $2->string,")\n", $3->string, "else\n", $5->string));}
	| DO STEND WHILE LOGEXP  {$$ = newNode(TYPE_TEXT,strcatN(5, "do\n", $2->string,"while(", $4->string, ");\n"));}
	| IF LOGEXP STEND BLOCK{$$ = newNode(TYPE_TEXT,strcatN(5, "if(", $2->string,")\n", $3->string,"\n", $4->string));}
	| IF LOGEXP STEND ELSE STEND BLOCK{$$ = newNode(TYPE_TEXT, strcatN(8, "if(", $2->string,")\n", $3->string, "else\n", $5->string,"\n", $6->string));}
	| DO STEND WHILE LOGEXP BLOCK {$$ = newNode(TYPE_TEXT,strcatN(6, "do\n", $2->string,"while(", $4->string, ");\n",$5->string));}
	| LINE END_STATEMENT BLOCK {$$ = newNode(TYPE_TEXT, strcatN(3, $1->string, "\n", $3->string));};

LINE	: ASSIGNMENT {$$ = newNode(TYPE_TEXT, $1->string);}
	| DECLARATION {$$ = newNode(TYPE_TEXT, $1->string);}
	| DEFINITION {$$ = newNode(TYPE_TEXT, $1->string);}
	| SEE EXPRESSION {if($2->type == TYPE_TEXT)
						$$ = newNode(TYPE_TEXT, strcatN(3,"printf(\"%s\n\",", $2->string, ");"));
					else
						$$ = newNode(TYPE_TEXT, strcatN(3,"printf(\"%d\n\",", $2->string, ");"));
					};

STEND	: START BLOCK END {$$ = newNode(TYPE_TEXT, strcatN(3,"{\n", $2->string,"}\n"));}
	| START END {$$ = newNode(TYPE_TEXT, "");};

ASSIGNMENT	: ID IS EXPRESSION {checkType(getType($1->string), $3->type);
								$$ = newNode($3->type,strcatN(4,$1->string,"=",$3->string,";"));};

DECLARATION	: NUMBER_T ID { insertSymbol($2->string, TYPE_NUMBER); 
							$$ = newNode(TYPE_TEXT,strcatN(3,"int ",$2->string,";")); }
		| TEXT_T ID { insertSymbol((char*)$2, TYPE_TEXT); 
					$$ = newNode(TYPE_TEXT, strcatN(3,"char* ",$2->string,";")); };

DEFINITION	: NUMBER_T ID IS EXPRESSION { insertSymbol($2->string, TYPE_NUMBER);
										if($4->type == TYPE_TEXT)
											yyerror("Cant assign text to integer");
										$$ = newNode(TYPE_TEXT,strcatN(5,"int ",$2->string,"=",$4->string,";")); }
		| TEXT_T ID IS EXPRESSION { insertSymbol($2->string, TYPE_TEXT);
									if($4->type == TYPE_NUMBER)
										yyerror("Cant assign integer to text");
									$$ = newNode(TYPE_TEXT, strcatN(5,"char* ",$2->string,"=",$4->string,";")); };

EXPRESSION	: LPARENT EXPRESSION RPARENT {$$ = newNode($2->type, strcatN(3,"(",$2->string,")"));}
		| EXPRESSION PLUS EXPRESSION {checkType($1->type, $3->type); 
									if($1->type == TYPE_TEXT)
									{
										$$ = newNode(TYPE_TEXT, strcatN(2,$1->string,$3->string));
									}
									else
										$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,")+(",$3->string,")"));
									}
		| EXPRESSION MINUS EXPRESSION {if($1->type == TYPE_TEXT || $3->type == TYPE_TEXT)
									{
										yyerror("invalid operation - requires number type.");
									}
									else
										$$ = newNode(TYPE_NUMBER,strcatN(5,"(",$1->string,")-(",$3->string,")"));
									}
		| EXPRESSION MUL EXPRESSION {if($1->type == TYPE_TEXT || $3->type == TYPE_TEXT)
									{
										yyerror("invalid operation * requires number type.");
									}
									else
										$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,")*(",$3->string,")"));
									}
		| EXPRESSION DIV EXPRESSION {if($1->type == TYPE_TEXT || $3->type == TYPE_TEXT)
									{
										yyerror("invalid operation / requires number type.");
									}
									else{
										if(atoi($3->string) == 0)
											yyerror("divide by zero error");
										else
											$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,")/(",$3->string,")"));

									}};

		| EXPRESSION MOD EXPRESSION {if($1->type == TYPE_TEXT || $3->type == TYPE_TEXT)
									{
										yyerror("invalid operation % requires number type.");
									}
									else
									{
										if(atoi($3->string) == 0)
											yyerror("division by zero not defined");
										else
											$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,")%(",$3->string,")"));
									}};
									

		| TERM  {$$ = $1;};

/* En C es lo mismo una expresion o una expresion logica pero
quizas aca como es mas verborragico convenga separarlas*/

LOGEXP	: NOT LOGEXP {$$ = newNode(TYPE_NUMBER, strcatN(3,"(!(",$2->string,"))"));}
	| LOGEXP AND LOGEXP {$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,"&&",$3->string,")"));}
	| LOGEXP OR LOGEXP {$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,"||",$3->string,")"));}
	| LPARENT LOGEXP RPARENT {$$ = newNode(TYPE_NUMBER, strcatN(3,"(",$2->string,")"));}
	| LPARENT LOGEXP RPARENT EQ LPARENT LOGEXP RPARENT {$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$2->string,"==",$6->string,")"));}
	| LPARENT LOGEXP RPARENT NE LPARENT LOGEXP RPARENT {$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$2->string,"!=",$6->string,")"));}
	| EXPRESSION GT EXPRESSION {checkType($1->type, $3->type);
								if($1->type == TYPE_NUMBER)
								{
									$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,">",$3->string,")"));
								}
								else
								{
									if(strcmp($1->string, $3->string) > 0)
										$$ = newNode(TYPE_NUMBER, "(1)");
									else 
										$$ = newNode(TYPE_NUMBER, "(0)");
								}}


	| EXPRESSION LT EXPRESSION {checkType($1->type, $3->type);
								if($1->type == TYPE_NUMBER)
								{
									$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,"<",$3->string,")"));
								}
								else
								{
									if(strcmp($1->string, $3->string) < 0)
										$$ = newNode(TYPE_NUMBER, "(1)");
									else 
										$$ = newNode(TYPE_NUMBER, "(0)");
								}}
								
	| EXPRESSION LE EXPRESSION {checkType($1->type, $3->type);
								if($1->type == TYPE_NUMBER)
								{
									$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,"<=",$3->string,")"));
								}
								else
								{
									if(strcmp($1->string, $3->string) <= 0)
										$$ = newNode(TYPE_NUMBER, "(1)");
									else 
										$$ = newNode(TYPE_NUMBER, "(0)");
								}}
		
	| EXPRESSION GE EXPRESSION {checkType($1->type, $3->type);
								if($1->type == TYPE_NUMBER)
								{
									$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,">=",$3->string,")"));
								}
								else
								{
									if(strcmp($1->string, $3->string) >= 0)
										$$ = newNode(TYPE_NUMBER, "(1)");
									else 
										$$ = newNode(TYPE_NUMBER, "(0)");
								}}
		
	| EXPRESSION EQ EXPRESSION {checkType($1->type, $3->type);
								if($1->type == TYPE_NUMBER)
								{
									$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,"==",$3->string,")"));
								}
								else
								{
									if(strcmp($1->string, $3->string) == 0)
										$$ = newNode(TYPE_NUMBER, "(1)");
									else 
										$$ = newNode(TYPE_NUMBER, "(0)");
								}}
	| EXPRESSION NE EXPRESSION {checkType($1->type, $3->type);
								if($1->type == TYPE_NUMBER)
								{
									$$ = newNode(TYPE_NUMBER, strcatN(5,"(",$1->string,"!=",$3->string,")"));
								}
								else
								{
									if(strcmp($1->string, $3->string) != 0)
										$$ = newNode(TYPE_NUMBER, "(1)");
									else 
										$$ = newNode(TYPE_NUMBER, "(0)");
								}}

TERM	: ID {$$ = newNode(getType($1->string),$1->string);}
	| NUM_C {$$ = newNode(TYPE_NUMBER, $1->string);}
	| TEXT_C {$$ = newNode(TYPE_TEXT, $1->string);};

%%

void yyerror(const char * s)
{
	fprintf(stderr, "ERROR: %s on line %d\n", s, linenum);
	exit(1);
}

char* strcatN(int num, ...)
{
	int i, length;
	char* toAdd;
	char* ret;

	va_list strings;
	va_start(strings, num);
	toAdd = va_arg(strings, char*);

	length = 0;
	length = strlen(toAdd)+ 1;

	ret = (char*)malloc(sizeof(char) * length);
	strcpy(ret, toAdd);
	for(i = 1; i < num ; i++)
	{
		toAdd = va_arg(strings, char*);
		length += strlen(toAdd);
		ret = (char*)realloc((void*)ret, length * sizeof(char));
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

int getType(char * symbol) 
{
	int index;
	for(index = 0; index < symbols; index++) {
		if(strcmp(symbol, symbolsTable[index]) == 0) {
			return symbolsType[index];
		}
	}

	return TYPE_NOTFOUND;
}

int main(void){
	yyparse();
}
