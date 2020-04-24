%{
	#include "myyacc.tab.h"
	int Oct2Dec(char temp[]);
	int Hex2Dec(char temp[]);
%}
delim		[ \t\n\r]
ws		{delim}+
letter		[A-Za-z]
digit		[0-9]
id		{letter}({letter}|{digit})*
integer		(0|[1-9][0-9]*)
exponent	E[+-]?{integer}
number		{integer}{exponent}?
hexadecimal     0[xX][a-fA-F0-9]+(\.[0-9a-fA-F][0-9a-fA-F]+)?
octal		0[0-7]+(\.[0-7][0-7]+)?
real		integer(\.integer)?{exponent}?
%option noyywrap
%%
"<"|"<="|">"|">="|"!="|"=="	{ filloperator(&yylval, yytext); return( REL); }
if	{ return( IF ); }
else 	{ return( ELSE ); }
while	{ return( WHILE ); }
do	{ return( DO ); }
for	{ return( FOR ); }
switch	{ return( SWITCH ); }
case	{ return( CASE ); }
default	{ return( DEFAULT ); }
break	{ return( BREAK ); }
true	{ return( TRUE ); }
false	{ return( FALSE ); }
int	{ return( INT ); }
long	{ return( LONG ); }
char	{ return( CHAR ); }
bool	{ return( BOOL ); }
float	{ return( FLOAT ); }
double	{ return( DOUBLE ); }
"&&"	{ return( AND ); }
"||"	{ return( OR ); }
"!"	{ return( '!'); }
"++"	{ return( INC ); }
"--"	{ return( DEC ); }
"+"	{ return( '+' ); }
"-"	{ return( '-' ); }
"*"	{ return( '*' ); }
"/"	{ return( '/' ); }
"="	{ return( '=' ); }
"{"	{ return( '{' ); }
"}"	{ return( '}' ); }
"["	{ return( '[' ); }
"]"	{ return( ']' ); }
"("	{ return( '(' ); }
")"	{ return( ')' ); }
";"	{ return( ';' ); }
{ws}	{ }
{id}	{ filllexeme(&yylval, yytext); return( ID ); }
{number}	{ filllexeme(&yylval, yytext); return( NUMBER ); }
{real}		{ filllexeme(&yylval, yytext); return( REAL ); }
{hexadecimal}	{char tmp[1024]; sprintf(tmp,"%d",Hex2Dec(yytext));
                filllexeme(&yylval, tmp); return(INT16);}
{octal}		{char tmp[1024]; sprintf(tmp,"%d",Oct2Dec(yytext));
                filllexeme(&yylval, tmp); return(INT8);}
%%
int Oct2Dec(char temp[])						//整数八进制转十进制
{
	int sum = 0;
	for (int i = 1;i < strlen(temp);i++)
	{
		sum = sum * 8 + temp[i] - '0';
	}
	return sum;
}
int Hex2Dec(char temp[])						//整数十六进制转十进制
{
	int sum = 0;
	int mid[100];
	for (int ii = 0;ii < strlen(temp);ii++)
	{
		if (temp[ii] == 'a' || temp[ii] == 'A')
			mid[ii] = 10;
		else if (temp[ii] == 'b' || temp[ii] == 'B')
			mid[ii] = 11;
		else if (temp[ii] == 'c' || temp[ii] == 'C')
			mid[ii] = 12;
		else if (temp[ii] == 'd' || temp[ii] == 'D')
			mid[ii] = 13;
		else if (temp[ii] == 'e' || temp[ii] == 'E')
			mid[ii] = 14;
		else if (temp[ii] == 'f' || temp[ii] == 'F')
			mid[ii] = 15;
		else mid[ii] = temp[ii] - '0';
	}
	int i;
	for (i = 2;i < strlen(temp);i++)
	{
		sum = sum * 16 + mid[i];
	}
	return sum;
}
