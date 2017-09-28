#include <stdlib.h>
#include <stdio.h>
#include "asa.h"

/* Crea un nuevo nodo con ELEMENTO. Guarda la referencia en NODO. Regresa 0 si
 * pudo crear el nodo. */
static int
nuevo_nodo (Node** nodo, void* elemento) {
  Node* n = (Node*) malloc (sizeof (Node));
  if (n == NULL)
    return 1;
  n->elem = elemento;
  n->sig = NULL;
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

int
new_feature (Feature** feature, Type_Feature tipo, char* nombre_tipo, char* id,
  Expr* asgnr) {
  Feature* f = (Feature*) malloc (sizeof (Feature));
  if (f == NULL
    || nueva_lista (& f->params,L_FORMAL)
    || nueva_lista (& f->body, L_EXPR))
    return 1;
  f->tipo = tipo;
  f->nombre_tipo = nombre_tipo;
  f->id = id;
  f->asgnr = asgnr;
  *feature = f;
  return 0;
}

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

int
new_construct (Construccion** construccion, Type_Expr tipo, Expr* guardia) {
  Construccion* c = (Construccion*) malloc (sizeof (Construccion));
  if (c == NULL)
    return 1;
  c->guardia = guardia;
  int f,s;
  switch (tipo) {
    case E_IF:
      f = nueva_lista (& c->fst, L_EXPR);
      s = nueva_lista (& c->snd, L_EXPR);
      break;
    case E_WHILE:
      f = nueva_lista (& c->fst, L_EXPR);
      c->snd = NULL;
      s = 0;
      break;
    case E_SWITCH:
      f = nueva_lista (& c->fst, L_CASE);
      s = nueva_lista (& c->snd, L_EXPR);
      break;
    case E_CASE:
      f = nueva_lista (& c->fst, L_EXPR);
      c->snd = NULL;
      s = 0;
      break;
    default:
      return 1;
  }
  if (f || s)
    return 1;
  *construccion = c;
  return 0;
}

int
new_method (Metodo** metodo, char* nombre) {
  Metodo* m = (Metodo*) malloc (sizeof (Metodo));
  if (m == NULL || nueva_lista (& m->args, L_EXPRC))
    return 1;
  m->nombre = nombre;
  *metodo = m;
  return 0;
}

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

int
new_expr (Expr** expresion, Type_Expr tipo, Op_Binario op, Operandos* ops,
  Construccion* cons, Metodo* app, Valor literal) {
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