

		Compilando ROCK Linux sobre un cluster
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	1. Cosas básicas
	================

Asumiremos que has leido el fichero BUILD y que sabes como realizar una 
compilación 'normal' de ROCK Linux. También asumiremos que sabes como usar un
cluster en linux (si estas leyendo esto, tendrás uno). Ahora voi a explicar como
compilar ROCK Linux sobre un cluster. Las técnicas aquí descritas pueden también
ser utilizadas para compilar ROCK Linux sobre una máquina SMP para obtener el
mejor rendimiento de todas las CPUs.

ROCK Linux puede ser compilado sobre un cluster simple de estaciones de trabajo
conectadas por medio de una LAN normal (ethernet, etc). No es necessaria una
baja latencia o un gran ancho de banda en la red para construir ROCK Linux en
un cluster con buen rendimiento.

ROCK Linux tiene su propio programador (scheduler) para distribuir trabajos 
sobre los nodos del cluster. Pero puedes usar cualquier programador de trabajos
que tengas actualmente instalado en tu cluster para hacer realizar esta tarea.

Cuando se compila ROCK Linux en modo paralelo (cluster), los scripts de 
compilación deciden basandose en las dependencias entre paquetes, que paquetes
deberán de ser compilados en paralelo y lo hara en paralelo (en lugar de hacerlo
en serie, que es el comportamiento por defecto).

Para construir ROCK Linux tienes que ser siempre administrador. Esto no cambia
cuando estas compilandolo sobre un cluster. La opción 'Abort when a 
package-build fails' no esta disponible al realizar una compilación en paralelo
(cluster).


	2. La ley de Amdahl
	===================

En un famoso escrito Amdahl observó que hay que considerar una aplicación entera
cuando se considera el nivel de paralelismo disponible. Si un único 1% del 
paralelismo de un proceso falla, entonces no importa el paralelismo disponible 
para el resto, el problema nunca podrá ser resuelto mucho más rápido que unas 100
veces de si se tratara de modo secuencial.

Cada paquete en ROCK Linux depende de al menos unos pocos paquetes básicos como 
la librería estándar de C, el compilador de C o la shell. Así que no será posible
hacer uso de la potencia del cluster durante las primeras fases de la compilación
, durante las cuales se crearán esos paquetes básicos. Más tarde, durante la 
compilación, habrá siempre algunos paquetes que podrán ser compilados en
paralelo (es común que sean unos 100 paquetes, después de que los básicos hayan
sido construidos).

La herramienta './scripts/Create-ParaSim' puede ser usada para simular una 
compilación en paralelo. Sólo configura tu compilación y entonces ejecuta
'./scripts/Create-ParaSim'. La salida es un gráfico que muestra cuántos trabajos 
en paralelo hay disponibles para la compilación y en que fase de la misma. Es 
algo como esto:

  ----+----------------------------------------------------------------------+
  181 |                                     ::::.                            |
      |                                   .:::::::.                          |
    P |                              .::::::::::::::                         |
    a |                             .::::::::::::::::.                       |
    r |                           :::::::::::::::::::::.                     |
    a |                        ..::::::::::::::::::::::::.                   |
    l |              .  ..  ...::::::::::::::::::::::::::::                  |
    l |             ::::::::::::::::::::::::::::::::::::::::.                |
    e |             ::::::::::::::::::::::::::::::::::::::::::.              |
    l |             ::::::::::::::::::::::::::::::::::::::::::::.            |
      |            .::::::::::::::::::::::::::::::::::::::::::::::           |
    J |            ::::::::::::::::::::::::::::::::::::::::::::::::.         |
    o |            ::::::::::::::::::::::::::::::::::::::::::::::::::.       |
    b |            ::::::::::::::::::::::::::::::::::::::::::::::::::::.     |
    s |          ::::::::::::::::::::::::::::::::::::::::::::::::::::::::.   |
      |       :.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.  |
    1 |...::..::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.|
  ----+----------------------------------------------------------------------+
      | 1                  Number of Jobs build so far                   424 |

El gráfico muestra en el eje vertical el número de trabajos ejecutándose en
paralelo, y en su eje horizontal el número de paquetes construidos.

Como se puede ver durante las primeras fases de la compilación, no se logra un
paralelismo muy óptimo, pero pronto alcanza un estado donde cerca de 100 
trabajos(compilaciones de paquetes) pueden ser realizados al mismo tiempo.

Que disminuya el número de procesos ejecutados en paralelo en el lado derecho
del gráfico es normal. Por ejemplo, cuando se han compilado 400 de 424 
paquetes, sólo quedan 24 paquetes por compilar, con lo que es imposible tener
100 trabajos ejecutándose en paralelo.

Ten en cuenta que el eje de las X es el número de paquetes compilados, y no el
tiempo. Por lo que el gráfico muestra información acerca del nivel de 
paralelismo que es posible alcanzar con tu configuración en general, pero no
provee números exactos de cuanto más rápido sería por ejemplo en un cluster de
16 nodos.

Puedes pasar la opción '-jobs N' al script './scripts/Create-ParaSim' para 
obtener una simulación de la compilación en un cluster de N nodos. El script
asume que los nodos del cluster son tan rápidos como el sistema que ha hecho
la compilación de referencia. Si los nodos de tu cluster son, por ejemplo, un
20% más rápidos, la compilación será completada un 20% más rápido de lo que
indica el status. Puedes incluso comparar compilaciones - por ejemplo "-jobs 
1,2,8" compararía una compilación en un nodo simple normal con una en un 
cluster de 2 nodos y una en uno de 8 nodos:

  -----+--------------------------------------------------------------------+
     8 |     :    :::                                                       |
       |     :.  ::::.                                                      |
       |   ..::  :::::                                                      |
       |   ::::..:::::.                                                     |
     1 |::::::::::::::::::                                                  |
  -----+--------------------------------------------------------------------+
     2 |    ::::::::::::::::::::::::::::::::                                |
       |  ::::::::::::::::::::::::::::::::::                                |
       |.:::::::::::::::::::::::::::::::::::                                |
       |::::::::::::::::::::::::::::::::::::                                |
     1 |::::::::::::::::::::::::::::::::::::                                |
  -----+--------------------------------------------------------------------+
     1 |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::|
       |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::|
       |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::|
       |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::|
     1 |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::|
  -----+--------------------------------------------------------------------+
  Jobs | 00:00                       Time                             14:41 |

Si tienes instalado 'gnuplot' y activa $DISPLAY, puedes también pasar la 
opción '-x11' a './scripts/Create-ParaSim', de esta forma usará el programa
'gnuplot' para mostrar los resultados. Una captura de pantalla del modo 
'-x11' de './scripts/Create-ParaSim' puede encontrarse en 
http://www.rocklinux.org/pics/screenshot_parasim.jpg.


	3.Preparando el maestro
	=======================

Estrae los fuentes de ROCK Linux en algún lugar y exporta éste directorio 
como lectura y escritura a todos los nodos usando NFS. En muchos casos 
habrá listo un directorio en tu cluster que es compartido entre todos los 
nodos (por ejemplo /home). Asumiré el directorio /home/rock-master en este
documento.

Configura tu compilación de forma normal. Activa la opción en la
configuración 'Make a parallel (cluster) build'. La opción 'Maximun size
of job queue' debería de tener un valor tan alto como el máximo número de 
trabajos que serán compilados en el cluster. Pon esta opción a '0'
(ilimitado) cuando compiles en un cluster grande.

La opción 'Command for adding jobs' será explicada en la sección 6 
(compilando con un programador de trabajos externo) y puede ser dejada en 
blanco si estás usando el programador de trabajos incluido.

También podría ser que quieras activar la opción 'Always clean up src dirs
(even on pjg fail)' para que los discos locales de los nodos de tu cluster no
se llenen con los directorios de fuentes de los paquetes fallidos.

Descarga los fuentes requeridos de forma normal (si no los tienes descargados 
aún).


	4.Preparando los nodos
	======================

Los pasos siguientes han de ser realizados en cada nodo. Si posees varios en
tu cluster podrías querer usar 'prsh' (http://www.cacr.caltech.edu/beowulf/)
para realizarlos en todos los nodos.

Necesitas crear un directorio local para la compilación en cada nodo del 
cluster (compilar los paquetes a través de un recurso NFS podría disminuir
bastante el rendimiento). En algunos casos habrá ya un directorio para esto 
(por ejemplo /scratch). Asumiré que el directorio es /scratch/rock-node en 
este documento.

Prepara el directorio /scratch/rock-node usando los comandos:

	# mkdir -p /scratch/rock-node
	# cd /home/rock-master
	# ./scripts/Create-Links -config -build /scratch/rock-node

Ahora tu cluster está listo para compilar ROCK Linux.

	
	5. Compilando con el programador de trabajos incluido
	=====================================================

Ejecuta './scripts/Build-Target' en el directorio /home/rock-master del
maestro. En lugar de compilar los paquetes, el maestro creará una cola de
trabajos y añadirá esos paquetes a la cola, que podrá ser compilada después.

Ejecuta './scripts/Build-Job -daemon' en el directorio /scratch/rock-node de
los nodos. Nuevamente, quizás quieras usar 'prsh' para hacerlo en todos los
nodos. Si deseas compilar múltiples paquetes en paralelo en un nodo del 
cluster (por ejemplo por que tiene 2 CPUs), necesitas ejcutar 
'./scripts/Build-Job -daemon' tantas veces como procesos quieras correr en
el mismo nodo a la vez.

"Build-Target", ejecutado en el maestro te mostrará que esta haciendo. 
Puedes ver el estado actual de tu compilación en cada consola con la 
herramienta './scripts/Create-ParaStatus'. La salida del scripts es similar
a esta:

   18:41 2002-05-08:   --- current status ---
   Build-Job (daemon mode)       running on node01 with PID 18452
   Build-Job (daemon mode)       running on node02 with PID 18665
   Build-Job (daemon mode)       running on node03 with PID 19618
   Job 3-kdenetwork              node02 (18665) since 18:32 2002-5-08
   Job 3-kdeutils                node03 (19618) since 18:41 2002-5-08
   Job 3-kdevelop                node01 (18452) since 18:30 2002-5-08
   Job 3-kdebindings             waiting in the job queue (priority 2)
   Job 3-kdeadmin                waiting in the job queue (priority 1)
   Job 3-kde-i18n-fr             waiting in the job queue (priority 1)
   Job 3-kde-i18n-es             waiting in the job queue (priority 1)
   Job 3-kde-i18n-de             waiting in the job queue (priority 1)
   Job 3-kdeartwork              waiting in the job queue (priority 0)
   Job 3-kdeaddons               waiting in the job queue (priority 0)
   18:41 2002-05-08:   ----------------------

"Build-Job -daemon", ejecutado en los nodos, se clona en segundo plano y sólo
imprime una linea de mensaje conteniendo el nombre del fichero del log que
contiene la salida del script. Este log esta en el directorio build/, el cual
es compartido entre todos los nodos por lo que puedes ver todos los logs desde
el nodo maestro.


	6. Compilando con un programador externo
	========================================

Digamos que el comando para añadir trabajos en tu programador de trabajos es
'addjob', y que sólo tiene un parámetro, el comando a ejecutar. Deberías de
activar la opción de configuración 'Command for adding jobs' al valor


	addjob 'cd /scratch/rock-node ; {}'

Los carácteres {} serán automáticamente reemplazados por la invocación de 
Build-Job para el paquete en compilación, y siempre tiene la forma:

	./scripts/Build-Job -cfg <config-name> <stagelevel>-<package-name>

Así que si quieres añadir algo de inteligencia al programador de trabajos (por
ejemplo compilar paquetes largos en un nodo más rápido) puedes pasar {} a otro
script, estando el nombre del comando en $*, el nombre de la configuración en
$3 y el nivel del stage y el nombre de paquete en $4.

Si no pueden ser ejecutados todos los trabajos, el programador de trabajos 
debería de escoger los paquetes que hayan sido requeridos primero, esto es
importante para asegurarse que siempre sea posible que múltiples paquetes 
puedan ser compilados en paralelos.

Ten en cuenta que './scripts/Build-Job -daemon' no funciona si la opción de 
configuración 'Command for adding jobs' está activa. El script
'./scripts/Create-ParaStatus' funcinará de forma normal.


