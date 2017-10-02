#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "asa.h"

/*
 * PRETTYPRINT
 * Generación del árbol de sintaxis abstracta.
 */
/* TEMPLATES */
// Templates para valores.
static char* const TMPL_TT = "bool[tt]"; // 8
static char* const TMPL_FF = "bool[ff]"; // 8
static char* const TMPL_NULL = "NULL"; // 4
static char* const TMPL_INT = "int[%d]"; // 5+1
static char* const TMPL_STRING = "string[%s]"; // 8+1
static char* const TMPL_ID = "id[%s]"; // 4+1
// Templates para construcciones.
static char* const TMPL_IF = "if(%s,%s,%s)"; // 6+1
static char* const TMPL_WHILE = "while(%s,%s)"; // 8+1
static char* const TMPL_SWITCH = "switch(%s,%s,%s)"; // 10+1
static char* const TMPL_CASE = "case(%s,%s)"; // 7+1
// Templates para operadores binarios y negación
static char* const TMPL_ASGN = "asgn(%s,%s)"; // 7+1
static char* const TMPL_SUMA = "suma(%s,%s)"; // 7+1
static char* const TMPL_PROD = "prod(%s,%s)"; // 7+1
static char* const TMPL_SUB = "sub(%s,%s)"; // 6+1
static char* const TMPL_DIV = "div(%s,%s)"; // 6+1
static char* const TMPL_LT = "lt(%s,%s)"; // 5+1
static char* const TMPL_LE = "le(%s,%s)"; // 5+1
static char* const TMPL_EQ = "eq(%s,%s)"; // 5+1
static char* const TMPL_NEG = "neg(%s)"; // 5+1
// Templates para métodos/nuevas instancias
static char* const TMPL_CALL_E = "%s.m[%s](%s)"; // 6+1
static char* const TMPL_CALL_ES = "%s.SUPER.m[%s](%s)"; // 12+1
static char* const TMPL_CALL = "m[%s](%s)"; // 5+1
static char* const TMPL_NEW = "obj[%s]"; // 5+1
// Templates para clases
static char* const TMPL_CLASS = "class %s:\n%s"; // 8+1
static char* const TMPL_CLASS_S = "class %s(%s):\n%s"; // 10+1
// Templates para features
static char* const TMPL_METHOD = "%s(%s):%s{\n%s\nreturn %s\n}\n"; // 16+1
static char* const TMPL_DEC = "%s:%s\n"; // 2+1
static char* const TMPL_DASGN = "%s<-%s:%s\n"; // 4+1
/* PROTOTIPOS */
// Prototipos de los pretty printers auxiliares.
static size_t print_value (char**, Valor*);
static size_t print_construct (char**, Construccion*);
static size_t print_binary (char**, Op_Binario, Operandos*);
static size_t print_expr (char**, Expr*);
static size_t print_method (char**, Metodo*);
static size_t print_class (char**, Class*);
static size_t print_feature (char**, Feature*);
static size_t print_formal (char**, Formal*);
static size_t print_list (char**, List*);

/* Crea un nuevo nodo con ELEMENTO. Guarda la referencia en NODO. Regresa 0 si
 * pudo crear el nodo. */
static int
nuevo_nodo (Node** nodo, void* elemento) {
  Node* n = (Node*) malloc (sizeof (Node));
  if (n == NULL)
    return 1;
  n->elem = elemento;
  n->sig = NULL;
  n->rep = NULL;
  n->l_rep = 0;
  *nodo = n;
  return 0;
}

/* Crea una nueva lista que almacena elementos de tipo TIPO y guarda la
 * referencia en LISTA. Regresa 0 si pudo crear la lista. */
int
nueva_lista (List** lista, Type_List tipo) {
  List* l = (List*) malloc (sizeof (List));
  if (l == NULL)
    return 1;
  l->cabeza = l->final = NULL;
  l->elementos = 0;
  l->tipo = tipo;
  *lista = l;
  return 0;
}

/* Agrega el nuevo elemento en ELEMENTO a la lista en LISTA. Regresa 0 si la
 * operación fue exitosa. */
int
agrega_elemento (List* lista, void* elemento) {
  Node* nuevo;
  if (nuevo_nodo (&nuevo, elemento))
    return 1;
  if (lista->elementos == 0) {
    lista->cabeza = lista->final = nuevo;
  } else {
    lista->final->sig = nuevo;
    lista->final = nuevo;
  }
  lista->elementos++;
  return 0;
}

/* Crea un nuevo programa en PROGRAMA con una lista vacía de clases. Regresa
 * 0 si la operación fue exitosa. */
int
new_program (Programa** programa) {
  Programa* p = (Programa*) malloc (sizeof (Programa));
  if (p == NULL || nueva_lista (& p->clases, L_CLASE))
    return 1;
  *programa = p;
  return 0;
}

/* Crea una nueva clase en CLASE, el nombre es NOMBRE, puede heredar a la clase
 * SUPER, FEATURES es la lista de miembros. Regresa 0 si la operación fue
 * exitosa. */
int
new_class (Class** clase, char* nombre, char* super, List* features) {
  Class* c = (Class*) malloc (sizeof (Class));
  if (c == NULL)
    return 1;
  c->nombre = nombre;
  c->super = super;
  c->features = features;
  *clase = c;
  return 0;
}

/* Crea un nuevo parámetro formal en FORMAL con firma TIPO ID. Regresa 0 si la
 * operación fue exitosa. */
int
new_formal (Formal** formal, char* tipo, char* id) {
  Formal* f = (Formal*) malloc (sizeof (Formal));
  if (f == NULL)
    return 1;
  f->tipo = tipo;
  f->id = id;
  *formal = f;
  return 0;
}

/* Crea un nuevo miembro en FEATURE, puede ser la declaración de una variable
 * "NOMBRE_TIPO ID;", declaración y asignación "NOMBRE_TIPO ID = ASGNR;" o un
 * método "NOMBRE_TIPO ID (PARAMS) { BODY return ASGNR; }". */
int
new_feature (Feature** feature, Type_Feature tipo, char* nombre_tipo, char* id,
  Expr* asgnr, List* params, List* body) {
  Feature* f = (Feature*) malloc (sizeof (Feature));
  if (f == NULL)
    return 1;
  f->tipo = tipo;
  f->nombre_tipo = nombre_tipo;
  f->id = id;
  f->asgnr = asgnr;
  f->params = params;
  f->body = body;
  *feature = f;
  return 0;
}

/* Crea la representación de los oeprandos de un operados binario/unario en
 * OPERANDOS, donde IZQ es el izquierdo (o único para unario) y DER el derecho
 * (o NULL para unario). */
int
new_operands (Operandos** operandos, Expr* izq, Expr* der) {
  Operandos* o = (Operandos*) malloc (sizeof (Operandos));
  if (o == NULL)
    return 1;
  o->izq = izq;
  o->der = der;
  *operandos = o;
  return 0;
}

/* Genera una nueva construcción del lenguaje en CONSTRUCCION. La construcción
 * puede ser un IF "if (GUARDIA) {FST} [else {SND}];",  un WHILE
 * "while (GAURDIA) {FST};", un SWITCH "switch (GAURDIA) {FST default: SND};"
 * o un CASE "case GAURDIA: FST break;". */
int
new_construct (Construccion** construccion, Type_Expr tipo, Expr* guardia,
  List* fst, List* snd) {
  Construccion* c = (Construccion*) malloc (sizeof (Construccion));
  if (c == NULL)
    return 1;
  c->tipo = tipo;
  c->guardia = guardia;
  c->fst = fst;
  c->snd = snd;
  *construccion = c;
  return 0;
}

/* Crea un struct que representa una llamada a método o una instanciación en
 * METODO. SUPER es el flag que determina si hay una llamada ".super", MSG es el
 * una expresión que representará un objeto, ARGS es la lista de argumentos para
 * el método, NOMBRE el nombre de este. Para instanciación solo importa NOMBRE
 * pues la sintaxis es "new NOMBRE;". */
int
new_method (Metodo** metodo, char* nombre, int inst, int super, Expr* msg,
  List* args) {
  Metodo* m = (Metodo*) malloc (sizeof (Metodo));
  if (m == NULL)
    return 1;
  m->nombre = nombre;
  m->inst = inst;
  m->super = super;
  m->msg = msg;
  m->args = args;
  *metodo = m;
  return 0;
}

/* Crea un nuevo valor en VALOR, puede ser un ENTERO dado por VAL (o un valor
 * booleano), un STRING CADENA o NULL. */
int
new_value (Valor** valor, Type_Valor tipo, int val, char* cadena) {
  Valor* v = (Valor*) malloc (sizeof (Valor));
  if (v == NULL)
    return 1;
  v->tipo = tipo;
  v->val = val;
  v->cadena = cadena;
  *valor = v;
  return 0;
}

/* Crea una nueva expresión en EXPRESION que puede ser un OPERADOR BINARIO/
 * UNARIO, con operandos OPS, una construcción del lenguaje dada por CONS,
 * llamada a método/instancación APP o una constante LITERAL. */
int
new_expr (Expr** expresion, Type_Expr tipo, Op_Binario op, Operandos* ops,
  Construccion* cons, Metodo* app, Valor* literal) {
  Expr* e = (Expr*) malloc (sizeof (Expr));
  if (e == NULL)
    return 1;
  e->tipo = tipo;
  e->op = op;
  e->ops = ops;
  e->cons = cons;
  e->app = app;
  e->literal = literal;
  *expresion = e;
  return 0;
}

/* Genera el árbol de sintaxis abstracta del programa PROGRAMA generado por
 * yyparse() y guarda la representación en BUFFER. Regresa la longitud de la
 * representación. */
size_t
genera_arbol (char** buffer, Programa* programa) {
  return print_list(buffer, programa->clases);
}

/* Pretty printer para valores. Genera la representación de V y la guarda en
 * BUFFER. Regresa la longitud de la cadena guardada en BUFFER. */
static size_t
print_value (char** buffer, Valor* v) {
  size_t l;
  char* s;
  switch (v->tipo) {
    case V_TRUE:
      *buffer = TMPL_TT;
      l = 8;
      break;
    case V_FALSE:
      *buffer = TMPL_FF;
      l = 8;
      break;
    case V_INT:
      l = 5 + (v->val > 1 ? (size_t) ceil(log10(v->val)) : 1);
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_INT, v->val);
      *buffer = s;
      break;
    case V_ID:
      l = 4 + strlen(v->cadena);
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_ID, v->cadena);
      *buffer = s;
      break;
    case V_STRING:
      l = 8 + strlen(v->cadena);
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_STRING, v->cadena);
      *buffer = s;
      break;
    case V_NULL:
      *buffer = TMPL_NULL;
      l = 4;
  }
  return l;
}

/* Pretty printer para construcciones. Genera la representación de la
 * construcción C y la guarda en BUFFER. Regresa la longitud de la cadena
 * guardada en BUFFER. */
static size_t
print_construct (char** buffer, Construccion* c) {
  char* g;
  char* i;
  char* d;
  char* s;
  size_t l;
  switch (c->tipo) {
    case E_IF:
      l = 6 + print_expr(&g, c->guardia) + print_list(&i, c->fst);
      if (c->snd != NULL)
        l += print_list(&d, c->snd);
      else
        l++;
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_IF, g, i,
        (c->snd != NULL)? d : "-");
      *buffer = s;
      break;
    case E_WHILE:
      l = 8 + print_expr(&g, c->guardia) + print_list(&i, c->fst);
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_WHILE, g, i);
      *buffer = s;
      break;
    case E_SWITCH:
      l = 10 + print_expr(&g, c->guardia);
      if (c->fst->elementos > 0) {
        l += print_list(&i, c->fst);
      } else {
        l++;
        i = "-";
      }
      if (c->snd != NULL) {
        l += print_list(&d, c->snd);
      } else {
        l++;
        d = "-";
      }
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_SWITCH, g, i, d);
      *buffer = s;
      break;
    case E_CASE:
      l = 7 + print_expr(&g, c->guardia) + print_list(&i, c->fst);
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_CASE, g, i);
      *buffer = s;
      break;
    default:
      // Este caso no ocurre
      l = 0;
  }
  return l;
}

/* Pretty printer para operadores binarios. Genera la representación del
 * operador B con operandos O y la guarda en BUFFER. Regresa la longitud de la
 * cadena guardada en BUFFER. */
static size_t
print_binary (char** buffer, Op_Binario b, Operandos* o) {
  char* i;
  char* d;
  char* s;
  size_t l = print_expr (&i, o->izq) + print_expr (&d, o->der);
  char* tmpl;
  switch (b) {
    case B_ASIGN:
      l += 7;
      tmpl = TMPL_ASGN;
      break;
    case B_MAS:
      l += 7;
      tmpl = TMPL_SUMA;
      break;
    case B_MENOS:
      l += 6;
      tmpl = TMPL_SUB;
      break;
    case B_POR:
      l += 7;
      tmpl = TMPL_PROD;
      break;
    case B_DIV:
      l += 6;
      tmpl = TMPL_DIV;
      break;
    case B_LT:
      l += 5;
      tmpl = TMPL_LT;
      break;
    case B_LE:
      l += 5;
      tmpl = TMPL_LE;
      break;
    case B_EQ:
      l += 5;
      tmpl = TMPL_EQ;
  }
  s = (char*) malloc(l*sizeof(char)+1);
  sprintf(s, tmpl, i, d);
  *buffer = s;
  return l;
}

/* Pretty printer para expresiones. Genera la representación de la expresión E
 * y la guarda en BUFFER. Regresa la longitud de la cadena guardada en
 * BUFFER. */
static size_t
print_expr (char** buffer, Expr* e) {
  char* o;
  size_t l;
  char* s;
  switch (e->tipo) {
    case E_APP:
    case E_INST:
      return print_method(buffer, e->app);
    case E_IF:
    case E_WHILE:
    case E_SWITCH:
    case E_CASE:
      return print_construct(buffer, e->cons);
    case E_OPB:
      return print_binary(buffer, e->op, e->ops);
    case E_NEG:
      l = 5 + print_expr(&o, e->ops->izq);
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf (s, TMPL_NEG, o);
      *buffer = s;
      return l;
    case E_VAL:
      return print_value(buffer, e->literal);
  }
}

/* Pretty printer para métodos. Genera la representación de la aplicación del
 * método M o una instanciación y la guarda en BUFFER. Regresa la longitud de
 * la cadena guardada en BUFFER. */
static size_t
print_method (char** buffer, Metodo* m) {
  size_t l = strlen(m->nombre);
  char* a;
  char* e;
  char* s;
  if (m->inst) {
    l += 5;
    s = (char*) malloc(l*sizeof(char)+1);
    sprintf(s, TMPL_NEW, m->nombre);
  } else {
    if (m->args == NULL) {
      a = "-";
      l++;
    } else {
      l += print_list (&a, m->args);
    }
    if (m->msg == NULL) {
      l += 5;
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_CALL, m->nombre, a);
    } else {
      l += print_expr(&e, m->msg);
      l += (m->super)? 12: 6;
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, (m->super)? TMPL_CALL_ES: TMPL_CALL_E, e, m->nombre, a);
    }
  }
  *buffer = s;
  return l;
}

/* Pretty printer para clases. Genera la representación de la clase C y la
 * guarda en BUFFER. Regresa la longitud de la cadena guardada en BUFFER. */
static size_t
print_class (char** buffer, Class* c) {
  char* s;
  char* f;
  size_t l = strlen(c->nombre) + print_list(&f, c->features);
  if (c->super == NULL) {
    l += 8;
    s = (char*) malloc(l*sizeof(char)+1);
    sprintf(s, TMPL_CLASS, c->nombre, f);
  } else {
    l += 10 + strlen(c->super) ;
    s = (char*) malloc(l*sizeof(char)+1);
    sprintf(s, TMPL_CLASS_S, c->nombre, c->super, f);
  }
  *buffer = s;
  return l;
}

/* Pretty printer para miembros. Genera la representación del miembro F y la
 * guarda en BUFFER. Regresa la longitud de la cadena guardada en BUFFER. */
static size_t
print_feature (char** buffer, Feature* f) {
  size_t l = strlen(f->nombre_tipo) + strlen(f->id);
  char* e;
  char* body;
  char* params;
  char* s;
  switch (f->tipo) {
    case F_DEC:
      l += 2;
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_DEC, f->id, f->nombre_tipo);
      break;
    case F_DASGN:
      l += 4 + print_expr(&e, f->asgnr);
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_DASGN, f->id, e, f->nombre_tipo);
      break;
    case F_METHOD:
      l += 16 + print_expr(&e, f->asgnr) + print_list(&body, f->body)
      + print_list(&params, f->params);
      s = (char*) malloc(l*sizeof(char)+1);
      sprintf(s, TMPL_METHOD, f->id, params, f->nombre_tipo, body, e);
  }
  *buffer = s;
  return l;
}

/* Pretty printer para parámetros formales. Genera la representación del
 * parámetro F y la guarda en BUFFER. Regresa la longitud de la cadena guardada
 * en BUFFER. */
static size_t
print_formal (char** buffer, Formal* f) {
  size_t l = 1 + strlen(f->tipo) + strlen(f->id);
  *buffer = (char*) malloc(l*sizeof(char)+1);
  sprintf(*buffer, "%s:%s", f->id, f->tipo);
  return l;
}

/* Pretty printer para listas. Genera la representación de la lista L y la
 * guarda en BUFFER. Regresa la longitud de la cadena guardada en BUFFER. */
static size_t
print_list (char** buffer, List* l) {
  if (l->elementos == 0) {
    *buffer = (char*) malloc(2*sizeof(char));
    (*buffer)[0] = '-';
    (*buffer)[1] = '\0';
    return 2;
  }
  size_t len = 0;
  char* ts;
  char* s;
  Node* tmp = l->cabeza;
  while (tmp != NULL) {
    switch (l->tipo) {
      case L_CLASE:
        tmp->l_rep = print_class(& tmp->rep, (Class*) tmp->elem);
        break;
      case L_FEATURE:
        tmp->l_rep = print_feature(& tmp->rep, (Feature*) tmp->elem);
        break;
      case L_FORMAL:
        tmp->l_rep = print_formal(& tmp->rep, (Formal*) tmp->elem);
        break;
      case L_EXPR:
      case L_EXPRC:
        tmp->l_rep = print_expr(& tmp->rep, (Expr*) tmp->elem);
        break;
      case L_CASE:
        tmp->l_rep = print_construct(& tmp->rep, (Construccion*) tmp->elem);
    }
    len += tmp->l_rep;
    tmp = tmp->sig;
  }
  if (l->tipo == L_FORMAL || l->tipo == L_EXPRC)
    ts = ",";
  else if (l->tipo == L_FEATURE || l->tipo == L_EXPR || l->tipo == L_CASE)
    ts = "\n";
  else
    ts = "\n\n";
  len += (l->elementos -1)*strlen(ts);
  s = (char*) malloc(len*sizeof(char)+1);
  s[0] = '\0';
  tmp = l->cabeza;
  while(tmp->sig != NULL) {
    strcat(s, tmp->rep);
    strcat(s, ts);
    tmp = tmp->sig;
  }
  strcat(s, tmp->rep);
  *buffer = s;
  return len;
}
