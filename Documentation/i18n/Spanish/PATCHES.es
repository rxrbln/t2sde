
La Gu�a de Parches de ROCK Linux
================================

Para lograr que la aplicaci�n de los parches sea lo m�s eficiente posible,
el env�o de los parches deber�a de ser en el formato descrito aqu�. Yo
(y alguno de los desarrolladores de subdistribuciones) rechazaremos los
parches si no est�n conforme a este documento.

Por favor, pon la cadena [PATCH] al inicio del campo Asunto del correo.
Podr�a no ser visto si no forma parte de los primeros car�cteres, ya que
algunos clientes de correo s�lo muestran el inicio del campo Asunto en la
lista de correos.

0. NO ENV�ES PARCHES NO TESTEADOS ANTES, SIN DEJAR CLARO QUE A�N NO HAN
   SIDO PROBADOS, Y NO ESPERES QUE PARCHES SIN TESTEAR SEAN APLICADOS. En 
   caso de actualizaciones de paquetes, etc. es suficiente con asegurarse
   que el paquete a�n se compila correctamente con una configuraci�n m�s
   o menos gen�rica.

1. Los parches deben estar en un formato unificado. Yo prefiero diffs
   unificados. Deber�a ser posible aplicar el parche con el comando 'patch
   -p1 < patchfile' en el directorio base.

2. El parche no debe contener nig�n fichero que sea generado de forma 
   autom�tica por ./scripts/Puzzle.

El script "./script/Create-Diff <dir_antiguo> <dir_nuevo>" puede ser usado
para crear facilmente parches conformes al punto 1 y 2.

3. El parche debe ser contra uno de los �ltimos snapshots del desarrollo.

4. Un parche debe arreglar s�lo un tema. Si pretendes arreglar varias cosas
   (independientes), env�a varios parches.

5. Si un parche no es autodescriptivo en pocas l�neas, a�ade un peque�o 
   comentario al principio del fichero del parche.

6. Si no recives ning�n tipo de respuesta y no ves el parche en los snapshots
   despu�s de una semana, reenv�a el parche al desarrollador del paquete.

7. No empaquetes los parches en ficheros tar. Los hace mucho m�s pesado para
   abrirlos y leerlos en un cliente de correo. Comprime un parche s�lo si es
   re�lmente grande.

8. Informa al responsable del mantenimiento del paquete cuandO empiezas a 
   trabajar en un problema, para asegurar que est�s duplicando trabajo.

9. No me env�es los ficheros que hayas a�adido o modificado. Env�ame un parche
   contra los fuentes de ROCK Linux (como se describe atr�s).

10.�NO ENV�ES FICHEROS TAR QUE REEMPLAZCAN LOS FICHEROS QUE HAS MODIFICADO!