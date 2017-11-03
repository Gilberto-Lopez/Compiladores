# Práctica 4: Tabla de símbolos

## Uso

La práctica funciona sobre la práctica 3, debe reemplazar los archivos en esta práctica con los de la práctica 3.

## Detalles

Para implementar la tabla de símbolos jerárquica nos apoyamos de los diccionarios (hashtables) implementados en C por el profesor [James Aspnes](http://www.cs.yale.edu/homes/aspnes) de la Universidad de Yale, departamento de Ciencias de la Computación.

Código:

* dict.h
* dict.c

Código fuente [aquí](http://www.cs.yale.edu/homes/aspnes/pinewiki/C(2f)HashTables.html?highlight=%28CategoryAlgorithmNotes%29 "C/HashTables").

## Ejecución

### Compilación

Para compilar ejecute el siguiente comando en consola:

```bash
make
```

### Ejecución

Para ejecutar ejecute el siguiente comando en consola:

```bash
./parser codigo.lol salida.txt
```

### Limpieza

Para eliminar los archivos creados ejecute el siguiente comando en consola:

```bash
make clean
```

### Debug

Para generar el ejecutable para debuggeo con GDB ejecute el siguiente comando en consola:

```bash
make debug
```

Para eliminar los archivos creados ejecute el siguiente comando en consola:

```bash
make clean-debug
```
