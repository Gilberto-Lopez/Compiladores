typedef enum _type_list Type_List;
typedef struct _node Node;
typedef struct _list List;
typedef struct _program Programa;
typedef struct _class Class;
typedef struct _formal Formal;
typedef enum _type_feature Type_Feature;
typedef struct _feature Feature;
typedef enum _type_expr Type_Expr;
typedef enum _op_binario Op_Binario;
typedef struct _operandos Operandos;
typedef struct _construccion Construccion;
typedef struct _metodo Metodo;
typedef enum _type_valor Type_Valor;
typedef struct _valor Valor;
typedef struct _expr Expr;

// Tipos de listas
enum _type_list {
  CLASE,
  FEATURE,
  FORMAL,
  EXPR,
  EXPRC,
  CASE
};

// Nodos para listas
struct _node {
  Node* sig;
  void* elem;
};

// Listas
struct _list {
  Node* cabeza;
  Node* final;
  int elementos;
  Type_List tipo;
};

// Clase sintáctica de programas
struct _program {
  List* clases;
};

// Clase sintáctica de clases
struct _class {
  char* nombre;
  char* super;
  List* features;
};

// Clase sintáctica de parámetros formales
struct _formal {
  char* tipo;
  char* id;
};

// Tipos de features
enum _type_feature {
  DEC,
  DASGN,
  METHOD
};

// Feature
// tipo y id están presentes siempre, asgnr para asignación o expresión de
// retorno, params y body para métodos
struct _feature {
  Type_Feature tipo;
  char* nombre_tipo;
  char* id;
  Expr* asgnr;
  List* params;
  List* body;
};

// Tipos de expresiones
enum _type_expr {
  APP,
  IF,
  WHILE,
  SWITCH,
  INST,
  OPB,
  NEG,
  VAL
};

// Tipos de operadores bianrios
enum _op_binario {
  ASIGN,
  MAS,
  MENOS,
  POR,
  DIV,
  LT,
  LE,
  EQ
};

// Operandos de un operador binario o unario
// En unario, der es NULL
struct _operandos {
  Expr* izq;
  Expr* der;
};

// Construcción del lenguaje (IF, WHILE, SWITCH, CASE)
// guardia es la guardia, fst y snd los cuerpos (snd no NULL para IF ELSE),
// guardia es la variable sobre la que se hace el SWITCH o el valor del CASE,
// fst la lista de CASEs y snd la lista de expresiones del DEFAULT
struct _construccion {
  Expr* guardia;
  List* fst;
  List* snd;
};

// Llamada a método del lenguaje (o instanciacion con args NULL)
struct _metodo {
  char* nombre;
  List* args;
};

// Tipos de valores constantes
enum _type_valor {
  V_TRUE,
  V_FALSE,
  V_INT,
  V_ID,
  V_STRING,
  V_NULL
};

// Valor constante
// val para bool e int, cadena para id y string
struct _valor {
  Type_Valor tipo;
  int val;
  char* cadena;
};

// Clase sintáctica de expresiones
// op y ops para operadores binarios, literal para constante, cons para
// construcción, app para aplicación de método o instanciacion
struct _expr {
  Type_Expr tipo;
  Op_Binario op;
  Operandos* ops;
  Construccion* cons;
  Metodo* app;
  Valor literal;
};

int nueva_lista (List**, Type_List);
int agrega_elemento (List*, void*);
// Macro para evitar el casting a void*
#define agrega(L, E) (agrega_elemento (L, (void*) E))

int new_program (Programa**);
int new_class (Class**, char*, char*); 
int new_formal (Formal**, char*, char*);
int new_feature (Feature**, Type_Feature, char*, char*, Expr*);
int new_operands (Operandos**, Expr*, Expr*);
int new_construct (Construccion**, Type_Expr, Expr*);
int new_method (Metodo**, char*);
int new_value (Valor**, Type_Valor, int, char*);
