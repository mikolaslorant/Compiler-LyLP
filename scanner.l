/*
Flex scanner
Lorant Mikolas
Santiago Swinnen
Felipe Gorostiaga
Diego Luciano Bruno Cilla

Comment code from ppt provided by the professorship
Code for SAVE_TOKEN and TOKEN(t) from https://github.com/faturita/LlvmBasicCompiler/blob/master/tokens.l
Code for alpha and digit https://github.com/faturita/YetAnotherCompilerClass/blob/master/loopsample/looping
*/

%{
#include "node.h"
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

#define TYPE_NOTFOUND 0
#define TYPE_NUMBER 1
#define TYPE_TEXT 2

extern void yyerror(const char * msg);



int linenum = 1;
int open_parentheses = 0;
int open_braces = 0;


%}

%option noyywrap
%x comment

alpha [A-Za-z]
digit [0-9]

%%



"number"						return NUMBER_T;
"text"							return TEXT_T;





"is"							return IS;
"+"								return PLUS;
"-"								return MINUS;
"*"								return MUL;
"/"								return DIV;
"%"								return MOD;

"("								{open_parentheses++; return LPARENT;}
")"								{open_parentheses--;
								if(open_parentheses < 0)
									yyerror("extra closing parentheses");
								else
									return RPARENT;
								}
"["								yyerror("unrecognized token [");
"]"								yyerror("unrecognized token ]");
"{"								yyerror("unrecognized token {");
"}"								yyerror("unrecognized token }");

"is greater than"				return GT;
"is less than"					return LT;
"is greater than or equal to"	return GE;
"is less than or equal to"		return LE;
"is equal to"						return EQ;
"is not equal to"						return NE;
"and"							return AND;
"or"							return OR;

"if"							return IF;
"else"							return ELSE;
"do"							return DO;
"while"							return WHILE;
"not"							return NOT;



"." 							return END_STATEMENT;
"start"						return START;
"end"							return END;
"\n"							{linenum++;}
""
"\t"							/*ignore tabs*/

{alpha}({alpha}|{digit})*		{	char * str = (char*)malloc(strlen(yytext) * sizeof(char));
									strcpy(str, yytext);
									yylval.node = newNode(TYPE_TEXT,str); return ID;}
{digit}+						{	char * str = (char*)malloc(strlen(yytext) * sizeof(char));
									strcpy(str, yytext);
									yylval.node = newNode(TYPE_NUMBER,str); return NUM_C;}
\"(\\.|[^"\\])*\"				{	char * str = (char*)malloc(strlen(yytext) * sizeof(char));
									strcpy(str, yytext);
									yylval.node = newNode(TYPE_TEXT,str); return TEXT_C;}

"/*" 							BEGIN(comment);
<comment>[^*\n]*
<comment>"*"+[^*/\n]*

<comment>"*"+"/"				BEGIN(INITIAL);

%%