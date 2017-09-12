%{
  #include "headers.h"

  int token;
%}
%%
"+"                           {ECHO;printf("\n");return MAS;}
"*"                           {ECHO;printf("\n");return MUL;}
"id"                          {ECHO;printf("\n");return ID;}
"("                           {ECHO;printf("\n");return LPAR;}
")"                           {ECHO;printf("\n");return RPAR;}
[ \t\n]+                      ;
%%
int
yywrap (void) {
  return 1;
}

void
E (void) {
  T ();
  EP ();
}

void
EP (void) {
  if (token == MAS) {
    token = yylex ();
    T ();
    EP ();
  }
}

void
T (void) {
  F ();
  TP ();
}

void
TP (void) {
  if (token == MUL) {
    token = yylex ();
    F ();
    TP ();
  }
}

void
F (void) {
  if (token == LPAR) {
    token = yylex ();
    E ();
    if (token == RPAR)
      token = yylex ();
    else
      error ();
  } else if (token == ID)
    token = yylex ();
  else
    error ();
}

void
error (void) {
  printf(yytext);
  printf("\tError sintáctico.\n");
}

void
init (void) {
  token = yylex ();
  E ();
  if (token != 0)
    error ();
}

int
main (int argc, char* argv[]) {
  yyin = fopen (argv[1],"r");
  init ();
  fclose (yyin);
}
