#include "dict.h"

typedef struct _env Env;
typedef struct _sym Sym;

// Crea un nuevo ambiente con su tabla de símbolos y un ambiente padre.
Env* new_env (Env*);
// Crea un nuevo símbolo (variable) con su id y tipo.
Sym* new_sym (char*, char*);

// Agrega un símbolo (par llave, valor) a un ambiente.
void install (Env*, char*, Sym*);
// Verifica si existe un símbolo con la llave dada en el ambiente.
// Con el flag en 0 solo busca en el ambiente actual.
Sym* context_check (Env*, char*, int);
