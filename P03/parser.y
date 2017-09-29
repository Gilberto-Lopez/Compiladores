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
  //char* asa;
  
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
%type<vinteger> INTEGER
%type<lista> feature_list formal_list expr_list exprc_list case_list default_clause
%type<programa> program
%type<clase> class
%type<miembro> feature
%type<param> formal
%type<exp> expr
%%
program:
  class
    { Programa* p; new_program (&p);
      agrega (p->clases, $1);
      $$ = p;
      //generar_arbol (&asa, p);
    }
  | program class
    { agrega ($1->clases, $2); }
  ;

class:
  CLASS TYPE '{' feature_list '}'
    { Class* c; new_class (&c, $2, NULL, $4);
      $$ = c;
    }
  | CLASS TYPE INHERITS TYPE '{' feature_list '}'
    { Class* c; new_class (&c, $2, $4, $6);
      $$ = c;
    }
  ;

/* Listas (posiblemente vacías) de feature. */
feature_list:
  %empty
    { List* l; nueva_lista (&l, L_FEATURE);
      $$ = l;
    }
  | feature_list feature
    { agrega ($1, $2); }
  ;

feature:
  TYPE ID '(' formal_list ')' '{' expr_list RETURN expr ';' '}'
    { Feature* f; new_feature (&f, F_METHOD, $1, $2, $9, $4, $7);
      $$ = f;
    }
  | TYPE ID ';'
    { Feature* f; new_feature (&f, F_DEC, $1, $2, NULL, NULL, NULL);
      $$ = f;
    }
  | TYPE ID '=' expr ';'
    { Feature* f; new_feature (&f, F_DASGN, $1, $2, $4, NULL, NULL);
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
    { List* l; nueva_lista (&l, L_FORMAL);
      agrega (l, $1);
      $$ = l;
    }
  | formal_list ',' formal
    { agrega ($1, $3); }
  ;

/* Listas (posiblemente vacías) de expr. */
expr_list:
  %empty
    { List* l; nueva_lista (&l, L_EXPR);
      $$ = l;
    }
  | expr_list expr ';'
    { agrega ($1, $2); }
  ;

formal:
  TYPE ID
    { Formal* f; new_formal (&f, $1, $2);
      $$ = f;
    }
  ;

expr:
  ID '=' expr
    { Valor* v; new_value (&v, V_ID, 0, $1);
      Expr* e_; new_expr (&e_, E_VAL, 0, NULL, NULL, NULL, v);
      Operandos* o; new_operands (&o, e_, $3);
      Expr* e; new_expr (&e, E_OPB, B_ASIGN, o, NULL, NULL, NULL);
      $$ = e;
    }
  | expr '.' ID '(' exprc_list ')'
    { Metodo* m; new_method (&m, $3, 0, $1, $5);
      Expr* e; new_expr (&e, E_APP, 0, NULL, NULL, m, NULL);
      $$ = e;
    }
  | expr '.' SUPER '.' ID '(' exprc_list ')'
    { Metodo* m; new_method (&m, $5, 1, $1, $7);
      Expr* e; new_expr (&e, E_APP, 0, NULL, NULL, m, NULL);
      $$ = e;
    }
  | ID '(' exprc_list ')'
    { Metodo* m; new_method (&m, $1, 0, NULL, $3);
      Expr* e; new_expr (&e, E_APP, 0, NULL, NULL, m, NULL);
      $$ = e;
    }
  | IF '(' expr ')' '{' expr_list '}'
    { Construccion* c; new_construct (&c, E_IF, $3, $6, NULL);
      Expr* e; new_expr (&e, E_IF, 0, NULL, c, NULL, NULL);
      $$ = e;
    }
  | IF '(' expr ')' '{' expr_list '}' ELSE '{' expr_list '}'
    { Construccion* c; new_construct (&c, E_IF, $3, $6, $10);
      Expr* e; new_expr (&e, E_IF, 0, NULL, c, NULL, NULL);
      $$ = e;
    }
  | WHILE '(' expr ')' '{' expr_list '}'
    { Construccion* c; new_construct (&c, E_WHILE, $3, $6, NULL);
      Expr* e; new_expr (&e, E_WHILE, 0, NULL, c, NULL, NULL);
      $$ = e;
    }
  | SWITCH '(' ID ')' '{' case_list default_clause '}'
    { Valor* v; new_value (&v, V_ID, 0, $3);
      Expr* e_; new_expr (&e_, E_VAL, 0, NULL, NULL, NULL, v);
      Construccion* c; new_construct (&c, E_SWITCH, e_, $6, $7);
      Expr* e; new_expr (&e, E_SWITCH, 0, NULL, c, NULL, NULL);
      $$ = e;
    }
  | NEW TYPE
    { Metodo* m; new_method (&m, $2, 0, NULL, NULL);
      Expr* e; new_expr (&e, E_INST, 0, NULL, NULL, m, NULL);
      $$ = e;
    }
  | expr '+' expr
    { Operandos* o; new_operands (&o, $1, $3);
      Expr* e; new_expr (&e, E_OPB, B_MAS, o, NULL, NULL, NULL);
      $$ = e;
    }
  | expr '-' expr
    { Operandos* o; new_operands (&o, $1, $3);
      Expr* e; new_expr (&e, E_OPB, B_MENOS, o, NULL, NULL, NULL);
      $$ = e;
    }
  | expr '*' expr
    { Operandos* o; new_operands (&o, $1, $3);
      Expr* e; new_expr (&e, E_OPB, B_POR, o, NULL, NULL, NULL);
      $$ = e;
    }
  | expr '/' expr
    { Operandos* o; new_operands (&o, $1, $3);
      Expr* e; new_expr (&e, E_OPB, B_DIV, o, NULL, NULL, NULL);
      $$ = e;
    }
  | expr '<' expr
    { Operandos* o; new_operands (&o, $1, $3);
      Expr* e; new_expr (&e, E_OPB, B_LT, o, NULL, NULL, NULL);
      $$ = e;
    }
  | expr LE expr
    { Operandos* o; new_operands (&o, $1, $3);
      Expr* e; new_expr (&e, E_OPB, B_LE, o, NULL, NULL, NULL);
      $$ = e;
    }
  | expr EQ expr
    { Operandos* o; new_operands (&o, $1, $3);
      Expr* e; new_expr (&e, E_OPB, B_EQ, o, NULL, NULL, NULL);
      $$ = e;
    }
  | '!' expr
    { Operandos* o; new_operands (&o, $2, NULL);
      Expr* e; new_expr (&e, E_NEG, 0, o, NULL, NULL, NULL);
      $$ = e;
    }
  | '(' expr ')'
    { $$ = $2; }
  | ID
    { Valor* v; new_value (&v, V_ID, 0, $1);
      Expr* e; new_expr (&e, E_VAL, 0, NULL, NULL, NULL, v);
      $$ = e;
    }
  | INTEGER
    { Valor* v; new_value (&v, V_INT, $1, NULL);
      Expr* e; new_expr (&e, E_VAL, 0, NULL, NULL, NULL, v);
      $$ = e;
    }
  | STRING
    { Valor* v; new_value (&v, V_STRING, 0, $1);
      Expr* e; new_expr (&e, E_VAL, 0, NULL, NULL, NULL, v);
      $$ = e;
    }
  | TRUE_K
    { Valor* v; new_value (&v, V_TRUE, 1, NULL);
      Expr* e; new_expr (&e, E_VAL, 0, NULL, NULL, NULL, v);
      $$ = e;
    }
  | FALSE_K
    { Valor* v; new_value (&v, V_FALSE, 0, NULL);
      Expr* e; new_expr (&e, E_VAL, 0, NULL, NULL, NULL, v);
      $$ = e;
    }
  | NULL_K
    { Valor* v; new_value (&v, V_NULL, 0, NULL);
      Expr* e; new_expr (&e, E_VAL, 0, NULL, NULL, NULL, v);
      $$ = e;
    }
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
    { List* l; nueva_lista (&l, L_EXPRC);
      agrega (l, $1);
      $$ = l;
    }
  | exprc_list ',' expr
    { agrega ($1, $3); }
  ;

/* Listas (posiblemente vacías) de cases. */
case_list:
  %empty
    { List* l; nueva_lista (&l, L_CASE);
      $$ = l;
    }
  | case_list CASE INTEGER ':' expr_list BREAK ';'
    { Valor* v; new_value (&v, V_INT, $3, NULL);
      Expr* e_; new_expr (&e_, E_VAL, 0, NULL, NULL, NULL, v);
      Construccion* c; new_construct (&c, E_CASE, e_, $5, NULL);
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
  //yyout = fopen (argv[2],"w");
  yyparse ();
  fclose (yyin);
  //fwrite (asa, sizeof(char), strlen(asa), yyout);
  //fclose (yyout);
  return 0;
}
