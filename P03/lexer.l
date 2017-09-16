%{
  #include "definiciones.h"

  char* buffer;
%}
letra [A-Za-z]
digito [0-9]
keyword "class"|"inherits"|"super"|"this"|"if"|"else"|"switch"|"case"|"break"|"while"|"default"|"return"|"int"|"boolean"|"true"|"false"|"null"
blanco [ \n\f\r\t\v]
operador [-+*/<!]|"=="|"<="
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
\"                            {init(1);strcat(buffer,yytext);BEGIN(string);}
<string>(\\.|[^\\"\0])*       strcat(buffer,yytext);
<string>\"                    {strcat(buffer,yytext);BEGIN(INITIAL);return STRING;}
<string><<EOF>>               {BEGIN(INITIAL);}
"/*"                          BEGIN(comment);
<comment>[^*\n]*              ;
<comment>"*"+[^*/\n]*         ;
<comment>"*"+"/"              BEGIN(INITIAL);
%%
int
yywrap (void) {
  return 1;
}

void
init (int f) {
  if (f)
    free(buffer);
  buffer = malloc (sizeof (char));
  buffer[0] = '\0';
}

int
main(int argc, char const *argv[])
{
  init (0);
  yyin = fopen (argv[1],"r");
  //yyout = fopen (argv[2],"w");
  int token = yylex ();
  while (token) {
    if (token == STRING)
      printf("\t%s",buffer);
    printf("%s\t%d\n", yytext, token);
    token = yylex ();
  }
  fclose (yyin);
  //fclose (yyout);
  return 0;
}