#include <stdlib.h>
#include <assert.h>
#include "dict.h"
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
  Env* env;     // Alcance de la variable
};

struct _psym {
  char* id;     // Identificador de la variable
  Env* env;     // Alcance de la variable
  int l;        // Línea donde aparece la variable
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

/* Crea un nuevo símbolo pendiente de revisar con identificador ID, alcance ENV
 * y aparece en la línea L del código. */
PSym*
new_psym (char* id, Env* env, int l) {
  PSym* s = (PSym*) malloc (sizeof(PSym));
  assert (s != NULL);
  s->id = id;
  s->env = env;
  s->l = l;
  return s;
}

/* Agrega VAL al ambiente E. La llave de VAL es su id. */
void
install (Env* e, Sym* val) {
  Insert (e->tabla, val->id, val);
  val->env = e;
}

/* Busca la variable con llave KEY en el ambiente E. Si R es 0 no busca en los
 * ambientes padres. */
Sym*
context_check (Env* e, char* key, int r) {
  Env* tmp;
  if (!r)
    return Search (e->tabla,key);
  for (tmp = e; tmp != NULL; tmp = tmp->prev) {
    Sym* s = Search (tmp->tabla,key);
    if (s != NULL)
      return s;
  }
  return NULL;
}
