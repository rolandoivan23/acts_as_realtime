require 'active_record'
require 'em-websocket'

module ActsAsRealTime

  class << self; attr_accessor :ws, :channel, :mod_app, :html; end

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
    def acts_as_realtime &blk
#      puts "ESTA GEMARA HARA QUE LAS APLICACIONES DE RAILS REVOLUCIONEN INCREIBLEMENTE"

      res_yield = yield ActsAsRealTime.ws, ActsAsRealTime.channel if block_given?
      ActsAsRealTime.mod_app, ActsAsRealTime.html = res_yield[0], res_yield[1]
      ActsAsRealTime.mod_app::Application.config.chanel = ActsAsRealTime::channel
      puts "EL HTML DEBE DE SER ASI: #{ActsAsRealTime.html}"

      ActiveRecord::Base.class_eval {

        define_method(:update_index) do
          puts "SI SE EJECUTA EL UPDATE INDEX-----------++++++++++++++++-------------"
          ActsAsRealTime.mod_app::Application.config.chanel.push "$('#users-table > tbody:first').prepend('<tr><td>#{ActsAsRealTime.html}</td><td>R</td><td>o</td><td>R</td></tr>');"


        end
        after_create :update_index

      }
    end
  end

  def self.define_adders_methods app
    eval "#{app}::Aplication.class_eval {" +
      "define_method(:save_communication_variables, :ws, :channel){" +
        "config.chanel = channel" +
        "config.ws = ws" +
      "}" +
    "}"
  end
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
