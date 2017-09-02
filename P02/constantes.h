#include <stdio.h>
#include <string.h>

#define ENTERO 1
#define IDENTIFICADOR 2
#define CADENA 3
#define KEYWORD 4
#define BLANCO 5
#define COMENTARIO 6
#define OPERADOR 7

char* error = "\tError lexico, no se reconoce el token.\n";
int len = 40;
