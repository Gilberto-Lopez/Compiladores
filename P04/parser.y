%{
  #include <stdio.h>
  #include <stdlib.h>
  
  // Lex
  extern int yylex ();
  extern char* yytext;
  extern FILE* yyin;
  extern FILE* yyout;
  extern int yylineno;

  void yyerror (char*);
  // El árbol
  char* asa;
  // Flag para listas evitar errores de la forma 'metodo(, ...,<>);'
  int empty;
  // Flag para errores
  int errores = 0;
  
  #include "asa.h"
  Programa* programa;

  /* P04 */
  #include "tablasim.h"
  // Tabla de símbolos jerárquica: Stack de ambientes.
  Env* top = NULL;
  Env* saved = NULL;
  // Macro para agregar un nuevo símbolo con id I y tipo T al ambiente top
  #define INSTALL(I,T) (install(top,new_sym(I,T)))
  // Macros para context_check, buscan en el ambiente top el símbolo ID:
  // C -> Current: solo busca en top
  // R -> Recursive: busca en top y en los ambientes padre
  #define CONTEXT_CHECK_C(ID) (context_check(top,ID,0))
  #define CONTEXT_CHECK_R(ID) (context_check(top,ID,1))
  void sim_error (char*, int);

  // Lista de símbolos pendientes por revisar
  List* pendientes;
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
      programa = p;
      $$ = p;
    }
  | program class
    { agrega ($1->clases, $2); }
  ;

class:
  CLASS TYPE '{'      { /* P04 */
                        // Tabla de símbolos para la clase
                        top = new_env (NULL);
                        // Agregamos el identificador this
                        INSTALL ("this",$2);
                      }
  feature_list '}'
    { Class* c; new_class (&c, $2, NULL, $5);
      $$ = c;
    }
  | CLASS TYPE INHERITS TYPE '{'      { /* P04 */
                                        top = new_env (NULL);
                                        INSTALL ("this",$2);
                                      }
    feature_list '}'
    { Class* c; new_class (&c, $2, $4, $7);
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
  TYPE ID '('       { /* P04 */
                      // Si el símbolo ya existe en el ambiente actual mandamos
                      // error, caso contrario lo agregamos
                      // El tipo es el tipo de regreso del método
                      if (CONTEXT_CHECK_C ($2) != NULL)
                        sim_error ($2,1);
                      else
                        INSTALL ($2,$1);
                      // Creamos una nueva tabla de símbolos para este bloque
                      saved = top;
                      top = new_env (top);
                    }
  formal_list ')' '{' expr_list RETURN expr ';' '}'
    { Feature* f; new_feature (&f, F_METHOD, $1, $2, $10, $5, $8);
      $$ = f;
      /* P04 */
      // Regresamos a la tabla de símbolos anterior
      top = saved;
    }
  | TYPE ID ';'
    { Feature* f; new_feature (&f, F_DEC, $1, $2, NULL, NULL, NULL);
      $$ = f;
      /* P04 */
      if (CONTEXT_CHECK_C ($2) != NULL)
        sim_error ($2,1);
      else
        INSTALL ($2,$1);
    }
  | TYPE ID       { /* P04 */
                    if (CONTEXT_CHECK_C ($2) != NULL)
                      sim_error ($2,1);
                    else
                      INSTALL ($2,$1);
                  }
    '=' expr ';'
    { Feature* f; new_feature (&f, F_DASGN, $1, $2, $5, NULL, NULL);
      $$ = f;
    }
  ;

/* Listas (posiblemente vacías de) de formal. */
formal_list:
  %empty
    { empty = 1;
      $$ = NULL;
    }
  | formal
    { empty = 0;
      List* l; nueva_lista (&l, L_FORMAL);
      agrega (l, $1);
      $$ = l;
    }
  | formal_list ',' formal
    { if (!empty) {
        agrega ($1, $3);
      } else {
        yyerror ("Parámetro vacío.");
      }
    }
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
      /* P04 */
      if (CONTEXT_CHECK_C ($2) != NULL)
        sim_error ($2,1);
      else
        INSTALL ($2,$1);
    }
  ;

expr:
  ID      { /* P04 */
            // Si el símbolo no existe (hasta este punto) lo guardamos como
            // pendiente para revisarlo más tarde.
            if (CONTEXT_CHECK_R ($1) == NULL)
              agrega (pendientes, new_psym ($1, top, yylineno));
          }
  '=' expr
    { Valor* v; new_value (&v, V_ID, 0, $1);
      Expr* e_; new_expr (&e_, E_VAL, 0, NULL, NULL, NULL, v);
      Operandos* o; new_operands (&o, e_, $4);
      Expr* e; new_expr (&e, E_OPB, B_ASIGN, o, NULL, NULL, NULL);
      $$ = e;
    }
  | expr '.' ID       { /* P04 */
                        if (CONTEXT_CHECK_R ($3) == NULL)
                          agrega (pendientes, new_psym ($3, top, yylineno));
                      }
    '(' exprc_list ')'
    { Metodo* m; new_method (&m, $3, 0, 0, $1, $6);
      Expr* e; new_expr (&e, E_APP, 0, NULL, NULL, m, NULL);
      $$ = e;
    }
  | expr '.' SUPER '.' ID       { /* P04 */
                                  if (CONTEXT_CHECK_R ($5) == NULL)
                                    agrega (pendientes, new_psym ($5, top, yylineno));
                                }
    '(' exprc_list ')'
    { Metodo* m; new_method (&m, $5, 0, 1, $1, $8);
      Expr* e; new_expr (&e, E_APP, 0, NULL, NULL, m, NULL);
      $$ = e;
    }
  | ID      { /* P04 */
              if (CONTEXT_CHECK_R ($1) == NULL)
                agrega (pendientes, new_psym ($1, top, yylineno));
            }
    '(' exprc_list ')'
    { Metodo* m; new_method (&m, $1, 0, 0, NULL, $4);
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
  | SWITCH '(' ID       { /* P04 */
                          if (CONTEXT_CHECK_R ($3) == NULL)
                            agrega (pendientes, new_psym ($3, top, yylineno));
                        }
    ')' '{' case_list default_clause '}'
    { Valor* v; new_value (&v, V_ID, 0, $3);
      Expr* e_; new_expr (&e_, E_VAL, 0, NULL, NULL, NULL, v);
      Construccion* c; new_construct (&c, E_SWITCH, e_, $7, $8);
      Expr* e; new_expr (&e, E_SWITCH, 0, NULL, c, NULL, NULL);
      $$ = e;
    }
  | NEW TYPE
    { Metodo* m; new_method (&m, $2, 1, 0, NULL, NULL);
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
    { /* P04 */
      if (CONTEXT_CHECK_R ($1) == NULL)
        agrega (pendientes, new_psym ($1, top, yylineno));
      Valor* v; new_value (&v, V_ID, 0, $1);
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
    { empty = 1;
      $$ = NULL;
    }
  | expr
    { empty = 0;
      List* l; nueva_lista (&l, L_EXPRC);
      agrega (l, $1);
      $$ = l;
    }
  | exprc_list ',' expr
    { if (!empty) {
        agrega ($1, $3);
      } else {
        yyerror ("Argumento vacío.");
      }
    }
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
  errores++;
  fprintf(stderr, "*** Error sintáctico en línea %d: '%s'\n\t%s\n",
    yylineno, yytext,s);
}

/* Imprime un mensaje de error por la tabla de símbolos. */
void
sim_error (char* s, int f) {
  errores++;
  fprintf(stderr, "*** Error en línea %d: Variable '%s' %s declarada\n",
    yylineno, s, f?"ya":"no");
}

/* Revisamos los símbolos que hayan quedado pendientes de revisar en la lista
 * pendientes. */
void
pendientes_check (void) {
  Node* tmp;
  for (tmp = pendientes->cabeza; tmp != NULL; tmp = tmp->sig) {
    PSym* ps = (PSym*) tmp->elem;
    char* id = get_id (ps);
    int l = get_line (ps);
    Env* env = get_env (ps);
    if (context_check (env, id, 1) == NULL) {
      yylineno = l;
      sim_error (id, 0);
    }
  }
}

int
main (int argc, char* argv[]) {
  if (argc < 3) {
    printf("Uso:\n./<parser> <codigo LOOLI> <archivo de salida>\n");
    return 1;
  }
  yyin = fopen (argv[1],"r");
  // Inicializamos la lista de símbolos pendientes
  nueva_lista (&pendientes, 0);
  yyparse ();
  fclose (yyin);
  // Revisamos los símbolos que quedaron pendientes
  pendientes_check ();
  if (errores) {
    printf("El programa contiene %d errores.\n", errores);
  } else {
    size_t len = genera_arbol(&asa, programa);
    yyout = fopen (argv[2],"w");
    fwrite (asa, sizeof(char), len, yyout);
    fclose (yyout);
  }
  return 0;
}
