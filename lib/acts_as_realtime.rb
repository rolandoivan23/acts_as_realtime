require 'active_record'
require 'em-websocket'

module ActsAsRealTime

  class << self; attr_accessor :ws, :channel, :mod_app, :html, :port, :selector, :host, :insert_method; end

  def self.startup_web_socket_server
    Thread.new {
      begin
        EventMachine.run {
          @channel = EM::Channel.new
          EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8092, :debug => true) do |ws|
            @ws = ws
            #RoRRT::Application.save_communication_variables @channel, ws
            ws.onopen {
              sid = @channel.subscribe { |msg| ws.send msg }
              #@channel.push "#{sid} connected!"

              ws.onmessage { |msg|
                #@channel.push "<#{sid}>: #{msg}"
                puts msg
              }

              ws.onclose {
                @channel.unsubscribe(sid)
                #@channel.push "<#{sid}>: Closed"
              }
            }

          end
          puts "Web socket server started"
        }
      rescue => e
        puts e.message
      end
    }

    #Este while es para esperar a que el hilo asigne las variables del socket y del canal
    while (@channel.nil? and @ws.nil?); end
    [@ws, @channel]
  end

  ws, channel = ActsAsRealTime::startup_web_socket_server

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods

    def acts_as_realtime(modelo, selector, insertion_method = 'prepend', &blk)

=begin
    Se había manejado cómo posible solución el manejar un token(*-*)
    para interporlar los valores de los registros que se estan creando, cómo
    por ejemplo el nombre de un usuario.

    La idea consistia que el nombre del campo que se quiere interpolar debe de ir entre el token
    identificador(*-*) en el html que sea pasado a la gema, para se parseado(interpolado) por la gema.
    Ej:

    html = "<tr><td><div class=" + '"prueba1"' + " > *-*#{'nombre'}*-* </div></td><td>R</td><td>o</td><td>R</td></tr>"

    Esta solución puede causar problemas futuros, es por eso que se busco otra solución, que es el código
    actual, esto se deja comentado por si se necesitara usar despues



      start_index = html.index("*-*")
      sub_html = html[start_index+3..-1]
      finish_index = sub_html.index('*-*') + 2
      attr = sub_html[0..finish_index-3]


=end

      #Se define el método update_index en lo modelos que se ejecute el método acts_as_real_time
      modelo.class_eval {
        define_method(:update_index) do

          #eval("html[start_index..finish_index] = #{attr}") Esta instrucción se usaba para la solución que se planteó arriba

          res_yield = yield ActsAsRealTime.ws, ActsAsRealTime.channel, self if block_given?
          ActsAsRealTime.mod_app, ActsAsRealTime.html = res_yield[0], res_yield[1]
          ActsAsRealTime.mod_app::Application.config.chanel = ActsAsRealTime::channel
          ActsAsRealTime.mod_app::Application.config.chanel.push "$('#{selector}').#{insertion_method}('#{ActsAsRealTime.html}');"
        end
        after_create :update_index
      }
    end
  end

=begin
Estos métodos no se usa actualmente, se deja comentado cómo ejemplo para modificaciones o mejoras futuras
  def self.define_adders_methods app
    eval "#{app}::Aplication.class_eval {" +
      "define_method(:save_communication_variables, :ws, :channel){" +
        "config.chanel = channel" +
        "config.ws = ws" +
      "}" +
    "}"
  end
=end
end

ActiveRecord::Base.send :include, ActsAsRealTime
=begin
eval "RoRRT::Aplication.class_eval {" +
         "define_method(:save_communication_variables, :ws, :channel){" +
         "config.chanel = channel" +
         "config.ws = ws" +
         "}" +
         "}"
=end
