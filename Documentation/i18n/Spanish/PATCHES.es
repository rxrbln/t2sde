
La Guía de Parches de ROCK Linux
================================

Para lograr que la aplicación de los parches sea lo más eficiente posible,
el envío de los parches debería de ser en el formato descrito aquí. Yo
(y alguno de los desarrolladores de subdistribuciones) rechazaremos los
parches si no están conforme a este documento.

Por favor, pon la cadena [PATCH] al inicio del campo Asunto del correo.
Podría no ser visto si no forma parte de los primeros carácteres, ya que
algunos clientes de correo sólo muestran el inicio del campo Asunto en la
lista de correos.

0. NO ENVÍES PARCHES NO TESTEADOS ANTES, SIN DEJAR CLARO QUE AÚN NO HAN
   SIDO PROBADOS, Y NO ESPERES QUE PARCHES SIN TESTEAR SEAN APLICADOS. En 
   caso de actualizaciones de paquetes, etc. es suficiente con asegurarse
   que el paquete aún se compila correctamente con una configuración más
   o menos genérica.

1. Los parches deben estar en un formato unificado. Yo prefiero diffs
   unificados. Debería ser posible aplicar el parche con el comando 'patch
   -p1 < patchfile' en el directorio base.

2. El parche no debe contener nigún fichero que sea generado de forma 
   automática por ./scripts/Puzzle.

El script "./script/Create-Diff <dir_antiguo> <dir_nuevo>" puede ser usado
para crear facilmente parches conformes al punto 1 y 2.

3. El parche debe ser contra uno de los últimos snapshots del desarrollo.

4. Un parche debe arreglar sólo un tema. Si pretendes arreglar varias cosas
   (independientes), envía varios parches.

5. Si un parche no es autodescriptivo en pocas líneas, añade un pequeño 
   comentario al principio del fichero del parche.

6. Si no recives ningún tipo de respuesta y no ves el parche en los snapshots
   después de una semana, reenvía el parche al desarrollador del paquete.

7. No empaquetes los parches en ficheros tar. Los hace mucho más pesado para
   abrirlos y leerlos en un cliente de correo. Comprime un parche sólo si es
   reálmente grande.

8. Informa al responsable del mantenimiento del paquete cuandO empiezas a 
   trabajar en un problema, para asegurar que estás duplicando trabajo.

9. No me envíes los ficheros que hayas añadido o modificado. Envíame un parche
   contra los fuentes de ROCK Linux (como se describe atrás).

10.¡NO ENVÍES FICHEROS TAR QUE REEMPLAZCAN LOS FICHEROS QUE HAS MODIFICADO!