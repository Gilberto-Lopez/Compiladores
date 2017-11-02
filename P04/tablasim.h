#include "dict.h"

typedef struct _env Env;
typedef struct _sym Sym;

// Crea un nuevo ambiente con su tabla de símbolos y un ambiente padre.
Env* new_env (Env*);
// Crea un nuevo símbolo (variable).
Sym* new_sym (char*, char*);

// Agrega un símbolo (par llave, valor) a un ambiente
void install (Env*, char*, Sym*);
// Verifica si existe un símbolo con la llave dada en el ambiente.
Sym* context_check (Env*, char*);
