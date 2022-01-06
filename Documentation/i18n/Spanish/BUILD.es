			  Compilando ROCK Linux
			  ~~~~~~~~~~~~~~~~~~~~~


	1. Requerimientos
	=================

Para compilar ROCK Linux necesitas una buena conexi�n a internet para descargar
los fuentes, bastante espacio en disco, un ordenador r�pido y algo de tiempo.
Dependiento de la configuraci�n que escogas y de tu hardware, la compilaci�n de
ROCK Linux puede tomar algunos d�as hasta completarse. Tambi�n necesitas 
permisos de administrador para construir ROCK Linux.

La distribuci�n sobre la que compilas ROCK Linux deber�a de ser una ROCK Linux.
Tambi�n es posible compilar ROCK Linux sobre otra distribuci�n, pero no esperes
lograrlo sin algo de hacking ...


	2. Estrayendo los fuentes
	=========================

Descarga el c�digo fuente de ROCK Linux (un fichero tar.bz2 de unos pocos MB)
desde www.rocklinux.org y extr�elo en cualquier lugar como root. El director�o
obtenido es el directorio 'base' de ROCK Linux.


	3. Configura la compilaci�n
	===========================

Teclea './scripts/Config' y un men� de configuraci�n aparecer�. Escoge tu 
configuraci�n (o simplemente deja los valores por defecto sin tocar). Necesitas
arrancar la herramienta de configuraci�n incluso aunque no quieras cambiar
nada.

Es posible tener m�ltiples configuraciones. Usa el comando './scripts/Config 
-cfg nombre_config' (donde nombre_config puede ser cualquier texto que no 
contenga espacios en blanco ni car�cteres especiales). Si has escogido un nombre
para tu configuraci�n, necesitas pasar la opci�n '-cfg nombre_config' como 
primer par�metro tambi�n al resto de scripts - para que puedan saber que 
configuraci�n leer.

El nombre de configuraci�n por defecto (cuando no se pasa la opci�n -cfg) es
'default'. La configuraci�n es almacenada en el directorio 
'config/nombre_config'.


	4. Descargando los fuentes de los paquetes
	==========================================

Ahora necesitas descargar los fuentes para compilar los paquetes que escogiste
en la configuraci�n. S�lo escribe './scripts/Download -required'.
Si quieres descargar los fuentes para todos los paquetes (a pesar de que no sean
necesarios para tu configuraci�n), escribe './scripts/Download -all'.


	5. Compilando la distribuci�n
	=============================

Teclea './scripts/Build-Target'. Como se mencion� antes, esto puede tomar varios
d�as hasta completar la compilaci�n.

La distribuci�n resultante es almacenada en el directorio build/.


	6. Creando im�genes de CD
	=========================

Para crear una imagen de CD desde la que instalar, puedes usar 
'./scripts/Create-ISO'. Create-ISO toma al menos un argumento: el nombre de la
configuraci�n que compilaste (generalmente 'default' o cualquiera que escogieras
despu�s de la opci�n -cfg).

Opcionalmente puedes usar la opci�n -size <MB> para especificar el tama�o de 
tus discos CD-R.
Otro par�metro opcional es -mkdebug, el cual creara una configuraci�n WMWare 
para ser usada con la nueva imagen creada.

La imagen no ser�, sin embargo, arrancable, a menos que configurases y 
compilases un 'bootdisk'. Esta configuraci�n ha de ser la primera configuraci�n
en ser pasada a './scripts/Create-ISO'.

As�, una llamada al comando podr�a parecerse a esto:

# ./scripts/Create-ISO -size 700 -mkdebug bootdisk athlon pentium4 generic

Esto crear� un conjunto de imagenes de CDs, las cuales ser�n como mucho de 700 
MB de tama�o, el primer CD deber�a de ser arrancable y el resto contendr� las
compilaciones 'athlon', 'pentium4' y 'generic'.

Como ves, es perfectamente posible tener varias optimizaciones o diferentes
compilaciones en un mismo conjunto de CDs. De esta forma s�lo necesitarias un
conjunto de CDs para instalar diferentes m�quinas.

Si posees una grabadora de DVD, podr�as pasar el argumento '-size 4300' y 
escribir la imagen en un DVD. Deber�an de coger aproximandamente 5 o 6 
compilaciones en un solo DVD.


	7. Limpiando el arbol de fuentes
	================================

S�mplemente escribe './scripts/Cleanup' para borrar los directorios src*. NO LOS
BORRES DE FORMA MANUAL!. Estos directorios quiz�s contengan montajes unidos al
resto del arbol de fuentes y es posible que vayas a borrar todo en el directorio
 base de ROCK Linux is haces un simple 'rm -rf' para borrarlo ...

Teclea './scripts/Cleanup --full' para borrar tambi�n el directorio build/.
