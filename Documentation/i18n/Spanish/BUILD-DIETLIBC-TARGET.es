				Dietlibc-target
                                ~~~~~~~~~~~~~~~

�ndice
~~~~~~

1) Prefacio
2) �Qu� es dietlibc?
3) Preparaci�n para la compilaci�n
4) Compilaci�n

1) Prefacio
~~~~~~~~~~~

Hola, �ste es un peque�o COMO compilar el target dietlibc. Espero que llegue el
d�a en que ya no haga falta por que el target sea algo evidente. Actualmente es
m�s bien un boceto de howto, pero �a qui�n le importa? es mejor que nada, 
�cierto?

Algunas cosas muy internas se encuentran en Documentation/Developers/TODO. Hay 
tambi�n problemas actuales y bugs, as� que aunque no seas un desarrollador
prob�blemente quieras leerlo.

El target es actu�lmente experimental, como el arbol 1.7 entero. As� que se
cuidadoso por que puede matar tu mascota, poner a tu madre furiosa, quitarte el
sue�o o simplemente no funcionar o compilar.

2) Qu� es dietlibc
~~~~~~~~~~~~~~~~~~

Dietlibc es una peque�a alternativa para libc. Al contrario que libc, no esta
tan hinchado y es muy util para sistemas embebidos o discos de instalaci�n,
donde el espacio de disco es algo caro.

Dietlibc est� a�n bajo un intenso desarrollo. Hay varios bugs que deber�an de
ser arreglados. Pero es lo suficiente funcional para intentar compilar un
sistema basado completamente en dietlibc. (Alguien ha de empezar con ello ;-) )
Pondremos a funcionar a este peque��n ayudando a los desarrolladores de 
dietlibc a encontrar bugs en su criatura ;-).

3) Preparando la compilaci�n
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tienes que instalar dietlibc. Puedes usar los fuentes que han sido descargados
por rocklinux (puedes encontralos en download/base/dietlibc/dietlibc-$ver.tar.bz2)
o conseguirlos desde http://www.fefe.de/dietlibc/

El pr�ximo paso es reemplazar el comando cc con un script que arranque gcc con
un emvoltorio diet prea�adido. Para hacer esto ejecutaremos estos comandos:

# mv /usr/bin/cc /usr/bin/cc.bak
# vi /usr/bin/cc

E insertaremos el siguiente c�digo en el fichero:

#!/bin/sh
exex diet gcc "$@"

Entonces debes cambiar los permisos del script:

# chmod +x /usr/bin/cc

Eso es todo lo que necesitas hacer para empezar con el proceso de 
compilaci�n del target dietlibc.

4) Compilaci�n
~~~~~~~~~~~~~~

Haz lo mismo que est� descrito en Documentation/Build seleccionando el
target dietlibc en scripts/Config.

Por favor desactiva la opci�n "Create cache files after packages have 
been built" en la secci�n expert de scripts/Config. Por lo que se no 
funciona.

Eso deber�a de ser todo.

Env�a comentarios a la lista de correo de rocklinux (rock-linux@rocklinux.org)
y/o a mi directamente (esden@rocklinux.org).

(C) 2002 by Piotr Esden-Tempski (esden@rocklinux.org)





