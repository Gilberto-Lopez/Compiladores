%{
  #include "definiciones.h"
%}
letra [A-Za-z]
digito [0-9]
keyword "class"|"inherits"|"super"|"this"|"if"|"else"|"switch"|"case"|"break"|"while"|"default"|"return"|"int"|"boolean"|"true"|"false"|"null"
blanco [ \f\r\t\v]
operador [-+*/<!]|"=="|"<="
%x string
%x comment
%%
\n                            ++yylineno;
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
"//"(.)*\n                    ++yylineno;
\"                            { clean(1);
                                strcat(buffer,yytext);
                                BEGIN(string);
                              }
<string>(\\.|[^\\"\0\n])*     strcat(buffer,yytext);
<string>\"                    { strcat(buffer,yytext);
                                BEGIN(INITIAL);
                                return STRING;
                              }
<string>\n                    { BEGIN(INITIAL);
                                error("Salto de linea en String.");
                                ++yylineno;
                              }
<string>\0                    { BEGIN(INITIAL);
                                error("Final de cadena en String.");
                              }
<string><<EOF>>               { BEGIN(INITIAL);
                                error("End Of File en String.");
                              }
"/*"                          BEGIN(comment);
<comment>\n                   ++yylineno;
<comment>[^*\n]*              ;
<comment>"*"+[^*/\n]*         ;
<comment>"*"+"/"              BEGIN(INITIAL);
.                             error("No se reconoce la cadena.");
%%
int
yywrap (void) {
  return 1;
}

/* Limpia BUFFER para los strings si F es 1.
 * Crea un string vacío con malloc en BUFFER. */
void
clean (int f) {
  if (f)
    free(buffer);
  buffer = malloc (sizeof (char));
  buffer[0] = '\0';
}

/* Imprime un mensaje de error S cuando ocurre un error léxico
 * y señala la línea y token que causaron el error. */
void
error (char* s) {
  printf("*** Error léxico en línea %d: '%s'\n%s\n", yylineno, yytext, s);
}

int
main(int argc, char const *argv[]) {
  clean (0);
  yyin = fopen (argv[1],"r");
  int token = yylex ();
  while (token) {
    if (token == STRING)
      printf("%s\t%d %d\n", buffer, token, yylineno);
    else
      printf("%s\t%d %d\n", yytext, token, yylineno);
    token = yylex ();
  }
  fclose (yyin);
  return 0;
}
