%{
  #include "defs.h"

  int tok;
%}
blanco [ \n\f\r\t\v]
%x comment
%%
"--"[^\n]*\n                  ;
","                           return COMMA;
";"                           return SCOLON;
"int"                         return INT;
"float"                       return FLOAT;
"id"                          return ID;
"num"                         return NUM;
":="                          return ASSGN;
"+"                           return PLUS;
"-"                           return MINUS;
"*"                           return PROD;
"/"                           return DIV;
"%"                           return MOD;
"("                           return LPAR;
")"                           return RPAR;
{blanco}+                     ;
%%
int
yywrap (void) {
  return 1;
}

void
P (void) {
  D ();
  S ();
}

void
D (void) {
  U ();
  L ();
  if (tok == SCOLON) {
    tok = yylex ();
    DP ();
  } else
    error ();
}

void
DP (void) {
  if (tok == INT || tok == FLOAT) {
    U ();
    L ();
    if (tok == SCOLON) {
      tok = yylex ();
      DP ();
    } else
      error ();
  }
}

void
U (void) {
  if (tok == INT || tok == FLOAT)
    tok = yylex ();
  else
    error ();
}

void
L (void) {
  if (tok == ID) {
    tok = yylex ();
    LP ();
  } else
    error ();
}

void
LP (void) {
  if (tok == COMMA) {
    tok = yylex ();
    if (tok == ID) {
      tok = yylex ();
      LP ();
    }
  }
}

void
S (void) {
  if (tok == ID) {
    tok = yylex ();
    if (tok == ASSGN) {
      tok = yylex ();
      E ();
      if (tok == SCOLON) {
        SP ();
      } else
        error ();
    } else
      error ();
  } else
    error ();
}

void
SP (void) {
  if (tok == ID) {
    tok = yylex ();
    if (tok == ASSGN) {
      tok = yylex ();
      E ();
      if (tok == SCOLON) {
        SP ();
      } else
        error ();
    } else
      error ();
  }
}

void
E (void) {
  T ();
  EP ();
}

void
EP (void) {
  if (tok == PLUS || tok == MINUS) {
    tok = yylex ();
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
  if (tok == PROD || tok == DIV || tok == MOD) {
    F ();
    TP ();
  }
}

void
F (void) {
  if (tok == ID || tok == NUM)
    tok = yylex ();
  else if (tok == LPAR) {
    tok = yylex ();
    E ();
    if (tok == RPAR)
      tok = yylex ();
    else
      error ();
  } else
    error ();
}

void
error (void) {
  printf(yytext);
  printf("Error sintáctico\n");
  exit (0);
}

int
main (int argc, char* argv[]) {
  yyin = fopen (argv[1],"r");
  tok = yylex ();
  E ();
  if (tok != 0)
    error ();
  fclose (yyin);
}
