%{
  #include <stdio.h>
  extern int yylex ();
  extern int yyparse ();
  extern char* yytext;
  extern FILE* yyin;
  extern int yylineno;
  void yyerror (char*);
%}
%start program
%token CLASS TYPE ID INHERITS SUPER WHILE SWITCH NEW INTEGER STRING BREAK DEFAULT CASE ELSE IF VALUE RETURN NULL_K TRUE_K FALSE_K
%nonassoc '<' LE EQ
%left '+' '-'
%left '*' '/'
%%
program:
  class
  | program class
  ;

class:
  CLASS TYPE '{' feature_list '}'
  | CLASS TYPE INHERITS TYPE '{' feature_list '}'
  ;

/* Listas (posiblemente vacías) de feature. */
feature_list:
  %empty
  | feature_list feature
  ;

feature:
  TYPE ID '(' formal_list ')' '{' expr_list RETURN expr ';' '}'
  | TYPE ID ';'
  | TYPE ID '=' expr ';'
  ;

/* Listas (posiblemente vacías'de) de formal. */
formal_list:
  %empty
  | formal
  | formal_list ',' formal
  ;

/* Listas (posiblemente vacías) de expr. */
expr_list:
  %empty
  | expr_list expr ';'
  ;

formal:
  TYPE ID
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
  ;

/* Listas (posiblemente vacías) de expr con separación de comas. */
exprc_list:
  %empty
  | expr
  | exprc_list ',' expr
  ;

/* Listas (posiblemente vacías) de cases. */
case_list:
  %empty
  | case_list CASE VALUE ':' expr_list BREAK ';'
  ;

/* Claúsula default (opcional) para el switch. */
default_clause:
  %empty
  | DEFAULT ':' expr_list
  ;
%%
/* Imprime mensajes de error por yyparse (). */
void
yyerror (char* s) {
  printf("*** Error sintáctico en línea %d: '%s'\n%s\n", yylineno, yytext, s);
  //fprintf(stderr, "%s\n", s);
}

int
main (int argc, char* argv[]) {
  yyin = fopen (argv[1],"r");
  yyparse ();
  fclose (yyin);
  return 0;
}

