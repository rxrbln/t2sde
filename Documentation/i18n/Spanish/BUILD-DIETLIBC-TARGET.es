				Dietlibc-target
                                ~~~~~~~~~~~~~~~

Índice
~~~~~~

1) Prefacio
2) ¿Qué es dietlibc?
3) Preparación para la compilación
4) Compilación

1) Prefacio
~~~~~~~~~~~

Hola, éste es un pequeño COMO compilar el target dietlibc. Espero que llegue el
día en que ya no haga falta por que el target sea algo evidente. Actualmente es
más bien un boceto de howto, pero ¿a quién le importa? es mejor que nada, 
¿cierto?

Algunas cosas muy internas se encuentran en Documentation/Developers/TODO. Hay 
también problemas actuales y bugs, así que aunque no seas un desarrollador
probáblemente quieras leerlo.

El target es actuálmente experimental, como el arbol 1.7 entero. Así que se
cuidadoso por que puede matar tu mascota, poner a tu madre furiosa, quitarte el
sueño o simplemente no funcionar o compilar.

2) Qué es dietlibc
~~~~~~~~~~~~~~~~~~

Dietlibc es una pequeña alternativa para libc. Al contrario que libc, no esta
tan hinchado y es muy util para sistemas embebidos o discos de instalación,
donde el espacio de disco es algo caro.

Dietlibc está aún bajo un intenso desarrollo. Hay varios bugs que deberían de
ser arreglados. Pero es lo suficiente funcional para intentar compilar un
sistema basado completamente en dietlibc. (Alguien ha de empezar con ello ;-) )
Pondremos a funcionar a este pequeñín ayudando a los desarrolladores de 
dietlibc a encontrar bugs en su criatura ;-).

3) Preparando la compilación
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tienes que instalar dietlibc. Puedes usar los fuentes que han sido descargados
por rocklinux (puedes encontralos en download/base/dietlibc/dietlibc-$ver.tar.bz2)
o conseguirlos desde http://www.fefe.de/dietlibc/

El próximo paso es reemplazar el comando cc con un script que arranque gcc con
un emvoltorio diet preañadido. Para hacer esto ejecutaremos estos comandos:

# mv /usr/bin/cc /usr/bin/cc.bak
# vi /usr/bin/cc

E insertaremos el siguiente código en el fichero:

#!/bin/sh
exex diet gcc "$@"

Entonces debes cambiar los permisos del script:

# chmod +x /usr/bin/cc

Eso es todo lo que necesitas hacer para empezar con el proceso de 
compilación del target dietlibc.

4) Compilación
~~~~~~~~~~~~~~

Haz lo mismo que está descrito en Documentation/Build seleccionando el
target dietlibc en scripts/Config.

Por favor desactiva la opción "Create cache files after packages have 
been built" en la sección expert de scripts/Config. Por lo que se no 
funciona.

Eso debería de ser todo.

Envía comentarios a la lista de correo de rocklinux (rock-linux@rocklinux.org)
y/o a mi directamente (esden@rocklinux.org).

(C) 2002 by Piotr Esden-Tempski (esden@rocklinux.org)





