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
  L_CLASE,
  L_FEATURE,
  L_FORMAL,
  L_EXPR,
  L_EXPRC,
  L_CASE
};

// Nodos para listas
struct _node {
  Node* sig;
  void* elem;
  char* rep;
  size_t l_rep;
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
  F_DEC,
  F_DASGN,
  F_METHOD
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
  E_APP,
  E_IF,
  E_WHILE,
  E_SWITCH,
  E_INST,
  E_OPB,
  E_NEG,
  E_VAL,
  E_CASE
};

// Tipos de operadores bianrios
enum _op_binario {
  B_ASIGN,
  B_MAS,
  B_MENOS,
  B_POR,
  B_DIV,
  B_LT,
  B_LE,
  B_EQ
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
  Type_Expr tipo;
  List* fst;
  List* snd;
};

// Llamada a método del lenguaje (o instanciacion con inst 1)
struct _metodo {
  char* nombre;
  int inst;
  int super;
  Expr* msg;
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
  Valor* literal;
};

int nueva_lista (List**, Type_List);
int agrega_elemento (List*, void*);
// Macro para evitar el casting a void*
#define agrega(L, E) (agrega_elemento (L, (void*) E))

int new_program (Programa**);
int new_class (Class**, char*, char*, List*); 
int new_formal (Formal**, char*, char*);
int new_feature (Feature**, Type_Feature, char*, char*, Expr*, List*, List*);
int new_operands (Operandos**, Expr*, Expr*);
int new_construct (Construccion**, Type_Expr, Expr*, List*, List*);
int new_method (Metodo**, char*, int, int, Expr*, List*);
int new_value (Valor**, Type_Valor, int, char*);
int new_expr (Expr**, Type_Expr, Op_Binario, Operandos*, Construccion*,
  Metodo*, Valor*);

void genera_arbol (char**, Programa*);
