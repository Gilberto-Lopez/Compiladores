#include <string.h>
#include <stdio.h>
#include <stdlib.h>

// Constantes de clase de tokens.
#define ID 1
#define ENTERO 2
#define REAL 3

/* Archivo donde se leen los tokens. */
FILE* f;
/* Último token. */
char* value;

/* Determina si C es una letra [A-Za-z]. */
int
is_letter (char c) {
  return (c >= 65 &&  c <= 90) || (c >= 97 &&  c <= 122);
}

/* Determina si C es un dígito [0-9]. */
int
is_digit (char c) {
  return c >= 48 && c <= 57;
}

/* Determina si C es un caracter en blanco [' '\n\t]. */
int
is_blank (char c) {
  return c == ' ' || c == '\t' || c == '\n';
}

/* Imprime un mensaje de error donde BUFFER es el token que se
 * estaba leyendo y M es caracter que rompe la expresión. 
 * Termina la ejecución del programa. */
void
error (char* buffer, char m) {
  printf("Expresión mal formada: %s*%c\n", buffer, m);
  exit (0);
}

/* Concatena el caracter CH al final de la cadena STR y regresa
 * el apuntador. */
char*
append (char* str, char ch) {
  char* nuevo;
  size_t len = strlen (str);
  nuevo = malloc (len + 2);
  if (nuevo == NULL)
    exit (0);
  strcpy (nuevo, str);
  nuevo[len] = ch;
  nuevo[len+1] = '\0';
  return nuevo;
}

/* Obtiene el siguiente token, regresa la clase del token y lo
 * guarda en VALUE. */
int
next_token (void) {
  char c;
  int q = 0;
  char* buffer = "";
  c = fgetc (f);
  while (c != EOF) {
    switch (q) {
      case 0:
        if (is_letter (c))
          q = 1;
        else if (is_digit (c))
          q = 2;
        else if (c == '.')
          q = 3;
        else if (is_blank (c))
          q = 5;
        else
          error (buffer, c);
        if (q != 5)
          buffer = append (buffer, c);
        break;
      case 1:
        if (is_digit (c) || is_letter (c))
          q = 1;
        else if (is_blank (c)) {
          value = buffer;
          return ID;
        } else
          error (buffer, c);
        buffer = append (buffer, c);
        break;
      case 2:
        if (is_digit (c))
          q = 2;
        else if (c == '.')
          q = 3;
        else if (is_blank (c)) {
          value = buffer;
          return ENTERO;
        } else
          error (buffer, c);
        buffer = append (buffer, c);
        break;
      case 3:
        if (is_digit (c))
          q = 4;
        else
          error (buffer, c);
        buffer = append (buffer, c);
        break;
      case 4:
        if (is_digit (c))
          q = 4;         
        else if (is_blank (c)) {
          value = buffer;
          return REAL;
        } else
          error (buffer, c);
        buffer = append (buffer, c);
        break;
      case 5:
        while (is_blank (c))
          c = fgetc (f);
        q = 0;
    }
    if (q != 0)
      c = fgetc (f);
  }
  return 0;
}

// Punto de entrada del programa.
void
main (void) {
  f = fopen ("ejemplo.txt", "r");
  if (f == NULL) {
    printf("No es posible leer ejemplo.txt\n");
    exit (0);
  }
  int clase = next_token ();
  while (clase) {
    printf ("Clase: %d, Token: '%s'\n", clase, value);
    clase = next_token ();
  }
  fclose(f);
}
