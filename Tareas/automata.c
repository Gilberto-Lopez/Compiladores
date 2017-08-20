#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define ID 0
#define ENTERO 1
#define REAL 2
#define BLANCO 3

FILE* f;
char* value;

int
is_letter (char c) {
  if ((c >= 65 &&  c <= 90) ||
    (c >= 97 &&  c <= 122))
    return 1;
  return 0;
}

int
is_digit (char c) {
  if (c >= 48 && c <= 57)
    return 1;
  return 0;
}

int
is_blank (char c) {
  if (c == ' ' || c == '\t' || c == '\n')
    return 1;
  return 0;
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
  int t = -1;
  char c;
  int q = 0;
  char* buffer = "";
  c = fgetc (f);
  while (c != EOF) {
    printf("%c\n", c);
    switch (q) {
      case 0:
        if (is_letter (c))
          q = 1;
        else if (is_digit (c))
          q = 2;
        else if (c == '.')
          q = 3;
        else if (c == is_blank (c))
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
  while (1) {
    int clase = next_token ();
    printf ("Clase: %d, Token: %s\n", clase, value);
  }
  fclose(f);

}