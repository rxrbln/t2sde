		      Compilación Cruzada de ROCK Linux
		      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	1. Compilacion cruzada de ROCK Linux en si mismo (la distribución)
	==================================================================

La compilación cruzada de ROCK Linux desde una arquitectura a otra es sencilla.
Únicamente sigue los pasos descritos en el fichero Documentation/BUILD y 
asegurate de haber seleccionado la opción en la configuración 'This is a 
cross-build between architectures'.

Ahora, cuando ejecutes './scripts/Build-Target', primero se creará un compilador
cruzado y después se realizará una compilación cruzada de una distribución ROCK
Linux mínima. Esta compilación mínima contiene todo lo necesario para un sistema
completo con línea de comandos incluyendo proceso init, shell, etc., pero sin
incluir un núcleo Linux.

Puedes instalar este sistema ROCK Linux compilado en cruzado sobre la 
arquitectura destino y realizar una recompilación completa de ROCK Linux en ella
si necesitas los paquetes más avanzados (como X11).

Ten en cuenta que no todos los destinos pueden ser compilados de forma cruzada 
sin dar errores, pero el objetivo 'generic' debería de hacerlo sin problemas.


	2. Compilando el núcleo de forma cruzada
	========================================

Primero extrae los fuentes del núcleo en algún lugar. No compiles el núcleo en 
/usr/src/linux - esto podría destrozar los ficheros de cabecera del sistema!
Vete al directorio de los fuentes del núcleo de linux que extrajiste.

Antes de que podamos continuar con la compilación, debemos de decirle al sistema
donde está instalado el compilador cruzado que construimos con 
'./scripts/Build-Target'. Este esta en el directorio base de ROCK Linux, bajo
build/<config-id>/tools/crosscc. Así que debemos extender la variable de 
entrono PATH con esa ruta, usando un comando como este, ejemplo para PowerPC:

	export PATH="/rock-linux/build/powerpc-1.7.0-DEV-powerpc-cross-generic/tools/crosscc:$PATH"

También necesitamos indicarle al núcleo el compilador cruzado que usaremos y la
arquitectura. Añade en el Makefile las variables ARCH y CROSS_COMPILE. Por 
ejemplo para PowerPC:

	ARCH = ppc
	CROSS_COMPILE = powerpc-unknown-linux-gnu-

Ahora ya puedes configurar y compilar el núcleo normalmente usando "make 
menuconfig" y "make vmlinux" (o "make bzImage").


	3. Instalando los resultados
	============================

Este paso es el más complicado y quizas sea dificultoso para algunas 
arquitecturas. Necesitas exportar el sistema en build/<config-id>/root usando
NFS y arrancar el núcleo compilado cruzado sobre la arquitectura destino por
medio de nfs-root.

Digamos que queremos instalar nuestra compilacion cruzada desde PowerPC sobre 
un RS/6000 con OpenFirmware. En ese caso necesitaremos copiar la imagen del 
núcleo a un disco floppy y arrancar el núcleo con el comando de Openfirmware:

	boot floppy:,zImage.prep root=/dev/nfs nfsroot=/ppc-nfs-root \
				 ip=192.168.0.2:192.168.0.1

Asumiendo que el servidor NFS tiene la dirección ip 192.168.0.1, el cliente
debería de usar la ip 192.168.0.2 y el directorio exportado es "/ppc-nfs-root".
Lee el fichero Documentation/nfsroot.txt en los fuentes del núcleo de linux para
más detalles.

Ahora puedes usar los comandos normales de Linux para crear un sistema de 
ficheros sobre una particion local y copiar todos los datos del sistema.

