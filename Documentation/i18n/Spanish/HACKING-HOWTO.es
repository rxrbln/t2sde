
			  Hacking ROCK Linux COMO
			===========================
			 Escrito por Clifford Wolf
			 ~~~~~~~~~~~~~~~~~~~~~~~~~

El diccionario Jargon define a un "Hacker" como:

# hacker n.
#
#	[originalmente, alguien que construye muebles con un hacha] 
#	1. Persona a la c�al le divierte explorar los detalles de sistemas
#	programables y como apurar sus capacidades, al contrario que la
#	mayoria de los usuarios, los cuales prefieren aprender s�lo lo 
#	m�nimo necesario. 2. Alguien que programa entusiasm�damente (incluso
#	obsesivamente) o a qui�n le divierte m�s la programaci�n que la 
#	teor�a acerca de ella. 3. Persona capaz de apreciar un valores de 
#	hacker. 4. Persona que es buena programando r�pidamente. 5. Un 
#	experto en un programa particular, o alguien que frecu�ntemente
#	realiza el trabajo us�ndolo, o sobre �l. como en 'hacker de Unix'.
#	(Las definiciones de la 1 a la 5 son coorelativas, y las personas
#	que encajan en ellas se congregan.) 6. Un experto o entusiasta de
#	algo. Uno podr�a ser un hacker de la astronom�a por ejemplo. 7. 
#	Alguien a qui�n divierte el reto intelectual de superar o rodear las
#	limitaciones de forma creativa. 8. [desaprobado] Un intruso malicioso
#	que intenta descubrir informaci�n delicada fisgoneando. De ah� 
#	`hacker de passwords', `hacker de redes'. El t�rmino correcto para 
#	este sentido es cracker.

Por lo tanto este "ROCK Linux Hacking COMO" no tiene nada que ver con
seguridad de m�quinas o de redes.

	
			�ndice
			======

0. Prefacio

1. Arbol de directorio de ROCK Linux.
1.1. Documentation/
1.2. scripts/
1.3. package/
1.3.1. package/base/
1.3.2. package/x11/
1.3.3. package/<architecture>/
1.3.4. package/<person>/
1.4. misc/
1.5. target/
1.6. architecture/
1.7. download/
1.8. src*/ and build/
1.9. config/*

2. Build- y otros scripts
2.1. ./scripts/Config
2.2. ./scripts/Download
2.3. Scripts para construir lo necesario
2.3.1. ./scripts/Build-Target
2.3.2. ./scripts/Build-Pkg
2.3.3. ./scripts/Build-TarBz2
2.3.4. ./scripts/Build-Tools
2.3.5. ./scripts/Build-CrossCC
2.3.6. ./scripts/Build-Job
2.4. Varias peque�as ayudas
2.4.1. ./scripts/Cleanup
2.4.2. ./scripts/Create-Links
2.4.3. ./scripts/Create-PkgList
2.4.4. ./scripts/Create-PkgQueue
2.4.5. ./scripts/Create-SrcTar
2.4.6. ./scripts/Create-Diff
2.4.7. ./scripts/Create-CkSumPatch
2.4.8. ./scripts/Create-DescPatch
2.4.9. ./scripts/Create-PkgUpdPatch
2.4.10. ./scripts/Create-ErrList
2.4.11. ./scripts/Create-UpdList
2.4.12. ./scripts/Update-System
2.4.13. ./scripts/Puzzle
2.4.14. ./scripts/Help
2.4.15. ./scripts/Internal
2.5. Scripts para realizar chequeos
2.5.1. ./scripts/Check-PkgVersion
2.5.2. ./scripts/Check-PkgFormat
2.5.3. ./scripts/Check-System
2.5.4. ./scripts/Check-Deps
2.6. Scripts para actualizar el arbol de fuentes
2.6.1. ./scripts/Update-Src

3. Configuraci�n del sistema
3.1. Fundamentos
3.2. Comandos especiales
3.2.1. comment 'Descripci�n' ["Ayuda"]
3.2.2. comment_id 'Descripci�n' 'ID' ["Ayuda"]
3.2.3. bool 'Descripci�n' Variable Valor_Defecto ["Ayuda"]
3.2.4. text 'Descripci�n' Variable Valor_Defecto ["Ayuda"]
3.2.5. choice Variable Valor_Defecto Value1 'Descripci�n1' [ ... ]
3.2.6. const Variable Valor_Defecto
3.2.7. Block_begin y block_end
3.2.8. expert_begin y expert_end
3.3. Variables especiales
3.3.1. ROCKCFG_*
3.3.2. ROCKCFGSET_*
3.3.3. CFGTEMP_*
3.4. Jerarquia de llamada de Config.in
3.5. Creacci�n del fichero Packages

4. Paquetes
4.1. Fundamentos
4.2. Los ficheros *.desc
4.2.1. Prioridad de paquetes
4.2.2. URLs de descargas
4.3. Los ficheros *.desc
4.3.1. FIXME
4.4. Los ficheros *.patch
4.5. Los ficheros *.doc
4.6. Los ficheros *.init

5. Targets

6. Arquitecturas


( created with >> perl -pe '$_="" unless /^\t?[0-9]/; s/^\t/\n/;' << )


		0. Prefacio
		===========
Este documento describe como extender y modificar los scripts de compilaci�n
de ROCK Linux.

Necesitas tener buenos conocimientos de shell scripting  para entender las
t�cnicas descritas en �ste documento. Algo de pr�ctica compilando e instalando
software en sistemas UNIX tambi�n te ayudar�.

Usa el c�digo existente (paquetes, targets, etc.) como ejemplos. Las 
explicaciones dadas en ellos, son con frecuencia muy informativas y leer el 
c�digo te ayudar� a entenderlos.

Corecciones, etc. son siempre bienvenidas (mejor si es en diffs unificados).
										
				   -Clifford wolf <clifford@clifford.at>


		1. Arbol de directorio de ROCK Linux
		====================================

1.1. Documentation/
===================

La Documentaci�n de ROCK Linux. L�ela toda - si puedes! Deber�as tambi�n 
visitar nuestra p�gina oficial en www.rocklinux.org y subscribirte a las 
listas de correo.

1.2. scripts/
=============

Todos los scripts de compilaci�n y ayuda pueden ser encontrados aqu�. Una
descripci�n detalla de ellos, pueden ser encontrados en el cap�tulo 2.

�Estate seguro de llamarlos siempre desde el directorio base (como 
"./scripts/Config") y NO entrar a scripts/ y ejecutarlos desde ah�!

1.3. package/
=============

La parte espec�fica de los fuentes de paquetes de ROCK Linux es almacenada
en este arbol. Hay para cada paquete al menos un fichero ".desc" (mira el
cap�tulo 4 para m�s detalles acerca del formato de paquetes).

Dentro del directorio package/, cada contenedor de paquete posee su propio
subdirectorio. Un contenedor de paquete es una unidad organizativa que 
agrupa paquetes juntos. Todos los paquetes en un mismo contenedor son
mantenidos por la misma persona o por el mismo grupo.

Dentro del directorio del contenedor, cada paquete tiene su propio
subdirectorio. Por ejemplo el paquete 'gcc' puede ser encontrado en "package/
base/gcc".

1.3.1. package/base/
--------------------

El contenedor "base" incluye los paquetes m�s importantes del coraz�n del 
sistema. Cosas como el compilador, el n�cleo y los paquetes de comandos unix
est�ndar (fileutils, ...).

Los paquetes "base" son mantenidos por Clifford Wolf <clifford@rocklinux.org>.

1.3.2. package/x11/
-------------------

El contenedor "x11" incluye los paquetes de x11, gnome y kde. Todo lo que 
necesitas para configurar una estaci�n gr�fica incluyendo las herramientas m�s
importantes.

Los paquetes "x11" son mantenidos por Rene Rebe <rene@rocklinux.org>.

1.3.3. package/<architecture>/
-------------------

POR HACER

1.3.4. package/<person>
-------------------

POR HACER

1.4. misc/
==========

Varias cosas que no tienen cabida en otro lugar son incluidas aqu�.

1.5. target/
============

Un "target" es una distribuci�n basada en ROCK Linux. El "rock linux est�ndar"
es el target "generic", construido con las opciones por defecto.

Cada target tiene su propio subdirectorio en este arbol.

1.6. architecture/
==================

Cada una de las arquitecturas soportadas por ROCK Linux tiene su propio 
subdirectorio en este arbol.

1.7. download/
==============

Los ficheros tar de los paquetes originales son descargados a este directorio
por el script ./script/Download. S�lo los ficheros necesarios para compilar el
target seleccionado ser�n descargados.

1.8. src*/ y build/
===================

Las configuraciones de compilacion (creadas por './scripts/Config') son 
almacenados en el arbol config/. Cada configuraci�n posee su propio
subdirectorio ah�.


	2. Build- y otros scripts
	=========================

2.1. ./scripts/Config
=====================

El fichero ./script/Config es el script configuraci�n principal. Este analiza
los ficheros de metaconfiguraci�n descritos en el cap�tulo 3 y crea los 
ficheros de configuraci�n en config/<config-name>/.

2.2. ./scripts/Download
=======================

El script ./scripts/Download es la herramienta encargada de la descarga de 
los fuentes de los paquetes. Una llamada al script sin par�metros imprime
un mensaje de ayuda.

Para descargar ficheros s�lo:
	./scripts/Download download/P_base/linux/linux-2.4.18.tar.bz2

Descargar todos los ficheros de un s�lo paquete:
	./scripts/Download -package linux

Todos los ficheros necesarios para el target escogido:
	./scripts/Download -required

O s�mplemente para descargar todo:
	./scripts/Download -all

Si no especificas un mirror con la opci�n -mirror, el script conectar� a 
www.rocklinux.org y autodetectar� el mejor mirror.

La descarga de todos los ficheros requeridos desde un cdrom local (montado):
	./scripts/Download -mirror file:///mnt/cdrom/ -required

2.3. Scripts para construir lo necesario
========================================

2.3.1. ./scripts/Build-Target
-----------------------------

Compila el target seleccionado. Dependiendo de tu hardware y de la 
configuraci�n seleccionada con ./scripts/config, esto puede tomar algunos 
d�as para terminar. Este script ignora cualquier opci�n pasada.

2.3.2. ./scripts/Build.Pkg
--------------------------

Compila un �nico paquete. Una llamada a este script sin argumentos, imprimir�
un mensaje de ayuda. En la mayor�a de los casos, las opciones son s�lo 
necesitadas por Build-Target cuando se construye una distribuci�n completa.

Para la construcci�n de un s�lo paquete:
	./scripts/Build-Pkg gawk

Cuidado: La recompilaci�n de un paquete podr� sobreescribir o borrar los 
ficheros de configuraci�n. Si no des�as que �sto ocurra, usa pkg-update con un
paquete binario precompilado.

2.3.3. ./scripts/Build-TarBz2
-----------------------------

Este script crea un paquete binario (.tar.bz2) basado en los ficheros 
encontrados en el sistema. Es usado por ./script/Build-Pkg cuando es llamado
con la opci�n --maketar, aunque es tambi�n posible usarlo directamente.

2.3.4. ./scripts/Build-Tools
----------------------------

Script que crea el directorio 'build.xxxxxx.tools' (d�nde 'xxxxxx' es el 
identificativo de configuraci�n) el cual contiene varias aplicaciones de 
ayuda usadas por Build-Pkg y otros scripts.

Cu�ndo el script es llamado con la opci�n -cleanup, es forzado a realizar una
recompilaci�n de los ficheros en el directorio de herramientas. En la mayor�a
de los casos �ste script ser� llamado por otros scripts (y no por el usuario).

2.3.5. ./scripts/Build-CrossCC
------------------------------

Para una compilaci�n cruzada de ROCK Linux necesitas un compilador cruzado. 
Este script crea el compilador-cruzado. El compilador cruzado y las binutils
cruzadas ser�n instaladas en el arbol build/ d�nde el script Build-Pkg espera
encontrarlo.

2.3.6. ./scripts/Build-Job
--------------------------

Este script es el cliente cuando corres ./scripts/Target en una compilaci�n 
en modo paralelo (cluster).

2.4. Varias peque�as ayudas
===========================

2.4.1. ./scripts/Cleanup
------------------------

El script Cleanup puede ser usado para borrar los directorios src* y build*,
los cuales son creados por los scripts de compilaci�n. Nunca borres estos
directorios de forma manual!.

Por defecto ./scripts/Cleanup s�lo borra los direcorios src*. Los directorios
build* ser�n borrados cuando sea pasada la opci�n -full.

2.4.2. ./scripts/Create-Links
-----------------------------

Este sencillo script crea enlaces simb�licos desde el directorio base de ROCK
Linux a otro directorio. Esto puede ser util si tienes los fuentes de ROCK 
Linux en un disco (Compartido por NFS, etc ) y quieres construirlo en alg�n
lugar m�s:

	/disks/raid/archive/os/rock# mkdir -p /disks/fast/rock
	/disks/raid/archive/os/rock# ./scripts/Create-Links /disks/fast/rock

2.4.3. ./scripts/Create-PkgList
-------------------------------

Crea una lista de todos los paquetes disponibles. Si se le pasa el nombre de
una arquitectura como par�metro, s�lo los paquetes disponibles sobre esa
arquitectura se�n listados.

Es script es usado por ./scripts/Config durante el proceso de creacci�n de
los ficheros de paquetes.

2.4.4. ./scripts/Create-PkgQueue
--------------------------------

Crea una lista de paquetes que podr�an ser los siguientes a compilar. El 
primer par�metro es el n�mero m�ximo de paquetes a imprimir (0=sin l�mite) y
el segundo par�metro es el directorio raiz d�nde el script puede encontrar la
informaci�n de /var/adm/... que necesita. Por ejemplo:

     # ./scripts/Create-PkgQueue 3 build/1.7.0-DEV-intel-generic/root
     2 X --2------9 010.050 base strace 4.4 / development/tool 159
     2 X --2------9 010.052 base ltrace 0.3.10 / development/tool 85
     2 X --2-4----9 010.055 base perl5 5.6.1 / development/interpreter 125

Este script es usado al inicio por ./scripts/Build-Target.

2.4.5. ./scripts/Create-SrcTar
------------------------------

Crea un fichero .tar.bz2 que contiene los fuentes de ROCK Linux, Este script
es usado por los desarrolladores de ROCK Linux cuando liberan snapshots o 
nuevas versiones.

2.4.6. ./scripts/Create-Diff
----------------------------

Este script es la herramienta recomendada para construir los parches diff. 
(Cuando haces alg�n cambio a los fuentes de ROCK Linux y quieres compartir tu
trabajo).

Por ejemplo: ./scripts/Create-Diff ../rock-src.orig . > mychanges.diff

2.4.7. ./scripts/Create-CkSumPatch
----------------------------------

Script que puede ser usado por los desarrolladores de ROCK Linux para crear de
forma autom�tica los checksums de las descargas en los ficheros .desc en uno
o m�s contenedores de paquetes.

Por ejemplo: ./scripts/Create-CkSumPatch extra2 ; patch -p1 < cksum.patch

2.4.8. ./scripts/Create-DescPatch
---------------------------------

Este script puede ser usado por los desarrolladores de ROCK Linux para que de
forma autom�tica adopten el formato del paquete los ficheros .desc.

2.4.9. ./scripts/Create-PkgUpdPatch
-----------------------------------

Script que permite a los desarrolladores de ROCK Linux crear autom�ticamente
parches de actualizaci�n de paquetes (despu�s de evaluar la salida del script
./scripts/Check-PkgVersion). Por ejemplo:

 	./scripts/Create-PkgUpdPatch > update.patch << EOT
		automake-1.6.1, bin86-0.16.3, bison-1.35, curl-7.9.6,
		diffutils-2.8.1, dump-0.4b28, ifhp-3.5.7, net-snmp-4.2.4,
		ntp-4.1.1, pciutils-2.1.10, sendmail.8.12.3, silo-1.2.5,
		tree-1.4b2, util-linux-2.11q, whois_4.5.25
	EOT

El fichero .patch de actualizaci�n resultante deber�a de ser chequeado 
manualmente antes de ser aplicado con 'patch -1 < update.patch'.

2.4.10. ./scripts/Create-ErrList
--------------------------------

Muestra una salida con la lista de paquetes que fallaron al compilarse 
(incluyendo los n�meros de stage). en el orden correcto.

2.4.11. ./scripts/Create-UpdList
--------------------------------

Crea la lista de paquetes que est�n activos en la configuraci�n actual y han
cambiado desde que los binarios instalados en el sistema han sido generados.
La comparaci�n es realizada usando los checksum del paquete fuente almacenados
en /var/adm/packages/<nombre-de-paquete>.

2.4.12. ./scripts/Update-System
-------------------------------

Actualiza (recompila) todos los paquetes en el sistema local para los cuales
hay disponible alguna nueva versi�n. Create-UpList es usado para generar la
lista de paquetes que necesitan ser actualizados.

2.4.13. ./scripts/Puzzle
------------------------

Algunos ficheros en el �rbol de fuentes son creados autom�ticamente. Este 
script los regenera todos, y deber�a de ser llamado cada vez que uno de los 
ficheros de los fuentes haya cambiado.

 2.4.14. ./scripts/Help
----------------------

Este script espera el nombre de fichero de un script en ./scripts/ y salta a
la posici�n correcta en la documentaci�n. Es una sencilla envoltura para 
'less'.

2.4.15. ./scripts/Internal
--------------------------

Script que usa Clifford Wolf para liberar snapshots y mantener los Mirrors de
FTP actualizados.

2.5. Scripts para realizar chequeos
=============================

2.5.1. ./scripts/Check-PkgVersion
---------------------------------

Script que es usado por los desarrolladores de ROCK Linux para chequear por
nuevas versiones de paquetes. Los resultados de la �ltima ejecuci�n son 
siempre almacenados en un directorio llamado checkver/ y si hay alguna 
diferencia en la ejecuci�n actual, un fichero *.msg ser� escrito en checkver/.
(lee el script para m�s detalles)

Por ejemplo: ./scripts/Check-PkgVersion -repository base
	      for x in checkver/*.new ; do mv -f $x ${x%.new}.txt ; done
	      cat checkver/*.msg > todo.txt

Nota: Los ficheros .mgs viejos ser�n autom�ticamente borrados cuando corras
Check-PkgVersion la pr�xima vez.

2.5.2. ./scripts/Check-PkgFormat
--------------------------------

Este script hace unos pocos testeos sencillos para autodetectar errores en los
ficheros *.desc y *.conf de los paquetes.

Por ejemplo: ./scripts/Check-PkgFormat -repository extra1

2.5.3. ./scripts/Check-System
-----------------------------

Este script hace uns simple test para autodetectar posibles errores con el 
sistema de la m�quina linux.

2.5.4. ./scripts/Check-Deps
---------------------------

Este comando chequea si el orden del paquete de la compilaci�n actual es 
correcto para pasar todas las dependencias de paquetes.

2.6. Scripts for updating the source tree
=========================================

2.6.1. ./scripts/Update-Src
---------------------------

Actualiza el �rbol de fuentes con rsync desde www.rocklinx.org.
Cuidado: Esto borrar� los cambios que realizaras en el �rbol de fuentes.

	
	3. Configuration System
	=======================


3.1. Fundamentos
================

El script de configuraci�n ./sripts/Config genera los ficheros en el 
directorio /config/${config}/:

	config		las opciones de configuraci�n
	packages	los paquetes que son compilados en esa configuraci�n

./scripts/Config define algunas funciones de shell especiales y contiene el
bucle principal del programa de configuraci�n. La estructura de los men�s de
configuraci�n es almacenada en scripts/config.in (y otros ficheros config.in
incluidos por el). Echa un vistazo a scripts/config.in para m�s informaci�n 
sobre qu� ficheros incluyen a qu� otros.

3.2. Comandos especiales
========================

Cada vez que el men� es mostrado (por ejemplo, despu�s de arrancar ./scripts/
Config y cada vez que se realiza alg�n cambio), scripts/config.in es ejecutado
y est� usando sus propios comandos especiales para escribir el fichero de 
configuraci�n y a�adir items al men�.

3.2.1. comment 'Descripci�n' ["Ayuda"]
-------------------------------------

A�ade un comentario al men� de configuraci�n (y lo hace sin ninguna funci�n).
Por ejemplo:

	comment '-Arquitectura, CPU y Optimizaci�n' " 
	Selecciona que optimizaci�n de CPU se corresponde con tu m�quina."

<Descripci�n>	T�tulo del item en el menu de configuraci�n (texto del 
		comentario).

<Ayuda>		Este es un campo opcional donde puedes a�adir un comentario
		m�s largo que ser� mostrado cuando selecciones esta l�nea de
		comentario y pulses sobre el bot�n de ayuda.

3.2.2. comment_id 'Descripci�n' 'ID' ["Ayuda"]
---------------------------------------------

A�ade un comentario al men� de configuraci�n (y lo hace sin ninguna funci�n).
Por ejemplo:

	comment '-Arquitectura, CPU y Optimizaci�n' COMMENT_ARCH_CPU_OPT "
	Selecciona que optimizaci�n de CPU se corresponde con tu m�quina."

<Descripci�n>	T�tulo del item en el menu de configuraci�n (texto del 
		comentario).

<ID>		Identificativo que ser� usado para identificar un comentario.
		Es �til cuando usas ficheros config.hlp para almacenar la
		ayuda.

<Ayuda>		Este es un campo opcional donde puedes a�adir un comentario
		m�s largo que ser� mostrado cuando selecciones esta l�nea de
		comentario y pulses sobre el bot�n de ayuda.

3.2.3. bool 'Descripci�n' Variable Valor_Defecto ["Ayuda"]
---------------------------------------------------

A�ade un item booleano (on/off) al men�. Por ejempo:

	bool 'Abortar cuando la compilaci�n de un paquete falle' 
	ROCKCFG_ABORT_ON_ERROR 1 "
	Cu�ndo selecciones �sta opci�n, Build-Target abortar� cuando un paqute
	falle al compilar"

<Descripci�n>	T�tulo del item en el men� de configuraci�n
<Variable>	Nombre de la variable de configuraci�n asociada a �ste item
		del men�
<Valor_Defecto>	'1' = On, '0' = Off
<Ayuda>		Este es un campo opcional donde puedes a�adir un comentario
		m�s largo que ser� mostrado cuando selecciones esta l�nea de
		comentario y pulses sobre el bot�n de ayuda

La variable estar� activada a '1' o a '0'.

3.2.4. text 'Descripci�n' Variable Valor_Defecto ["Help"]
---------------------------------------------------

A�ade un item de texto en el men�. Si el texto debe de coincidir con un patr�n
especial, modifica la variable de configuraci�n antes de hacer la llamada a la
funci�n text. Por ejemplo:

	ROCKCFG_MAKE_JOBS="`echo $ROCKCFG_MAKE_JOBS | sed 's,[^0-9],,g'`"
	text 'N�mero de procesos make paralelos (make -j)' ROCKCFG_MAKE_JOBS 1
 
<Descripci�n>	T�tulo del item en el men� de configuraci�n
<Variable>	Nombre de la variable de configuraci�n asociada a �ste item
		del men�
<Valor_Defecto>	Valor por defecto
<Ayuda>		Este es un campo opcional donde puedes a�adir un comentario
		m�s largo que ser� mostrado cuando selecciones esta l�nea de
		comentario y pulses sobre el bot�n de ayuda

3.2.5. choice Variable Valor_Defecto Valor1 'Descripci�n1' [ ... ]
------------------------------------------------------------------

A�ade un item al men� de m�ltiples opciones. Por ejemplo:

	choice ROCKCFG_INTEL_OPT generic   \
		generic "Sin optimizaci�n especial"          \
		i386    "Optimizado para Intel 386"          \
		i486    "Optimizado para Intel 486"          \
		i586    "Optimizado para Intel Pentium"      \
		i686    "Optimizado para Intel Pentium-Pro"  \
		k6      "Optimizado para AMD K-6"            \
		k7      "Optimizado para AMD Athlon"

<Variable>	Nombre de la variable de configuraci�n asociada a �ste item
		del men�
<Valor_Defecto>	Valor por defecto

<ValorN>	Valor para la opci�n N
<Descripci�nN>	T�tulo del item en el men� de configuraci�n si la opci�n N
		est� activa

3.2.6. const Variable Valor_Defecto
-----------------------------------

Asigna la variable con el valor por defecto dado sin mostrar ning�n item en
el men�.

3.2.7. block_begin y block_end
------------------------------

Un conjunto de items de men�, los cuales permanecen juntos, deben estar entre
block_begin y block_end. block_begin espera un par�metro num�rico que 
especifica el n�mero de car�cteres que el t�tulo del item del men� deber� ser
desplazado a la derecha. Por ejemplo:

    comment '---   Compilador por defecto para compilar (casi) todo'
    block_begin 5
        choice ROCKCFG_PKG_GCC_DEFAULT_CC gcc2 $list

        if [ $ROCKCFG_PKG_GCC_DEFAULT_CC = 'gcc2' ] ; then
           bool 'Usar GCC Stack-Smashing Protector' ROCKCFG_PKG_GCC_STACKPRO 0
           [ $ROCKCFG_PKG_GCC_STACKPRO = 1 ] &&
                                ROCKCFG_ID="$ROCKCFG_ID-stackprotector"
        else
            ROCKCFG_ID="$ROCKCFG_ID-$ROCKCFG_PKG_GCC_DEFAULT_CC"
        fi
    block_end

3.2.8. expert_begin y expert_end
--------------------------------

Las opciones que s�lo deber�an de ser mostradas si el 'modo experto' est�
activo, deben ir entre expert_begin y expert_end.


3.3. Variables especiales
=========================

3.3.1. ROCKCFG_*
----------------

Todas las variables de configuraci�n deber�an de empezar con "ROCKCFG_". Las
variables que no son principales tienen prefijos de extensi�n:

Arquitecturas:	ROCKCFG_ARCH_<Nombre-Arquitectura>_*
Targets:	ROCKCFG_TRG_<Nombre-Target>_*
Paquetes:	ROCKCFG_PKG_<Nombre-Paquete>_*

Algunas variables son manejadas por ./scripts/Config de una manera especial:

ROCKCFG_ID	Es la descripci�n corta de la configuraci�n. Las opciones 
		de configuraci�n importantes deber�an de a�adir algo a �sta
		variable.

ROCKCFG_EXPERT	Si �sta puesta a '0', los items entre expert_begin y 
		expert_end no ser�n mostrados y los valores por defecto para 
		esas opciones ser�n usados.

3.3.2. ROCKCFGSET_*
-------------------

Las variables ROCKCFGSET_* pueden ser usadas para preservar una opci�n (por
ejemplo, en un target). Si por ejemplo, ROCKCFGSET_STRIP est� puesta a 1,
ROCKCFG_STRIP tendr� el valor 1 y el usuario no podr� cambiar su valor.

3.3.3. CFGTEMP_*
----------------

Estas variables pueden ser usadas para intercambio de datos entre los 
distintos ficheros config.in. Las variables no principales tienen prefijos de
extensi�n:

Arquitecturas:	ROCKCFG_ARCH_<Nombre-Arquitectura>_*
Targets:	ROCKCFG_TRG_<Nombre-Target>_*
Paquetes:	ROCKCFG_PKG_<Nombre-Paquete>_*

Por ejemplo, la creacci�n din�mica de una opci�n de m�ltiples elecciones:

architecture/intel/preconfig.in:
	CFGTEMP_ARCHLIST="$CFGTEMP_ARCHLIST intel IBM_PCs_and_compatible"

architecture/powerpc/preconfig.in:
	CFGTEMP_ARCHLIST="$CFGTEMP_ARCHLIST powerpc PowerPC_Workstations"

scripts/config.in:
	choice ROCKCFG_ARCH $ROCKCFG_ARCH $CFGTEMP_ARCHLIST

3.4. Jerarquia de llamada de Config.in
======================================

Todsos los ficheros config.in son ejecutados desde scripts/config.in en el 
siguiente orden:

	- architecture/*/preconfig.in

	* Selecting Architecture
	* architecture/$ROCKCFG_ARCH/config.in

	- target/*/preconfig.in
	- package/*/*/preconfig.in

	* Selecting Target
	* target/$ROCKCFG_TARGET/config.in

	* package/*/*/config.in
	* Various common build options

	- package/*/*/postconfig.in
	- architecture/$ROCKCFG_ARCH/postconfig.in
	- target/$ROCKCFG_TARGET/postconfig.in

S�lo los scripts marcados con '*' podr�n interactuar con el usuario (creando
items del men�). El resto podr� s�lo activar y modificar distintas variables.

3.5. Creacci�n del fichero Packages
===================================

EL script ./scripts/Config crea un fichero de paquetes con todos los paquetes
disponibles para la arquitectura seleccionada antes de llamar a 
scripts/config.in. Cada fichero config.in podr� ahora modificar este fichero
Packages creando un fichero Packages.new y renombr�ndolo a Packages. Por 
ejemplo:

	if [ $ROCKCFG_TRG_GENERIC_BUILDSF != 1 ] ; then
                awk '$4 != "sourceforge" { print }' \
			< config/$config/packages \
			> config/$config/packages.new
                mv config/$config/packages.new config/$config/packages
        fi

EL fichero de paquetes esta separado por blancos y es facil de analizar con 
grep, sed y awk.
Los campos son:

X/O	'X' = el paquete est� activo,	'O' = el paquete no est� activo
	Si no quieres que otro config.in reactive un paquete, podr�s tambi�n,
	s�mplemente borrar la l�nea del fichero.

Stages	Niveles de stage igual que los especificados en la marca [P] de los 
	paquetes (ver el pr�ximo cap�tulo)

Pri.	Prioridad especificada igual que en el tag [P] de los paquetes (atajo
	para el fichero)

Resp.	Nombre del contenedor d�nde se encuentra el paquete

Name	Nombre del paquete

Ver.	Versi�n del paquete

Prefix	Prefijo del paquete (seguido de '/')

Cat.	Categor�as del paquete (siempre en min�sculas, conteniendo al menos
	un /)

Flags	Banderas del paquete (siempre may�sculas)

Counter	S�mplemente ignora �ste fichero

C�mo el campo 'counter', las categor�as u las banderas son siempre seguidas y
precedidas de un ' ', puedes de forma sencilla borrar todos los paquetes menos
dietlibc-ready con un comando como:

	grep ' DIETLIBC ' < config/$config/packages \
				> config/$config/packages.new

Leete los ficheros config.in que hay para m�s detalles.


	4. Paquetes
	===========

4.1. Fundamentos
================

Cada paquete tiene su propio subdirectorio en package/<contenedor>/. Los
contenedores son unidades organizativas que agrupan paquetes. Cada contenedor
pertenece a un desarrollador de ROCK Linux o a un grupo de desarrolladores.

El nombre del paquete es de 2 a 25 car�cteres de largo y debe coincidir con
la expresi�n regular:

	/^[a-z0-9][a-z0-9\.\+_-]*[a-z0-9\+]$/

(Con un m�nimo de 2 car�cteres. El primero: letra en min�scula o n�mero. El
�ltimo: letra en min�scula o n�mero o '+'. El resto: letras en min�scula,
n�meros o uno de los siguientes car�cteres: '.', '+', '_' o '-'.)

Un nombre de paquete no debe aparecer en m�s de un contenedor.

Otros subdirectorios (que no sean de paquetes) est�n permitidos, si no empiezan
con una letra min�scula o un n�mero (as� por ejemplo, los directorios "CVS"
est�n permitidos) y que no contenga alg�n fichero *.desc.

Este directorio de paquete contiene toda la informaci�n necesaria para 
descargar y compilar un paquete.

4.2. Los ficheros *.desc
========================

Cada paquete DEBE tener un fichero <nombre_de_paquete>.desc. Este contiene toda
la metainformaci�n del paquete. Echa un vistazo al fichero PKG-DESC-FORMAT para
una descripci�n de las etiquetas disponibles.

4.2.1. Prioridad de paquetes
----------------------------

La etiqueta [P] es usada para indicar la prioridad del paquete. Esta etiqueta
tiene 3 campos:

	[P] X --3-----9 010.066

El primer campo ('X' o 'O') especifica si el paquete deber�a de ser construido
por defecto o no. Este valor suele valer 'X' en casi todos los paquetes. Esta
bandera podr� ser sobreescrita por la configuraci�n (cap�tulo 3).

El segundo campo lista los stages en los cuales el paquete deber�a de ser 
compilado. Hay 10 stages (0-9). Build-Target empezar� con la compilaci�n en el
stage 1, despu�s stage 2, etc... El stage 9 s�lo es construido si se activa en 
la configuraci�n 'Make rebuild stage (stage 9)'. Los stages 0 y 1 son stages
para la compilaci�n cruzada, y deber�an s�lo de contener paquetes que soporten
este tipo de compilaci�n. De esta forma los stages pueden ser usados para 
indicar el orden de compilaci�n (por ejemplo, el stage 3 se construye antes que
el stage 5) y para reconstruir un paquete varias veces.

El tercer campo es usado para especificar el orden de compilaci�n junto con los
stages. Este es un ordenado por texto simplemente.

4.2.2. URLs de descarga
-----------------------

Generalmente un paquete debe descargar uno o m�s ficheros de fuentes. Estos
ficheros son descargados usando el script ./scripts/Download y se almacenan en
el directorio 'download/<nombre-de-repositorio>/<nombre-de-paquete>/'.

Cada fichero que pueda ser descargado tiene su pr�pia etiqueta [D] en el 
fichero *.desc del paquete. La etiqueta [D] tiene 3 campos:

	[D] 354985877 gcc-2.95.3.tar.gz ftp://ftp.gnu.org/pub/gnu/gcc/

El primer campo es el checksum para el fichero. Esos checksums son creados con
por ejemplo:

	./scripts/Download -mk-cksum download/base/gcc2/gcc-2.95.3.tar.bz2

Si el checksum es '0', significa que no ha sido creado un checksum. El script
'./scripts/Create-CkSumPatch'puede ser usado para crear un parche que a�ada
esos checksums.

Para los que no tengan checksum, por alguna u otra raz�n (por ejemplo, por que
el contenido del sitio original esta cambiando con frecuencia), una cadena 
consistente de s�lamente car�cteres 'X' puede ser usada. Por ejemplo:

	[D] XXXXXXXXXX RFCs3001-latest.tar.gz ftp://ftp.rfc-editor.org/in-notes/tar/
	
El segundo campo es el nombre del fichero. Los ficheros con el sufijo *.gz o 
*.tgz son autom�ticamente convertidos a *.bz2 o *.tbz2 por el script ./scripts/
Download.

El tercer par�metro es la URL de descarga sin la parte correspondiente al 
nombre del fichero. Si el nombre del fichero local difiere del remoto, la URL
deber�a de ser antecedido por un car�cter '!'. Por ejemplo:

	[D] 2447691734 services.txt !http://www.graffiti.com/services

El script ./scripts/Check-PkgVersion tambi�n usa esta etiqueta [D] para buscar
por nuevas versiones del paquete. El script './scripts/Check-PkgVersion' puede
tambi�n ser directamente configurado usando las etiquetas [CV-URL], [CV-PAT] y
[CV-DEL].

4.3. Los ficheros *.conf
========================

./scripts/Build-Pkg tienen un c�digo semi-inteligente para compilar e instalar
un paquete. Esto lo hace la funci�n de shell build_this_package(), la cual
puede se encontrada en ./scripts/Build-Pkg. Este scripts se configura usando
varias variables que pueden ser activadas o modificadas en el fichero *.conf.
Una lista de esas variables puede ser encontrada en el fichero PKG-BUILD-VARS
en este directorio. Lee los ficheros *.conf para ver ejemplos.

4.3.1. FIXME
------------

4.4. Los ficheros *.patch
=========================

Todos los ficheros *.patch en el directorio de paquetes son autom�ticamente 
aplicados despues de que el fichero tar de los fuentes del paquete sea 
extraido. El parche *.patch.<arquitectura> s�lo se aplica cuando se compila
para la arquitectura indicada.

4.5. Los ficheros *.doc
=======================

Todos los ficheros *.doc en el directorio de paquetes son autom�ticamente 
compiados al directorio de documentaci�n del paquete (por ejemplo /usr/share/
/doc/$pkg) sin el sufijo ".doc".

4.6. Los ficheros *.init
========================

Los scripts de inicializaci�n son isntalados usando la funci�n install_init.
Esta funci�n convierte un fichero *.init en un script de inicio estilo SysV.
Echale un vistazo a

	package/base/devfsd/devfsd.conf y
	package/base/devfsd/devfsd.init
o
	package/base/sysklogd/sysklogd.conf   y
	package/base/sysklogd/sysklogd.init

para peque�os ejemplos. La conversi�n desde los ficheros *.init a scripts de
inicio SysV es realizada usando m4 y el fichero de macros 'package/base/
/sysvinit/init_macros.m4'.

	5. Targets
	==========

 POR REALIZAR


	6. Arquitecturas
	================

 POR REALIZAR