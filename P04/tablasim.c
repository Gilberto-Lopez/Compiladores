#include <stdlib.h>
#include <assert.h>
#include "tablasim.h"

#define Insert(D,K,V) (DictInsert(D,K,(void*)V))
#define Search(D,K) ((Sym*)DictSearch(D,K))

// Ambientes
struct _env {
  Env* prev;    // Ambiente padre
  Dict tabla;   // Tabla de símbolos
};

// Símbolos
struct _sym {
  char* tipo;   // Tipo de la variable
  char* id;     // Identificador de la variable
};

/* Crea una nueva tabla de símbolos en la referencia ENV con tabla padre P. */
Env*
new_env (Env* p) {
  Env* env = (Env*) malloc (sizeof(Env));
  assert (env != NULL);
  env->prev = p;
  env->tabla = DictCreate ();
  return env;
}

/* Crea un nuevo símbolo correspondiente a la variable ID con tipo TIPO. */
Sym*
new_sym (char* id, char* tipo) {
  Sym* s = (Sym*) malloc (sizeof(Sym));
  assert (s != NULL);
  s->tipo = tipo;
  s->id = id;
  return s;
}

/* Agrega el par KEY,VAL al ambiente E. */
void
install (Env* e, char* key, Sym* val) {
  Insert (e->tabla, key, val);
}

/* Busca la variable con llave KEY en el ambiente E. */
Sym*
context_check (Env* e, char* key) {
  Env* tmp = e;
  for (; tmp != NULL, tmp = tmp->prev) {
    Sym* s = Search (e,key);
    if (s != NULL)
      return s;
  }
  return NULL;
}
