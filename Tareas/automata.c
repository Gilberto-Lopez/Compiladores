#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define ID 1
#define ENTERO 2
#define REAL 3
#define BLANCO 4

FILE* f;
char* value;

int
is_letter (char c) {
  return (c >= 65 &&  c <= 90) || (c >= 97 &&  c <= 122);
}

int
is_digit (char c) {
  return c >= 48 && c <= 57;
}

int
is_blank (char c) {
  return c == ' ' || c == '\t' || c == '\n';
}

void
error (char* buffer, char m) {
  printf("Expresión mal formada: %s*%c\n", buffer, m);
  exit (0);
}

char*
append (char* str, char ch) {
  char* nuevo = NULL;
  size_t len = strlen (str);
  nuevo = malloc (len + 2);
  strcpy (nuevo, str);
  nuevo[len] = ch;
  nuevo[len+1] = '\0';
  return nuevo;
}

int
next_token (void) {
  int t;
  char c;
  int q = 0;
  char* buffer = "";
  c = fgetc (f);
  while (c != EOF) {
    printf("%c\n", c);
    t = 0;
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
        t = BLANCO;
        q = 0;
    }
    if (t != BLANCO)
      c = fgetc (f);
  }
  return t;
}

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