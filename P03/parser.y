%{
  #include <stdio.h>
  #include <stdlib.h>
  
  // Lex
  extern int yylex ();
  extern char* yytext;
  extern FILE* yyin;
  //extern FILE* yyout;
  extern int yylineno;

  //extern int yyparse ();
  void yyerror (char*);
  
  #include "asa.h"
%}
%start program
%union{
  char* vstring;
  int vinteger;
  List* lista;
  Programa* programa;
  Class* clase;
  Feature* miembro;
  Formal* param;
  Expr* exp;
}
%token CLASS TYPE ID INHERITS SUPER WHILE SWITCH NEW INTEGER STRING BREAK DEFAULT CASE ELSE IF RETURN NULL_K TRUE_K FALSE_K
%nonassoc '<' LE EQ
%left '+' '-'
%left '*' '/'
%type<vstring> TYPE ID STRING
%type<vinteger> INTEGER TRUE_K FALSE_K
%type<lista> formal_list expr_list exprc_list case_list feature_list default_clause default_clause
%type<programa> program
%type<clase> class
%type<miembro> feature
%type<param> formal
%type<exp> expr
%%
program:
  class
    { Programa* p;
      new_program (&p);
      agrega (p->clases, $1);
      $$ = p;
      //generar_arbol (p);
    }
  | program class
    { agrega ($1->clases, $2); }
  ;

class:
  CLASS TYPE '{' feature_list '}'
    { Class* c;
      new_class (&c, $2, NULL, $4);
      $$ = c;
    }
  | CLASS TYPE INHERITS TYPE '{' feature_list '}'
    { Class* c;
      new_class (&c, $2, $4, $6);
      $$ = c;
    }
  ;

/* Listas (posiblemente vacías) de feature. */
feature_list:
  %empty
    { List* l;
      nueva_lista (&l, L_FEATURE);
      $$ = l;
    }
  | feature_list feature
    { agrega ($1, $2); }
  ;

feature:
  TYPE ID '(' formal_list ')' '{' expr_list RETURN expr ';' '}'
    { Feature* f;
      new_feature (&f, F_METHOD, $1, $2, $9, $4, $7);
      $$ = f;
    }
  | TYPE ID ';'
    { Feature* f;
      new_feature (&f, F_DEC, $1, $2, NULL, NULL, NULL);
      $$ = f;
    }
  | TYPE ID '=' expr ';'
    { Feature* f;
      new_feature (&f, F_DASGN, $1, $2, $4, NULL, NULL);
      $$ = f; 
    }
  ;

/* Listas (posiblemente vacías de) de formal. */
formal_list:
  %empty
    { $$ = NULL;
    /*List* l;
      nueva_lista (&l, L_FORMAL);
      $$ = l;*/
    }
  | formal
    { List* l;
      nueva_lista (&l, L_FORMAL);
      agrega (l, $1);
      $$ = l;
    }
  | formal_list ',' formal
    { agrega ($1, $3); }
  ;

/* Listas (posiblemente vacías) de expr. */
expr_list:
  %empty
    { List* l;
      nueva_lista (&l, L_EXPR);
      $$ = l;
    }
  | expr_list expr ';'
    { agrega ($1, $2); }
  ;

formal:
  TYPE ID
    { Formal* f;
      new_formal (&f, $1, $2);
      $$ = f;
    }
  ;

expr:
  ID '=' expr
  | expr '.' ID '(' exprc_list ')'
  | expr '.' SUPER '.' ID '(' exprc_list ')'
  | ID '(' exprc_list ')'
  | IF '(' expr ')' '{' expr_list '}'
  | IF '(' expr ')' '{' expr_list '}' ELSE '{' expr_list '}'
  | WHILE '(' expr ')' '{' expr_list '}'
  | SWITCH '(' ID ')' '{' case_list default_clause '}'
  | NEW TYPE
  | expr '+' expr
  | expr '-' expr
  | expr '*' expr
  | expr '/' expr
  | expr '<' expr
  | expr LE expr
  | expr EQ expr
  | '!' expr
  | '(' expr ')'
  | ID
  | INTEGER
  | STRING
  | TRUE_K
  | FALSE_K
  | NULL_K
  ;

/* Listas (posiblemente vacías) de expr con separación de comas. */
exprc_list:
  %empty
    { $$ = NULL;
    /*List* l;
      nueva_lista (&l, L_EXPRC);
      $$ = l;*/
    }
  | expr
    { List* l;
      nueva_lista (&l, L_EXPRC);
      agrega (l, $1);
      $$ = l;
    }
  | exprc_list ',' expr
    { agrega ($1, $3); }
  ;

/* Listas (posiblemente vacías) de cases. */
case_list:
  %empty
    { List* l;
      nueva_lista (&l, L_CASE);
      $$ = l;
    }
  | case_list CASE INTEGER ':' expr_list BREAK ';'
    { Valor* v;
      new_value (&v, V_INT, $3, NULL);
      Construccion* c;
      new_construct (&c, E_CASE, v, $5, NULL);
      agrega ($1, c);
    }
  ;

/* Claúsula default (opcional) para el switch. */
default_clause:
  %empty
    { $$ = NULL; }
  | DEFAULT ':' expr_list
    { $$ = $3; }
  ;
%%
/* Imprime mensajes de error por yyparse (). */
void
yyerror (char* s) {
  (void) s;
  fprintf(stderr, "*** Error sintáctico en línea %d: '%s'\n",
    yylineno, yytext);
  //exit(1);
}

int
main (int argc, char* argv[]) {
  yyin = fopen (argv[1],"r");
  yyparse ();
  fclose (yyin);
  return 0;
}
