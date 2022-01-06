

		Compilando ROCK Linux sobre un cluster
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	1. Cosas b�sicas
	================

Asumiremos que has leido el fichero BUILD y que sabes como realizar una 
compilaci�n 'normal' de ROCK Linux. Tambi�n asumiremos que sabes como usar un
cluster en linux (si estas leyendo esto, tendr�s uno). Ahora voi a explicar como
compilar ROCK Linux sobre un cluster. Las t�cnicas aqu� descritas pueden tambi�n
ser utilizadas para compilar ROCK Linux sobre una m�quina SMP para obtener el
mejor rendimiento de todas las CPUs.

ROCK Linux puede ser compilado sobre un cluster simple de estaciones de trabajo
conectadas por medio de una LAN normal (ethernet, etc). No es necessaria una
baja latencia o un gran ancho de banda en la red para construir ROCK Linux en
un cluster con buen rendimiento.

ROCK Linux tiene su propio programador (scheduler) para distribuir trabajos 
sobre los nodos del cluster. Pero puedes usar cualquier programador de trabajos
que tengas actualmente instalado en tu cluster para hacer realizar esta tarea.

Cuando se compila ROCK Linux en modo paralelo (cluster), los scripts de 
compilaci�n deciden basandose en las dependencias entre paquetes, que paquetes
deber�n de ser compilados en paralelo y lo hara en paralelo (en lugar de hacerlo
en serie, que es el comportamiento por defecto).

Para construir ROCK Linux tienes que ser siempre administrador. Esto no cambia
cuando estas compilandolo sobre un cluster. La opci�n 'Abort when a 
package-build fails' no esta disponible al realizar una compilaci�n en paralelo
(cluster).


	2. La ley de Amdahl
	===================

En un famoso escrito Amdahl observ� que hay que considerar una aplicaci�n entera
cuando se considera el nivel de paralelismo disponible. Si un �nico 1% del 
paralelismo de un proceso falla, entonces no importa el paralelismo disponible 
para el resto, el problema nunca podr� ser resuelto mucho m�s r�pido que unas 100
veces de si se tratara de modo secuencial.

Cada paquete en ROCK Linux depende de al menos unos pocos paquetes b�sicos como 
la librer�a est�ndar de C, el compilador de C o la shell. As� que no ser� posible
hacer uso de la potencia del cluster durante las primeras fases de la compilaci�n
, durante las cuales se crear�n esos paquetes b�sicos. M�s tarde, durante la 
compilaci�n, habr� siempre algunos paquetes que podr�n ser compilados en
paralelo (es com�n que sean unos 100 paquetes, despu�s de que los b�sicos hayan
sido construidos).

La herramienta './scripts/Create-ParaSim' puede ser usada para simular una 
compilaci�n en paralelo. S�lo configura tu compilaci�n y entonces ejecuta
'./scripts/Create-ParaSim'. La salida es un gr�fico que muestra cu�ntos trabajos 
en paralelo hay disponibles para la compilaci�n y en que fase de la misma. Es 
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

El gr�fico muestra en el eje vertical el n�mero de trabajos ejecut�ndose en
paralelo, y en su eje horizontal el n�mero de paquetes construidos.

Como se puede ver durante las primeras fases de la compilaci�n, no se logra un
paralelismo muy �ptimo, pero pronto alcanza un estado donde cerca de 100 
trabajos(compilaciones de paquetes) pueden ser realizados al mismo tiempo.

Que disminuya el n�mero de procesos ejecutados en paralelo en el lado derecho
del gr�fico es normal. Por ejemplo, cuando se han compilado 400 de 424 
paquetes, s�lo quedan 24 paquetes por compilar, con lo que es imposible tener
100 trabajos ejecut�ndose en paralelo.

Ten en cuenta que el eje de las X es el n�mero de paquetes compilados, y no el
tiempo. Por lo que el gr�fico muestra informaci�n acerca del nivel de 
paralelismo que es posible alcanzar con tu configuraci�n en general, pero no
provee n�meros exactos de cuanto m�s r�pido ser�a por ejemplo en un cluster de
16 nodos.

Puedes pasar la opci�n '-jobs N' al script './scripts/Create-ParaSim' para 
obtener una simulaci�n de la compilaci�n en un cluster de N nodos. El script
asume que los nodos del cluster son tan r�pidos como el sistema que ha hecho
la compilaci�n de referencia. Si los nodos de tu cluster son, por ejemplo, un
20% m�s r�pidos, la compilaci�n ser� completada un 20% m�s r�pido de lo que
indica el status. Puedes incluso comparar compilaciones - por ejemplo "-jobs 
1,2,8" comparar�a una compilaci�n en un nodo simple normal con una en un 
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

Si tienes instalado 'gnuplot' y activa $DISPLAY, puedes tambi�n pasar la 
opci�n '-x11' a './scripts/Create-ParaSim', de esta forma usar� el programa
'gnuplot' para mostrar los resultados. Una captura de pantalla del modo 
'-x11' de './scripts/Create-ParaSim' puede encontrarse en 
http://www.rocklinux.org/pics/screenshot_parasim.jpg.


	3.Preparando el maestro
	=======================

Estrae los fuentes de ROCK Linux en alg�n lugar y exporta �ste directorio 
como lectura y escritura a todos los nodos usando NFS. En muchos casos 
habr� listo un directorio en tu cluster que es compartido entre todos los 
nodos (por ejemplo /home). Asumir� el directorio /home/rock-master en este
documento.

Configura tu compilaci�n de forma normal. Activa la opci�n en la
configuraci�n 'Make a parallel (cluster) build'. La opci�n 'Maximun size
of job queue' deber�a de tener un valor tan alto como el m�ximo n�mero de 
trabajos que ser�n compilados en el cluster. Pon esta opci�n a '0'
(ilimitado) cuando compiles en un cluster grande.

La opci�n 'Command for adding jobs' ser� explicada en la secci�n 6 
(compilando con un programador de trabajos externo) y puede ser dejada en 
blanco si est�s usando el programador de trabajos incluido.

Tambi�n podr�a ser que quieras activar la opci�n 'Always clean up src dirs
(even on pjg fail)' para que los discos locales de los nodos de tu cluster no
se llenen con los directorios de fuentes de los paquetes fallidos.

Descarga los fuentes requeridos de forma normal (si no los tienes descargados 
a�n).


	4.Preparando los nodos
	======================

Los pasos siguientes han de ser realizados en cada nodo. Si posees varios en
tu cluster podr�as querer usar 'prsh' (http://www.cacr.caltech.edu/beowulf/)
para realizarlos en todos los nodos.

Necesitas crear un directorio local para la compilaci�n en cada nodo del 
cluster (compilar los paquetes a trav�s de un recurso NFS podr�a disminuir
bastante el rendimiento). En algunos casos habr� ya un directorio para esto 
(por ejemplo /scratch). Asumir� que el directorio es /scratch/rock-node en 
este documento.

Prepara el directorio /scratch/rock-node usando los comandos:

	# mkdir -p /scratch/rock-node
	# cd /home/rock-master
	# ./scripts/Create-Links -config -build /scratch/rock-node

Ahora tu cluster est� listo para compilar ROCK Linux.

	
	5. Compilando con el programador de trabajos incluido
	=====================================================

Ejecuta './scripts/Build-Target' en el directorio /home/rock-master del
maestro. En lugar de compilar los paquetes, el maestro crear� una cola de
trabajos y a�adir� esos paquetes a la cola, que podr� ser compilada despu�s.

Ejecuta './scripts/Build-Job -daemon' en el directorio /scratch/rock-node de
los nodos. Nuevamente, quiz�s quieras usar 'prsh' para hacerlo en todos los
nodos. Si deseas compilar m�ltiples paquetes en paralelo en un nodo del 
cluster (por ejemplo por que tiene 2 CPUs), necesitas ejcutar 
'./scripts/Build-Job -daemon' tantas veces como procesos quieras correr en
el mismo nodo a la vez.

"Build-Target", ejecutado en el maestro te mostrar� que esta haciendo. 
Puedes ver el estado actual de tu compilaci�n en cada consola con la 
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

"Build-Job -daemon", ejecutado en los nodos, se clona en segundo plano y s�lo
imprime una linea de mensaje conteniendo el nombre del fichero del log que
contiene la salida del script. Este log esta en el directorio build/, el cual
es compartido entre todos los nodos por lo que puedes ver todos los logs desde
el nodo maestro.


	6. Compilando con un programador externo
	========================================

Digamos que el comando para a�adir trabajos en tu programador de trabajos es
'addjob', y que s�lo tiene un par�metro, el comando a ejecutar. Deber�as de
activar la opci�n de configuraci�n 'Command for adding jobs' al valor


	addjob 'cd /scratch/rock-node ; {}'

Los car�cteres {} ser�n autom�ticamente reemplazados por la invocaci�n de 
Build-Job para el paquete en compilaci�n, y siempre tiene la forma:

	./scripts/Build-Job -cfg <config-name> <stagelevel>-<package-name>

As� que si quieres a�adir algo de inteligencia al programador de trabajos (por
ejemplo compilar paquetes largos en un nodo m�s r�pido) puedes pasar {} a otro
script, estando el nombre del comando en $*, el nombre de la configuraci�n en
$3 y el nivel del stage y el nombre de paquete en $4.

Si no pueden ser ejecutados todos los trabajos, el programador de trabajos 
deber�a de escoger los paquetes que hayan sido requeridos primero, esto es
importante para asegurarse que siempre sea posible que m�ltiples paquetes 
puedan ser compilados en paralelos.

Ten en cuenta que './scripts/Build-Job -daemon' no funciona si la opci�n de 
configuraci�n 'Command for adding jobs' est� activa. El script
'./scripts/Create-ParaStatus' funcinar� de forma normal.


