%{
  extern "C" int yylex ();
  extern "C" int yyparse ();
  extern "C" FILE* yyin;
%}
%start program
%token CLASS TYPE ID INHERITS SUPER WHILE SWITCH NEW INTEGER STRING TRUE FALSE BREAK DEFAULT
%left '+' '-'
%left '*' '/'
%left '.'
%%
program:
  class
  | program class
  ;

class:
  CLASS TYPE feature_list
  | CLASS TYPE INHERITS TYPE feature_list
  ;

/* Listas (posiblemente vacías) de feature. */
feature_list:
  | feature_list feature
  ;

feature:
  TYPE ID '(' formal_list ')' '{' expr ';' expr_list '}'
  | TYPE ID ';'
  | TYPE ID '=' expr ';'
  ;

/* Listas de formal. */
formal_list:
  | formal
  | formal_list ',' formal
  ;

/* Listas (posiblemente vacías) de expr. */
expr_list:
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
  | TRUE
  | FALSE
  ;

/* Listas (posiblemente vacías) de expr con separación de comas. */
exprc_list:
  | expr
  | exprc_list ',' expr
  ;

/* Listas (posiblemente vacías) de cases. */
case_list:
  | case_list CASE VALUE ':' expr_list BREAK ';'
  ;

/* Claúsula default (opcional) para el switch. */
default_clause:
  | DEFAULT ':' expr_list
  ;
  
%%

