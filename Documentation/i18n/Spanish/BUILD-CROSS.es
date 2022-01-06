		      Compilaci�n Cruzada de ROCK Linux
		      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	1. Compilacion cruzada de ROCK Linux en si mismo (la distribuci�n)
	==================================================================

La compilaci�n cruzada de ROCK Linux desde una arquitectura a otra es sencilla.
�nicamente sigue los pasos descritos en el fichero Documentation/BUILD y 
asegurate de haber seleccionado la opci�n en la configuraci�n 'This is a 
cross-build between architectures'.

Ahora, cuando ejecutes './scripts/Build-Target', primero se crear� un compilador
cruzado y despu�s se realizar� una compilaci�n cruzada de una distribuci�n ROCK
Linux m�nima. Esta compilaci�n m�nima contiene todo lo necesario para un sistema
completo con l�nea de comandos incluyendo proceso init, shell, etc., pero sin
incluir un n�cleo Linux.

Puedes instalar este sistema ROCK Linux compilado en cruzado sobre la 
arquitectura destino y realizar una recompilaci�n completa de ROCK Linux en ella
si necesitas los paquetes m�s avanzados (como X11).

Ten en cuenta que no todos los destinos pueden ser compilados de forma cruzada 
sin dar errores, pero el objetivo 'generic' deber�a de hacerlo sin problemas.


	2. Compilando el n�cleo de forma cruzada
	========================================

Primero extrae los fuentes del n�cleo en alg�n lugar. No compiles el n�cleo en 
/usr/src/linux - esto podr�a destrozar los ficheros de cabecera del sistema!
Vete al directorio de los fuentes del n�cleo de linux que extrajiste.

Antes de que podamos continuar con la compilaci�n, debemos de decirle al sistema
donde est� instalado el compilador cruzado que construimos con 
'./scripts/Build-Target'. Este esta en el directorio base de ROCK Linux, bajo
build/<config-id>/tools/crosscc. As� que debemos extender la variable de 
entrono PATH con esa ruta, usando un comando como este, ejemplo para PowerPC:

	export PATH="/rock-linux/build/powerpc-1.7.0-DEV-powerpc-cross-generic/tools/crosscc:$PATH"

Tambi�n necesitamos indicarle al n�cleo el compilador cruzado que usaremos y la
arquitectura. A�ade en el Makefile las variables ARCH y CROSS_COMPILE. Por 
ejemplo para PowerPC:

	ARCH = ppc
	CROSS_COMPILE = powerpc-unknown-linux-gnu-

Ahora ya puedes configurar y compilar el n�cleo normalmente usando "make 
menuconfig" y "make vmlinux" (o "make bzImage").


	3. Instalando los resultados
	============================

Este paso es el m�s complicado y quizas sea dificultoso para algunas 
arquitecturas. Necesitas exportar el sistema en build/<config-id>/root usando
NFS y arrancar el n�cleo compilado cruzado sobre la arquitectura destino por
medio de nfs-root.

Digamos que queremos instalar nuestra compilacion cruzada desde PowerPC sobre 
un RS/6000 con OpenFirmware. En ese caso necesitaremos copiar la imagen del 
n�cleo a un disco floppy y arrancar el n�cleo con el comando de Openfirmware:

	boot floppy:,zImage.prep root=/dev/nfs nfsroot=/ppc-nfs-root \
				 ip=192.168.0.2:192.168.0.1

Asumiendo que el servidor NFS tiene la direcci�n ip 192.168.0.1, el cliente
deber�a de usar la ip 192.168.0.2 y el directorio exportado es "/ppc-nfs-root".
Lee el fichero Documentation/nfsroot.txt en los fuentes del n�cleo de linux para
m�s detalles.

Ahora puedes usar los comandos normales de Linux para crear un sistema de 
ficheros sobre una particion local y copiar todos los datos del sistema.

