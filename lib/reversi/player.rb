
require 'reversi/move'

module Reversi
  class Player
    attr_reader :color

    def initialize(board, color, &callback)
      @color = color
      @board = board
      @get_move_callback = callback
    end

    def get_move
      i, j = @get_move_callback.call
      Move.new(i, j, color)
    end

    def notify_move(m)

    end

    def black?
      color == :black
    end

    def white?
      color == :white
    end

  end

  class NetworkPlayer < Player
    def initialize(color, socket)
      @socket = socket
      @color = color
    end

    def get_move
      recv_move
    end

    def notify_move(m)
      send_move(m)
    end


    def send_move(m)
      @socket.puts "#{m.i} #{m.j} #{m.color}"
    end

    def recv_move
      s = @socket.gets.split
      Move.new(s[0].to_i, s[1].to_i, s[2].to_sym)
    end
  end
end
