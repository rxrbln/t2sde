			  Compilando ROCK Linux
			  ~~~~~~~~~~~~~~~~~~~~~


	1. Requerimientos
	=================

Para compilar ROCK Linux necesitas una buena conexión a internet para descargar
los fuentes, bastante espacio en disco, un ordenador rápido y algo de tiempo.
Dependiento de la configuración que escogas y de tu hardware, la compilación de
ROCK Linux puede tomar algunos días hasta completarse. También necesitas 
permisos de administrador para construir ROCK Linux.

La distribución sobre la que compilas ROCK Linux debería de ser una ROCK Linux.
También es posible compilar ROCK Linux sobre otra distribución, pero no esperes
lograrlo sin algo de hacking ...


	2. Estrayendo los fuentes
	=========================

Descarga el código fuente de ROCK Linux (un fichero tar.bz2 de unos pocos MB)
desde www.rocklinux.org y extráelo en cualquier lugar como root. El directorío
obtenido es el directorio 'base' de ROCK Linux.


	3. Configura la compilación
	===========================

Teclea './scripts/Config' y un menú de configuración aparecerá. Escoge tu 
configuración (o simplemente deja los valores por defecto sin tocar). Necesitas
arrancar la herramienta de configuración incluso aunque no quieras cambiar
nada.

Es posible tener múltiples configuraciones. Usa el comando './scripts/Config 
-cfg nombre_config' (donde nombre_config puede ser cualquier texto que no 
contenga espacios en blanco ni carácteres especiales). Si has escogido un nombre
para tu configuración, necesitas pasar la opción '-cfg nombre_config' como 
primer parámetro también al resto de scripts - para que puedan saber que 
configuración leer.

El nombre de configuración por defecto (cuando no se pasa la opción -cfg) es
'default'. La configuración es almacenada en el directorio 
'config/nombre_config'.


	4. Descargando los fuentes de los paquetes
	==========================================

Ahora necesitas descargar los fuentes para compilar los paquetes que escogiste
en la configuración. Sólo escribe './scripts/Download -required'.
Si quieres descargar los fuentes para todos los paquetes (a pesar de que no sean
necesarios para tu configuración), escribe './scripts/Download -all'.


	5. Compilando la distribución
	=============================

Teclea './scripts/Build-Target'. Como se mencionó antes, esto puede tomar varios
días hasta completar la compilación.

La distribución resultante es almacenada en el directorio build/.


	6. Creando imágenes de CD
	=========================

Para crear una imagen de CD desde la que instalar, puedes usar 
'./scripts/Create-ISO'. Create-ISO toma al menos un argumento: el nombre de la
configuración que compilaste (generalmente 'default' o cualquiera que escogieras
después de la opción -cfg).

Opcionalmente puedes usar la opción -size <MB> para especificar el tamaño de 
tus discos CD-R.
Otro parámetro opcional es -mkdebug, el cual creara una configuración WMWare 
para ser usada con la nueva imagen creada.

La imagen no será, sin embargo, arrancable, a menos que configurases y 
compilases un 'bootdisk'. Esta configuración ha de ser la primera configuración
en ser pasada a './scripts/Create-ISO'.

Así, una llamada al comando podría parecerse a esto:

# ./scripts/Create-ISO -size 700 -mkdebug bootdisk athlon pentium4 generic

Esto creará un conjunto de imagenes de CDs, las cuales serán como mucho de 700 
MB de tamaño, el primer CD debería de ser arrancable y el resto contendrá las
compilaciones 'athlon', 'pentium4' y 'generic'.

Como ves, es perfectamente posible tener varias optimizaciones o diferentes
compilaciones en un mismo conjunto de CDs. De esta forma sólo necesitarias un
conjunto de CDs para instalar diferentes máquinas.

Si posees una grabadora de DVD, podrías pasar el argumento '-size 4300' y 
escribir la imagen en un DVD. Deberían de coger aproximandamente 5 o 6 
compilaciones en un solo DVD.


	7. Limpiando el arbol de fuentes
	================================

Símplemente escribe './scripts/Cleanup' para borrar los directorios src*. NO LOS
BORRES DE FORMA MANUAL!. Estos directorios quizás contengan montajes unidos al
resto del arbol de fuentes y es posible que vayas a borrar todo en el directorio
 base de ROCK Linux is haces un simple 'rm -rf' para borrarlo ...

Teclea './scripts/Cleanup --full' para borrar también el directorio build/.
