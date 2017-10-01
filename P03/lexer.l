%{
  #include <stdlib.h>
  #include <string.h>
  
  // Buffer para guardar los strings.
  char* buffer;
  void clean (int);
  void error (char*);

  #include "asa.h"
  #include "parser.tab.h"
%}
letra [A-Za-z]
digito [0-9]
blanco [ \f\r\t\v]
operador [-+*/<!]
simbolo [.,:;(){}=]
%x string
%x comment
%%
\n                            ++yylineno;
{blanco}+                     ;
"class"                       return CLASS;
"inherits"                    return INHERITS;
"return"                      return RETURN;
"super"                       return SUPER;
"if"                          return IF;
"else"                        return ELSE;
"while"                       return WHILE;
"switch"                      return SWITCH;
"case"                        return CASE;
"break"                       return BREAK;
"default"                     return DEFAULT;
"new"                         return NEW;
"int"|"boolean"               { yylval.vstring = strdup(yytext);
                                return TYPE;
                              }
[A-Z]({digito}|{letra}|"_")*  { yylval.vstring = strdup(yytext);
                                return TYPE;
                              }
"true"                        return TRUE_K;
"false"                       return FALSE_K;
"null"                        return NULL_K;
{digito}+                     { yylval.vinteger = atoi(yytext);
                                return INTEGER;
                              }
"this"                        { yylval.vstring = strdup(yytext);
                                return ID;
                              }
({digito}|{letra}|"_")+       { yylval.vstring = strdup(yytext);
                                return ID;
                              }
{simbolo}                     return *yytext;
{operador}                    return *yytext;
"<="                          return LE;
"=="                          return EQ;
\"                            { clean(1);
                                strcat(buffer,yytext);
                                BEGIN(string);
                              }
<string>(\\.|[^\\"\0\n])*     strcat(buffer,yytext);
<string>\"                    { strcat(buffer,yytext);
                                yylval.vstring = strdup(buffer);
                                BEGIN(INITIAL);
                                return STRING;
                              }
<string>\n                    { BEGIN(INITIAL);
                                error("Salto de línea en String.");
                                ++yylineno;
                              }
<string>\0                    { BEGIN(INITIAL);
                                error("Final de cadena en String.");
                              }
<string><<EOF>>               { BEGIN(INITIAL);
                                error("End Of File en String.");
                              }
"//"(.)*\n                    ++yylineno;
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
  fprintf(stderr, "*** Error léxico en línea %d: '%s'\n\t%s\n",
    yylineno, yytext, s);
  //exit(1);
}
