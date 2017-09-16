%{
  #include "definiciones.h"
%}
letra [A-Za-z]
digito [0-9]
keyword "class"|"inherits"|"super"|"this"|"if"|"else"|"switch"|"case"|"break"|"while"|"default"|"return"|"int"|"boolean"|"true"|"false"|"null"
blanco [ \n\f\r\t\v]
operador [+-*/<!]|"=="|"<="
%x string
%x comment
%%
{blanco}+                     ;
"."                           return PUNTO;
","                           return COMA;
":"                           return COLON;
";"                           return SCOLON;
"("                           return LPAR;
")"                           return RPAR;
"{"                           return LBRACKET;
"}"                           return RBRACKET;
"="                           return ASIGN;
{operador}                    return OPERADOR;
{digito}+                     return ENTERO;
({digito}|{letra}|"_")+       return ID;
"//"[^\n]*\n                  ;

\"                            BEGIN(string);
<string>(\\.|[^\\"\0])*       ;
<string>\"                    {fwrite("3\n",1,2,yyout);BEGIN(INITIAL);}
<string><<EOF>>               {fwrite(yytext,1,yyleng,yyout);fwrite(error,1,len,yyout);BEGIN(INITIAL);}
"/*"                          BEGIN(comment);
<comment>[^*\n]*              ;
<comment>"*"+[^*/\n]*         ;
<comment>"*"+"/"              {fwrite("6\n",1,2,yyout);BEGIN(INITIAL);}
%%
int
yywrap (void) {
  return 1;
}
