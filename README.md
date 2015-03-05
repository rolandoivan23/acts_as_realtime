# acts_as_realtime
Gema para agregar funcionalidad de tiempo real en tus index de manera sencilla.

acts_as_realtime pretende ayudar a implementar index en los que se puedan insertar elementos o registros personalizados 
en tiempo real, esto es al mismo instante en que se crean los registros del modelo al que corresponde el index que
queremos modificar en tiempo real. Esta gema esta pensada para ser usada en aplicaciones de rails.

Instalaión

Gemfile

gem 'acts_as_realtime'

Requerimientos

*Jquery, puedes usar la cdn de la siguiente manera
<script src="//code.jquery.com/jquery-1.11.0.min.js"></script>

*Ruby 1.9.2 o superior

Uso

El uso de esta gema es bastante simple, solo se tiene que ejecutar el método acts_as_realtime en los modelos que queremos 
con index de tiempo real, el método puede llevar una serie de parametros para modificar un poco el comportamiento y otros 
parámetros obligatorios pero estos serán explicados más adelante, el otro paso es insertar el código necesario en las vistas,
este código en un futuro debe de ser reemplazado por un helper, esto para solo llamar el helper y que este inserte el código
en la vista por nosotros.

Ejemplo páctico:

Modelo User.rb #Sólo cómo ejemplo
class User < ActiveRecord::Base
  acts_as_realtime do |ws, channel, inst|
    html = "<tr><td><div class=" + '"prueba1"' + " > #{inst.nombre} </div></td><td>R</td><td>o</td><td>R</td></tr>"
    [RoRRT, html] #Este arreglo debe de enviarse de esta manera estrictamente para el buen funcionamiento de la gema.
  end
end

La parte de la vista puedes poner el siguiente código en tu application.html.erb

  function debug(string) {
          var element = document.getElementById("debug");
          var p = document.createElement("p");
          p.appendChild(document.createTextNode(string));
          element.appendChild(p);
  }
  function init() {
      var Socket = "MozWebSocket" in window ? MozWebSocket : WebSocket;
      var ws = new Socket("ws://localhost:8092");
      ws.onmessage = function(evt) { eval(evt.data);  };
      ws.onclose = function(event) {
          debug("Received: " + evt.data);
      };
      ws.onopen = function() {

      };
  };
      
  Lo único restante sería ejecutar en el evento load del body la función init. Esto de la siguiente manera:
  
  <body onload="init();">
  
  NOTA: Cabe hacer mención que la parte donde se inicializa el socket (var ws = new Socket("ws://localhost:8092");) debe 
  de variar una vez que estemos en un hambiente de producción, la inicialización debe de contener la ip de nuestro servidor
  de producción o bien el dominio de nuestra aplicación.
  
  Para cualquier duda, comentario, mejora o sugerencia pueden contactarme en rolando.vazquez.23@gmail.com
  
  Una disculpa de antemano por todos los errores que se puedan presentar o por la falta de buenas prácticas, esta es mi primer gema
  formal y me falta mucho por aprender, gracias por su comprensión.
