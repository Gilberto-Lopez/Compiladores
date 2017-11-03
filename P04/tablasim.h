typedef struct _env Env;
typedef struct _sym Sym;
typedef struct _psym PSym;

// Crea un nuevo ambiente con su tabla de símbolos y un ambiente padre.
Env* new_env (Env*);
// Crea un nuevo símbolo con su id y tipo.
Sym* new_sym (char*, char*);
// Crea un nuevo símbolo pendiente de revisar con un id, alcance y la línea
// donde aparece
PSym* new_psym (char*, Env*, int);

// Agrega un símbolo a un ambiente.
void install (Env*, Sym*);
// Verifica si existe un símbolo con la llave dada en el ambiente.
// Con el flag en 0 solo busca en el ambiente actual.
Sym* context_check (Env*, char*, int);
