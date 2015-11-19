
require 'socket'
require 'timeout'

module Reversi
  module Network
    BEACON_PORT   = 4000
    CALLBACK_PORT = 4001

    class Beacon
      def initialize(server_name)
        @server_name = server_name
        @socket = UDPSocket.new
        @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true)
        @socket.bind '0.0.0.0', BEACON_PORT
      end

      def start
        @beacon_thread = Thread.new do
          loop do
            msg, peer = @socket.recvfrom(256)
            if msg == 'reversi'
              @socket.send @server_name, 0, Socket.sockaddr_in(CALLBACK_PORT, peer[3])
            end
          end
        end
      end

      def stop
        @beacon_thread.kill
      end

      def close
        @socket.close
      end
    end

    def self.discover_peers
      socket = UDPSocket.new
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true)
      socket.bind '0.0.0.0', CALLBACK_PORT

      socket.send 'reversi', 0, Socket.sockaddr_in(BEACON_PORT, '255.255.255.255')

      peers = []

      begin
        Timeout.timeout(1) do
          loop do
            msg, addr = socket.recvfrom(256)
            peers << [msg, addr[3]]
          end
        end
      rescue Timeout::Error
      end

      socket.close

      peers
    end
  end
end
