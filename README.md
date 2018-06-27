# Compiler-LyLP
Compiler
Para ejecutar el compilador se deben seguir los siguientes pasos:
1.Ir al directorio Compiler-LyLP
2.Ejecutar el comando make all.
3.Luego si se quiere compilar un archivo para obtener el código en c:
        ./compiler < filename.lylp > filename.c
4.Por último compilar el resultado obtenido con gcc:
    gcc filename.c -o filename
5.Y para ejecutarlo: ./filename

Para construir de manera más rápida los archivos ejecutables proveídos como test (siendo 5 con sin errores de compilación y dos con).
1.Repetir los pasos 1 y 2 explicados anteriormente.
2.Ejecutar make test<i> (donde <i> es el número del test que se quiere compilar: 1, 2, 3, 4, 5, 6 y 7.)
3.Ejecutar el archivo compilado: ./test<i>
    
Para eliminar los ejecutables de los test  y los archivos con los que se construyó el ejecutable del compilador (y.tab.c, y.tab.h, etc.). 
Ejecutar make clean.

Ante cualquier duda, problema o dificultad se puede contactar a cualquier integrante del grupo a través del correo institucional del ITBA.
