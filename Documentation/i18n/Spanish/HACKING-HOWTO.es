
			  Hacking ROCK Linux COMO
			===========================
			 Escrito por Clifford Wolf
			 ~~~~~~~~~~~~~~~~~~~~~~~~~

El diccionario Jargon define a un "Hacker" como:

# hacker n.
#
#	[originalmente, alguien que construye muebles con un hacha] 
#	1. Persona a la cúal le divierte explorar los detalles de sistemas
#	programables y como apurar sus capacidades, al contrario que la
#	mayoria de los usuarios, los cuales prefieren aprender sólo lo 
#	mínimo necesario. 2. Alguien que programa entusiasmádamente (incluso
#	obsesivamente) o a quién le divierte más la programación que la 
#	teoría acerca de ella. 3. Persona capaz de apreciar un valores de 
#	hacker. 4. Persona que es buena programando rápidamente. 5. Un 
#	experto en un programa particular, o alguien que frecuéntemente
#	realiza el trabajo usándolo, o sobre él. como en 'hacker de Unix'.
#	(Las definiciones de la 1 a la 5 son coorelativas, y las personas
#	que encajan en ellas se congregan.) 6. Un experto o entusiasta de
#	algo. Uno podría ser un hacker de la astronomía por ejemplo. 7. 
#	Alguien a quién divierte el reto intelectual de superar o rodear las
#	limitaciones de forma creativa. 8. [desaprobado] Un intruso malicioso
#	que intenta descubrir información delicada fisgoneando. De ahí 
#	`hacker de passwords', `hacker de redes'. El término correcto para 
#	este sentido es cracker.

Por lo tanto este "ROCK Linux Hacking COMO" no tiene nada que ver con
seguridad de máquinas o de redes.

	
			Índice
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
2.4. Varias pequeñas ayudas
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

3. Configuración del sistema
3.1. Fundamentos
3.2. Comandos especiales
3.2.1. comment 'Descripción' ["Ayuda"]
3.2.2. comment_id 'Descripción' 'ID' ["Ayuda"]
3.2.3. bool 'Descripción' Variable Valor_Defecto ["Ayuda"]
3.2.4. text 'Descripción' Variable Valor_Defecto ["Ayuda"]
3.2.5. choice Variable Valor_Defecto Value1 'Descripción1' [ ... ]
3.2.6. const Variable Valor_Defecto
3.2.7. Block_begin y block_end
3.2.8. expert_begin y expert_end
3.3. Variables especiales
3.3.1. ROCKCFG_*
3.3.2. ROCKCFGSET_*
3.3.3. CFGTEMP_*
3.4. Jerarquia de llamada de Config.in
3.5. Creacción del fichero Packages

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
Este documento describe como extender y modificar los scripts de compilación
de ROCK Linux.

Necesitas tener buenos conocimientos de shell scripting  para entender las
técnicas descritas en éste documento. Algo de práctica compilando e instalando
software en sistemas UNIX también te ayudará.

Usa el código existente (paquetes, targets, etc.) como ejemplos. Las 
explicaciones dadas en ellos, son con frecuencia muy informativas y leer el 
código te ayudará a entenderlos.

Corecciones, etc. son siempre bienvenidas (mejor si es en diffs unificados).
										
				   -Clifford wolf <clifford@clifford.at>


		1. Arbol de directorio de ROCK Linux
		====================================

1.1. Documentation/
===================

La Documentación de ROCK Linux. Léela toda - si puedes! Deberías también 
visitar nuestra página oficial en www.rocklinux.org y subscribirte a las 
listas de correo.

1.2. scripts/
=============

Todos los scripts de compilación y ayuda pueden ser encontrados aquí. Una
descripción detalla de ellos, pueden ser encontrados en el capítulo 2.

¡Estate seguro de llamarlos siempre desde el directorio base (como 
"./scripts/Config") y NO entrar a scripts/ y ejecutarlos desde ahí!

1.3. package/
=============

La parte específica de los fuentes de paquetes de ROCK Linux es almacenada
en este arbol. Hay para cada paquete al menos un fichero ".desc" (mira el
capítulo 4 para más detalles acerca del formato de paquetes).

Dentro del directorio package/, cada contenedor de paquete posee su propio
subdirectorio. Un contenedor de paquete es una unidad organizativa que 
agrupa paquetes juntos. Todos los paquetes en un mismo contenedor son
mantenidos por la misma persona o por el mismo grupo.

Dentro del directorio del contenedor, cada paquete tiene su propio
subdirectorio. Por ejemplo el paquete 'gcc' puede ser encontrado en "package/
base/gcc".

1.3.1. package/base/
--------------------

El contenedor "base" incluye los paquetes más importantes del corazón del 
sistema. Cosas como el compilador, el núcleo y los paquetes de comandos unix
estándar (fileutils, ...).

Los paquetes "base" son mantenidos por Clifford Wolf <clifford@rocklinux.org>.

1.3.2. package/x11/
-------------------

El contenedor "x11" incluye los paquetes de x11, gnome y kde. Todo lo que 
necesitas para configurar una estación gráfica incluyendo las herramientas más
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

Varias cosas que no tienen cabida en otro lugar son incluidas aquí.

1.5. target/
============

Un "target" es una distribución basada en ROCK Linux. El "rock linux estándar"
es el target "generic", construido con las opciones por defecto.

Cada target tiene su propio subdirectorio en este arbol.

1.6. architecture/
==================

Cada una de las arquitecturas soportadas por ROCK Linux tiene su propio 
subdirectorio en este arbol.

1.7. download/
==============

Los ficheros tar de los paquetes originales son descargados a este directorio
por el script ./script/Download. Sólo los ficheros necesarios para compilar el
target seleccionado serán descargados.

1.8. src*/ y build/
===================

Las configuraciones de compilacion (creadas por './scripts/Config') son 
almacenados en el arbol config/. Cada configuración posee su propio
subdirectorio ahí.


	2. Build- y otros scripts
	=========================

2.1. ./scripts/Config
=====================

El fichero ./script/Config es el script configuración principal. Este analiza
los ficheros de metaconfiguración descritos en el capítulo 3 y crea los 
ficheros de configuración en config/<config-name>/.

2.2. ./scripts/Download
=======================

El script ./scripts/Download es la herramienta encargada de la descarga de 
los fuentes de los paquetes. Una llamada al script sin parámetros imprime
un mensaje de ayuda.

Para descargar ficheros sólo:
	./scripts/Download download/P_base/linux/linux-2.4.18.tar.bz2

Descargar todos los ficheros de un sólo paquete:
	./scripts/Download -package linux

Todos los ficheros necesarios para el target escogido:
	./scripts/Download -required

O símplemente para descargar todo:
	./scripts/Download -all

Si no especificas un mirror con la opción -mirror, el script conectará a 
www.rocklinux.org y autodetectará el mejor mirror.

La descarga de todos los ficheros requeridos desde un cdrom local (montado):
	./scripts/Download -mirror file:///mnt/cdrom/ -required

2.3. Scripts para construir lo necesario
========================================

2.3.1. ./scripts/Build-Target
-----------------------------

Compila el target seleccionado. Dependiendo de tu hardware y de la 
configuración seleccionada con ./scripts/config, esto puede tomar algunos 
días para terminar. Este script ignora cualquier opción pasada.

2.3.2. ./scripts/Build.Pkg
--------------------------

Compila un único paquete. Una llamada a este script sin argumentos, imprimirá
un mensaje de ayuda. En la mayoría de los casos, las opciones son sólo 
necesitadas por Build-Target cuando se construye una distribución completa.

Para la construcción de un sólo paquete:
	./scripts/Build-Pkg gawk

Cuidado: La recompilación de un paquete podrá sobreescribir o borrar los 
ficheros de configuración. Si no deséas que ésto ocurra, usa pkg-update con un
paquete binario precompilado.

2.3.3. ./scripts/Build-TarBz2
-----------------------------

Este script crea un paquete binario (.tar.bz2) basado en los ficheros 
encontrados en el sistema. Es usado por ./script/Build-Pkg cuando es llamado
con la opción --maketar, aunque es también posible usarlo directamente.

2.3.4. ./scripts/Build-Tools
----------------------------

Script que crea el directorio 'build.xxxxxx.tools' (dónde 'xxxxxx' es el 
identificativo de configuración) el cual contiene varias aplicaciones de 
ayuda usadas por Build-Pkg y otros scripts.

Cuándo el script es llamado con la opción -cleanup, es forzado a realizar una
recompilación de los ficheros en el directorio de herramientas. En la mayoría
de los casos éste script será llamado por otros scripts (y no por el usuario).

2.3.5. ./scripts/Build-CrossCC
------------------------------

Para una compilación cruzada de ROCK Linux necesitas un compilador cruzado. 
Este script crea el compilador-cruzado. El compilador cruzado y las binutils
cruzadas serán instaladas en el arbol build/ dónde el script Build-Pkg espera
encontrarlo.

2.3.6. ./scripts/Build-Job
--------------------------

Este script es el cliente cuando corres ./scripts/Target en una compilación 
en modo paralelo (cluster).

2.4. Varias pequeñas ayudas
===========================

2.4.1. ./scripts/Cleanup
------------------------

El script Cleanup puede ser usado para borrar los directorios src* y build*,
los cuales son creados por los scripts de compilación. Nunca borres estos
directorios de forma manual!.

Por defecto ./scripts/Cleanup sólo borra los direcorios src*. Los directorios
build* serán borrados cuando sea pasada la opción -full.

2.4.2. ./scripts/Create-Links
-----------------------------

Este sencillo script crea enlaces simbólicos desde el directorio base de ROCK
Linux a otro directorio. Esto puede ser util si tienes los fuentes de ROCK 
Linux en un disco (Compartido por NFS, etc ) y quieres construirlo en algún
lugar más:

	/disks/raid/archive/os/rock# mkdir -p /disks/fast/rock
	/disks/raid/archive/os/rock# ./scripts/Create-Links /disks/fast/rock

2.4.3. ./scripts/Create-PkgList
-------------------------------

Crea una lista de todos los paquetes disponibles. Si se le pasa el nombre de
una arquitectura como parámetro, sólo los paquetes disponibles sobre esa
arquitectura seán listados.

Es script es usado por ./scripts/Config durante el proceso de creacción de
los ficheros de paquetes.

2.4.4. ./scripts/Create-PkgQueue
--------------------------------

Crea una lista de paquetes que podrían ser los siguientes a compilar. El 
primer parámetro es el número máximo de paquetes a imprimir (0=sin límite) y
el segundo parámetro es el directorio raiz dónde el script puede encontrar la
información de /var/adm/... que necesita. Por ejemplo:

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
(Cuando haces algún cambio a los fuentes de ROCK Linux y quieres compartir tu
trabajo).

Por ejemplo: ./scripts/Create-Diff ../rock-src.orig . > mychanges.diff

2.4.7. ./scripts/Create-CkSumPatch
----------------------------------

Script que puede ser usado por los desarrolladores de ROCK Linux para crear de
forma automática los checksums de las descargas en los ficheros .desc en uno
o más contenedores de paquetes.

Por ejemplo: ./scripts/Create-CkSumPatch extra2 ; patch -p1 < cksum.patch

2.4.8. ./scripts/Create-DescPatch
---------------------------------

Este script puede ser usado por los desarrolladores de ROCK Linux para que de
forma automática adopten el formato del paquete los ficheros .desc.

2.4.9. ./scripts/Create-PkgUpdPatch
-----------------------------------

Script que permite a los desarrolladores de ROCK Linux crear automáticamente
parches de actualización de paquetes (después de evaluar la salida del script
./scripts/Check-PkgVersion). Por ejemplo:

 	./scripts/Create-PkgUpdPatch > update.patch << EOT
		automake-1.6.1, bin86-0.16.3, bison-1.35, curl-7.9.6,
		diffutils-2.8.1, dump-0.4b28, ifhp-3.5.7, net-snmp-4.2.4,
		ntp-4.1.1, pciutils-2.1.10, sendmail.8.12.3, silo-1.2.5,
		tree-1.4b2, util-linux-2.11q, whois_4.5.25
	EOT

El fichero .patch de actualización resultante debería de ser chequeado 
manualmente antes de ser aplicado con 'patch -1 < update.patch'.

2.4.10. ./scripts/Create-ErrList
--------------------------------

Muestra una salida con la lista de paquetes que fallaron al compilarse 
(incluyendo los números de stage). en el orden correcto.

2.4.11. ./scripts/Create-UpdList
--------------------------------

Crea la lista de paquetes que están activos en la configuración actual y han
cambiado desde que los binarios instalados en el sistema han sido generados.
La comparación es realizada usando los checksum del paquete fuente almacenados
en /var/adm/packages/<nombre-de-paquete>.

2.4.12. ./scripts/Update-System
-------------------------------

Actualiza (recompila) todos los paquetes en el sistema local para los cuales
hay disponible alguna nueva versión. Create-UpList es usado para generar la
lista de paquetes que necesitan ser actualizados.

2.4.13. ./scripts/Puzzle
------------------------

Algunos ficheros en el árbol de fuentes son creados automáticamente. Este 
script los regenera todos, y debería de ser llamado cada vez que uno de los 
ficheros de los fuentes haya cambiado.

 2.4.14. ./scripts/Help
----------------------

Este script espera el nombre de fichero de un script en ./scripts/ y salta a
la posición correcta en la documentación. Es una sencilla envoltura para 
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
nuevas versiones de paquetes. Los resultados de la última ejecución son 
siempre almacenados en un directorio llamado checkver/ y si hay alguna 
diferencia en la ejecución actual, un fichero *.msg será escrito en checkver/.
(lee el script para más detalles)

Por ejemplo: ./scripts/Check-PkgVersion -repository base
	      for x in checkver/*.new ; do mv -f $x ${x%.new}.txt ; done
	      cat checkver/*.msg > todo.txt

Nota: Los ficheros .mgs viejos serán automáticamente borrados cuando corras
Check-PkgVersion la próxima vez.

2.5.2. ./scripts/Check-PkgFormat
--------------------------------

Este script hace unos pocos testeos sencillos para autodetectar errores en los
ficheros *.desc y *.conf de los paquetes.

Por ejemplo: ./scripts/Check-PkgFormat -repository extra1

2.5.3. ./scripts/Check-System
-----------------------------

Este script hace uns simple test para autodetectar posibles errores con el 
sistema de la máquina linux.

2.5.4. ./scripts/Check-Deps
---------------------------

Este comando chequea si el orden del paquete de la compilación actual es 
correcto para pasar todas las dependencias de paquetes.

2.6. Scripts for updating the source tree
=========================================

2.6.1. ./scripts/Update-Src
---------------------------

Actualiza el árbol de fuentes con rsync desde www.rocklinx.org.
Cuidado: Esto borrará los cambios que realizaras en el árbol de fuentes.

	
	3. Configuration System
	=======================


3.1. Fundamentos
================

El script de configuración ./sripts/Config genera los ficheros en el 
directorio /config/${config}/:

	config		las opciones de configuración
	packages	los paquetes que son compilados en esa configuración

./scripts/Config define algunas funciones de shell especiales y contiene el
bucle principal del programa de configuración. La estructura de los menús de
configuración es almacenada en scripts/config.in (y otros ficheros config.in
incluidos por el). Echa un vistazo a scripts/config.in para más información 
sobre qué ficheros incluyen a qué otros.

3.2. Comandos especiales
========================

Cada vez que el menú es mostrado (por ejemplo, después de arrancar ./scripts/
Config y cada vez que se realiza algún cambio), scripts/config.in es ejecutado
y está usando sus propios comandos especiales para escribir el fichero de 
configuración y añadir items al menú.

3.2.1. comment 'Descripción' ["Ayuda"]
-------------------------------------

Añade un comentario al menú de configuración (y lo hace sin ninguna función).
Por ejemplo:

	comment '-Arquitectura, CPU y Optimización' " 
	Selecciona que optimización de CPU se corresponde con tu máquina."

<Descripción>	Título del item en el menu de configuración (texto del 
		comentario).

<Ayuda>		Este es un campo opcional donde puedes añadir un comentario
		más largo que será mostrado cuando selecciones esta línea de
		comentario y pulses sobre el botón de ayuda.

3.2.2. comment_id 'Descripción' 'ID' ["Ayuda"]
---------------------------------------------

Añade un comentario al menú de configuración (y lo hace sin ninguna función).
Por ejemplo:

	comment '-Arquitectura, CPU y Optimización' COMMENT_ARCH_CPU_OPT "
	Selecciona que optimización de CPU se corresponde con tu máquina."

<Descripción>	Título del item en el menu de configuración (texto del 
		comentario).

<ID>		Identificativo que será usado para identificar un comentario.
		Es útil cuando usas ficheros config.hlp para almacenar la
		ayuda.

<Ayuda>		Este es un campo opcional donde puedes añadir un comentario
		más largo que será mostrado cuando selecciones esta línea de
		comentario y pulses sobre el botón de ayuda.

3.2.3. bool 'Descripción' Variable Valor_Defecto ["Ayuda"]
---------------------------------------------------

Añade un item booleano (on/off) al menú. Por ejempo:

	bool 'Abortar cuando la compilación de un paquete falle' 
	ROCKCFG_ABORT_ON_ERROR 1 "
	Cuándo selecciones ésta opción, Build-Target abortará cuando un paqute
	falle al compilar"

<Descripción>	Título del item en el menú de configuración
<Variable>	Nombre de la variable de configuración asociada a éste item
		del menú
<Valor_Defecto>	'1' = On, '0' = Off
<Ayuda>		Este es un campo opcional donde puedes añadir un comentario
		más largo que será mostrado cuando selecciones esta línea de
		comentario y pulses sobre el botón de ayuda

La variable estará activada a '1' o a '0'.

3.2.4. text 'Descripción' Variable Valor_Defecto ["Help"]
---------------------------------------------------

Añade un item de texto en el menú. Si el texto debe de coincidir con un patrón
especial, modifica la variable de configuración antes de hacer la llamada a la
función text. Por ejemplo:

	ROCKCFG_MAKE_JOBS="`echo $ROCKCFG_MAKE_JOBS | sed 's,[^0-9],,g'`"
	text 'Número de procesos make paralelos (make -j)' ROCKCFG_MAKE_JOBS 1
 
<Descripción>	Título del item en el menú de configuración
<Variable>	Nombre de la variable de configuración asociada a éste item
		del menú
<Valor_Defecto>	Valor por defecto
<Ayuda>		Este es un campo opcional donde puedes añadir un comentario
		más largo que será mostrado cuando selecciones esta línea de
		comentario y pulses sobre el botón de ayuda

3.2.5. choice Variable Valor_Defecto Valor1 'Descripción1' [ ... ]
------------------------------------------------------------------

Añade un item al menú de múltiples opciones. Por ejemplo:

	choice ROCKCFG_INTEL_OPT generic   \
		generic "Sin optimización especial"          \
		i386    "Optimizado para Intel 386"          \
		i486    "Optimizado para Intel 486"          \
		i586    "Optimizado para Intel Pentium"      \
		i686    "Optimizado para Intel Pentium-Pro"  \
		k6      "Optimizado para AMD K-6"            \
		k7      "Optimizado para AMD Athlon"

<Variable>	Nombre de la variable de configuración asociada a éste item
		del menú
<Valor_Defecto>	Valor por defecto

<ValorN>	Valor para la opción N
<DescripciónN>	Título del item en el menú de configuración si la opción N
		está activa

3.2.6. const Variable Valor_Defecto
-----------------------------------

Asigna la variable con el valor por defecto dado sin mostrar ningún item en
el menú.

3.2.7. block_begin y block_end
------------------------------

Un conjunto de items de menú, los cuales permanecen juntos, deben estar entre
block_begin y block_end. block_begin espera un parámetro numérico que 
especifica el número de carácteres que el título del item del menú deberá ser
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

Las opciones que sólo deberían de ser mostradas si el 'modo experto' está
activo, deben ir entre expert_begin y expert_end.


3.3. Variables especiales
=========================

3.3.1. ROCKCFG_*
----------------

Todas las variables de configuración deberían de empezar con "ROCKCFG_". Las
variables que no son principales tienen prefijos de extensión:

Arquitecturas:	ROCKCFG_ARCH_<Nombre-Arquitectura>_*
Targets:	ROCKCFG_TRG_<Nombre-Target>_*
Paquetes:	ROCKCFG_PKG_<Nombre-Paquete>_*

Algunas variables son manejadas por ./scripts/Config de una manera especial:

ROCKCFG_ID	Es la descripción corta de la configuración. Las opciones 
		de configuración importantes deberían de añadir algo a ésta
		variable.

ROCKCFG_EXPERT	Si ésta puesta a '0', los items entre expert_begin y 
		expert_end no serán mostrados y los valores por defecto para 
		esas opciones serán usados.

3.3.2. ROCKCFGSET_*
-------------------

Las variables ROCKCFGSET_* pueden ser usadas para preservar una opción (por
ejemplo, en un target). Si por ejemplo, ROCKCFGSET_STRIP está puesta a 1,
ROCKCFG_STRIP tendrá el valor 1 y el usuario no podrá cambiar su valor.

3.3.3. CFGTEMP_*
----------------

Estas variables pueden ser usadas para intercambio de datos entre los 
distintos ficheros config.in. Las variables no principales tienen prefijos de
extensión:

Arquitecturas:	ROCKCFG_ARCH_<Nombre-Arquitectura>_*
Targets:	ROCKCFG_TRG_<Nombre-Target>_*
Paquetes:	ROCKCFG_PKG_<Nombre-Paquete>_*

Por ejemplo, la creacción dinámica de una opción de múltiples elecciones:

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

Sólo los scripts marcados con '*' podrán interactuar con el usuario (creando
items del menú). El resto podrá sólo activar y modificar distintas variables.

3.5. Creacción del fichero Packages
===================================

EL script ./scripts/Config crea un fichero de paquetes con todos los paquetes
disponibles para la arquitectura seleccionada antes de llamar a 
scripts/config.in. Cada fichero config.in podrá ahora modificar este fichero
Packages creando un fichero Packages.new y renombrándolo a Packages. Por 
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

X/O	'X' = el paquete está activo,	'O' = el paquete no está activo
	Si no quieres que otro config.in reactive un paquete, podrás también,
	símplemente borrar la línea del fichero.

Stages	Niveles de stage igual que los especificados en la marca [P] de los 
	paquetes (ver el próximo capítulo)

Pri.	Prioridad especificada igual que en el tag [P] de los paquetes (atajo
	para el fichero)

Resp.	Nombre del contenedor dónde se encuentra el paquete

Name	Nombre del paquete

Ver.	Versión del paquete

Prefix	Prefijo del paquete (seguido de '/')

Cat.	Categorías del paquete (siempre en minúsculas, conteniendo al menos
	un /)

Flags	Banderas del paquete (siempre mayúsculas)

Counter	Símplemente ignora éste fichero

Cómo el campo 'counter', las categorías u las banderas son siempre seguidas y
precedidas de un ' ', puedes de forma sencilla borrar todos los paquetes menos
dietlibc-ready con un comando como:

	grep ' DIETLIBC ' < config/$config/packages \
				> config/$config/packages.new

Leete los ficheros config.in que hay para más detalles.


	4. Paquetes
	===========

4.1. Fundamentos
================

Cada paquete tiene su propio subdirectorio en package/<contenedor>/. Los
contenedores son unidades organizativas que agrupan paquetes. Cada contenedor
pertenece a un desarrollador de ROCK Linux o a un grupo de desarrolladores.

El nombre del paquete es de 2 a 25 carácteres de largo y debe coincidir con
la expresión regular:

	/^[a-z0-9][a-z0-9\.\+_-]*[a-z0-9\+]$/

(Con un mínimo de 2 carácteres. El primero: letra en minúscula o número. El
último: letra en minúscula o número o '+'. El resto: letras en minúscula,
números o uno de los siguientes carácteres: '.', '+', '_' o '-'.)

Un nombre de paquete no debe aparecer en más de un contenedor.

Otros subdirectorios (que no sean de paquetes) están permitidos, si no empiezan
con una letra minúscula o un número (así por ejemplo, los directorios "CVS"
están permitidos) y que no contenga algún fichero *.desc.

Este directorio de paquete contiene toda la información necesaria para 
descargar y compilar un paquete.

4.2. Los ficheros *.desc
========================

Cada paquete DEBE tener un fichero <nombre_de_paquete>.desc. Este contiene toda
la metainformación del paquete. Echa un vistazo al fichero PKG-DESC-FORMAT para
una descripción de las etiquetas disponibles.

4.2.1. Prioridad de paquetes
----------------------------

La etiqueta [P] es usada para indicar la prioridad del paquete. Esta etiqueta
tiene 3 campos:

	[P] X --3-----9 010.066

El primer campo ('X' o 'O') especifica si el paquete debería de ser construido
por defecto o no. Este valor suele valer 'X' en casi todos los paquetes. Esta
bandera podrá ser sobreescrita por la configuración (capítulo 3).

El segundo campo lista los stages en los cuales el paquete debería de ser 
compilado. Hay 10 stages (0-9). Build-Target empezará con la compilación en el
stage 1, después stage 2, etc... El stage 9 sólo es construido si se activa en 
la configuración 'Make rebuild stage (stage 9)'. Los stages 0 y 1 son stages
para la compilación cruzada, y deberían sólo de contener paquetes que soporten
este tipo de compilación. De esta forma los stages pueden ser usados para 
indicar el orden de compilación (por ejemplo, el stage 3 se construye antes que
el stage 5) y para reconstruir un paquete varias veces.

El tercer campo es usado para especificar el orden de compilación junto con los
stages. Este es un ordenado por texto simplemente.

4.2.2. URLs de descarga
-----------------------

Generalmente un paquete debe descargar uno o más ficheros de fuentes. Estos
ficheros son descargados usando el script ./scripts/Download y se almacenan en
el directorio 'download/<nombre-de-repositorio>/<nombre-de-paquete>/'.

Cada fichero que pueda ser descargado tiene su própia etiqueta [D] en el 
fichero *.desc del paquete. La etiqueta [D] tiene 3 campos:

	[D] 354985877 gcc-2.95.3.tar.gz ftp://ftp.gnu.org/pub/gnu/gcc/

El primer campo es el checksum para el fichero. Esos checksums son creados con
por ejemplo:

	./scripts/Download -mk-cksum download/base/gcc2/gcc-2.95.3.tar.bz2

Si el checksum es '0', significa que no ha sido creado un checksum. El script
'./scripts/Create-CkSumPatch'puede ser usado para crear un parche que añada
esos checksums.

Para los que no tengan checksum, por alguna u otra razón (por ejemplo, por que
el contenido del sitio original esta cambiando con frecuencia), una cadena 
consistente de sólamente carácteres 'X' puede ser usada. Por ejemplo:

	[D] XXXXXXXXXX RFCs3001-latest.tar.gz ftp://ftp.rfc-editor.org/in-notes/tar/
	
El segundo campo es el nombre del fichero. Los ficheros con el sufijo *.gz o 
*.tgz son automáticamente convertidos a *.bz2 o *.tbz2 por el script ./scripts/
Download.

El tercer parámetro es la URL de descarga sin la parte correspondiente al 
nombre del fichero. Si el nombre del fichero local difiere del remoto, la URL
debería de ser antecedido por un carácter '!'. Por ejemplo:

	[D] 2447691734 services.txt !http://www.graffiti.com/services

El script ./scripts/Check-PkgVersion también usa esta etiqueta [D] para buscar
por nuevas versiones del paquete. El script './scripts/Check-PkgVersion' puede
también ser directamente configurado usando las etiquetas [CV-URL], [CV-PAT] y
[CV-DEL].

4.3. Los ficheros *.conf
========================

./scripts/Build-Pkg tienen un código semi-inteligente para compilar e instalar
un paquete. Esto lo hace la función de shell build_this_package(), la cual
puede se encontrada en ./scripts/Build-Pkg. Este scripts se configura usando
varias variables que pueden ser activadas o modificadas en el fichero *.conf.
Una lista de esas variables puede ser encontrada en el fichero PKG-BUILD-VARS
en este directorio. Lee los ficheros *.conf para ver ejemplos.

4.3.1. FIXME
------------

4.4. Los ficheros *.patch
=========================

Todos los ficheros *.patch en el directorio de paquetes son automáticamente 
aplicados despues de que el fichero tar de los fuentes del paquete sea 
extraido. El parche *.patch.<arquitectura> sólo se aplica cuando se compila
para la arquitectura indicada.

4.5. Los ficheros *.doc
=======================

Todos los ficheros *.doc en el directorio de paquetes son automáticamente 
compiados al directorio de documentación del paquete (por ejemplo /usr/share/
/doc/$pkg) sin el sufijo ".doc".

4.6. Los ficheros *.init
========================

Los scripts de inicialización son isntalados usando la función install_init.
Esta función convierte un fichero *.init en un script de inicio estilo SysV.
Echale un vistazo a

	package/base/devfsd/devfsd.conf y
	package/base/devfsd/devfsd.init
o
	package/base/sysklogd/sysklogd.conf   y
	package/base/sysklogd/sysklogd.init

para pequeños ejemplos. La conversión desde los ficheros *.init a scripts de
inicio SysV es realizada usando m4 y el fichero de macros 'package/base/
/sysvinit/init_macros.m4'.

	5. Targets
	==========

 POR REALIZAR


	6. Arquitecturas
	================

 POR REALIZAR