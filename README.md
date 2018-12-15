# TP_Final


>Instrucciones de uso:

1) Clonar la applicación a una ubicación local.
2) Desde una terminal correr el comando 'bundle install' para importar todas las gemas necesarias.
  
  *En caso de que falle la instalación de la gema Gruff debido a su dependencia con ImageMagick, intentar corriendo el siguiente comando, y luego volver a ejecutar 'bundle install':

    'sudo apt-get install libmagickwand-dev imagemagick'


3) Inicio: al ejecutar 'ruby app.rb' inicia la aplicación importando por única vez los datos contenidos en 'obras.csv'.
4) Por medio del menú de navegación se puede acceder a las diferentes secciones: 

  * Inicio (Bienvenida)
  * Nueva Obra (Permite cargar una nueva Obra)
  * Lista Obras (Muestra el listado de Obras y permite acceder a sus detalles, modificarlas o eliminarlas)
  * Estadísticas (Muestra diferentes tablas, estadísticas y gráficos comparativos. Además brinda la posibilidad de buscar obras por año de inicio o finalización)
  * Enunciado TP (Detalla el contenido y formato del proyecto, según requerimientos de los PO)
  * Contacto (Datos personales de contacto)