%{
  #include <stdio.h>
  
  #define MAS 1
  #define MUL 2
  #define ID 3
  #define LPAR 4
  #define RPAR 5

  int token;
%}
%%
"+"                           return MAS;
"*"                           return MUL;
"id"                          return ID;
"("                           return LPAR;
")"                           return RPAR;
[ ]+                          ;
(.|\n)+                       exit (0);
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
  printf("Error sintáctico.\n");
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
