# acts_as_realtime
Gema para agregar funcionalidad de tiempo real en tus index de manera sencilla.

acts_as_realtime pretende ayudar a implementar index en los que se puedan insertar elementos o registros personalizados 
en tiempo real, esto es al mismo instante en que se crean los registros del modelo al que corresponde el index que
queremos modificar en tiempo real. Esta gema esta pensada para ser usada en aplicaciones de rails.

##Instalación

Gemfile

`gem 'acts_as_realtime'`

##Requerimientos

+ Jquery, puedes usar la cdn de la siguiente manera
> `<script src="//code.jquery.com/jquery-1.11.0.min.js"></script>`
+ Ruby 1.9.2 o superior

##Uso

El uso de esta gema es bastante simple, solo se tiene que ejecutar el método acts_as_realtime en los modelos que queremos 
con index de tiempo real, el método puede llevar una serie de parametros para modificar un poco el comportamiento y otros 
parámetros obligatorios pero estos serán explicados más adelante, el otro paso es insertar el código necesario en las vistas,
este código en un futuro debe de ser reemplazado por un helper, esto para solo llamar el helper y que este inserte el código
en la vista por nosotros.

Ejemplo páctico:

Modelo User.rb #Sólo cómo ejemplo

<pre><code>
    class User &lt; ActiveRecord::Base 
      acts_as_realtime(self, '#users-table > tbody:first') do |ws, channel, inst| 
        html = "&lt;tr&gt;&lt;td&gt;&lt;div class=" + '"prueba1"' + " &gt; #{inst.nombre} &lt;/div&gt;&lt;/td&gt;&lt;td&gt;R&lt;/td&gt;&lt;td&gt;o&lt;/td&gt;&lt;td&gt;R&lt;/td&gt;&lt;/tr&gt;" 
        [RoRRT, html] #Este arreglo debe de enviarse de esta manera estrictamente para el buen funcionamiento de la gema. 
      end 
    end
</code></pre>

Nota: Todas las comillas de propiedades como la de class, id, style, etc deben de ser estrictamente como comillas dobles, es por 
esta razón la concatenación que se usa en este ejemplo.
###Parámetros
Los parámetros que necesita la gema los podemos dividir en obligatorios y opcionales

####Obligatorios

+ Modelo: es la clase del modelo que queremos darle la funcionalidad de tiempo real, puede ser self o el nombre de la clase
+ El bloque, en el cual su última sentencia debe de ser un arreglo, donde el primer elemento corresponde al módulo
de nuestra aplicación de rails, es este caso mi applicación se llama RoRRT, es por eso que así se llama el módulo,
el segundo elemento debe de ser la estructura del html que queremos que se inserte en nuestro index. Básicamente
estas son las únicas reglas obligatorias para que funcione adecuadamente la gema.

+ Selector de jquery: Este parámetro es para indicar el contenedor en el cúal se deben de insertar los nuevos registros
creados

####No obligatorios

+ Método de inserción: Este método es con el que se va a insertar los registros mediante jquery, por default es prepend, la 
otra posible opción es un append. 

En este caso la llamada sería la siguiente:

<pre><code>
    acts_as_realtime(self, '#users-table > tbody:first', 'append') do |ws, channel, inst| 
        html = "&lt;tr&gt;&lt;td&gt;&lt;div class=" + '"prueba1"' + " &gt; #{inst.nombre} &lt;/div&gt;&lt;/td&gt;&lt;td&gt;R&lt;/td&gt;&lt;td&gt;o&lt;/td&gt;&lt;td&gt;R&lt;/td&gt;&lt;/tr&gt;" 
        [RoRRT, html] #Este arreglo debe de enviarse de esta manera estrictamente para el buen funcionamiento de la gema. 
      end 
</code></pre>      

####Enviados por la gema

En el bloque que enviamos a la gema también nos manda cierto parametros que pueden ser de gran utilidad, estos son:

+ Web Socket: el objeto del web socket que se usa para la comunicación
+ Channel: Este parámetro se usa para que a todos los usuarios que entren a determinado index se les mande la información
+ Instancia: Esta es la instancia de cada registro que se crea para determinado modelo, es de suma importancia para 
poder enviar el html que queremos con la nueva información cómo se muestra en el ejemplo.

Nota: Los dos primeros objetos pueden ser de gran utilidad para otras funcionalidades, es por ello que los manda la gema, pero
ellos no se van a tocar a fondo, para conocerlos más puede ver la documentación de [EM WebSocket](https://github.com/igrigorik/em-websocket)

La parte de la vista puedes poner el siguiente código en tu application.html.erb


<pre><code>
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
    
          }
      };
</code></pre>
      
  Lo único restante sería ejecutar en el evento load del body la función init. Esto de la siguiente manera:
  
 `<body onload="init();">`
  
  NOTA: Cabe hacer mención que la parte donde se inicializa el socket (var ws = new Socket("ws://localhost:8092");) debe 
  de variar una vez que estemos en un hambiente de producción, la inicialización debe de contener la ip de nuestro servidor
  de producción o bien el dominio de nuestra aplicación.
  
  Para cualquier duda, comentario, mejora o sugerencia pueden contactarme en rolando.vazquez.23@gmail.com
  
  Una disculpa de antemano por todos los errores que se puedan presentar o por la falta de buenas prácticas, esta es mi primer gema
  formal y me falta mucho por aprender, gracias por su comprensión.
