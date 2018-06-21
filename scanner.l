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
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

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



"number"						return NUMBER;
"text"							return TEXT;





"is"							return IS;
"+"								return PLUS;
"-"								return MINUS;
"*"								return MUL;
"/"								return DIV;
"%"								return MOD;

"("								{open_parentheses++; return LPARENT}
")"								{open_parentheses--; 
								if(open_parentheses < 0) 
									yyerror("extra closing parentheses");
								else
									return RPAREN;
								}
"["								yyerror("unrecognized token [");
"]"								yyerror("unrecognized token ]");
"{"								yyerror("unrecognized token {");
"}"								yyerror("unrecognized token }");

"is greater than"				return GT;
"is less than"					return LT;
"is greater than or equal to"	return GE;
"is less than or equal to"		return LE;
"equals"						return EQ;
"not equal to"						return NE;
"and"							return AND;
"or"							return OR;	

"if"							return IF;
"else"							return ELSE;
"do"							return DO;
"until"							return UNTIL;
"not"							return NOT;



"." 							return END_STATEMENT
"start"							return START;
"end"							return END;
"\n"							{linenum++;}
""
"\t"							/*ignore tabs*/

{alpha}({alpha}|{digit})*		return ID;
{digit}+						{yylval.ivalue = atoi(yytext);return NUM;}
\"(\\.|[^"\\])*\"				{yylval.svalue = yytext; return TEXT_LITERAL;}	

"/*" 							BEGIN(comment);
<comment>[^*\n]*
<commment>"*"+[^*/\n]*
<INITIAL>\n 					++linenum;
<comment>"*"+"/"				BEGIN(INITIAL);

%%

int main(int argc, char *argv[])
{
	yylex();
	printf("# of lines = %d\n", linenum);
}
