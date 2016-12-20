
module Reversi
  class Player
    attr_reader :color

    def initialize(board, color)
      @color = color
      @board = board
    end

    def black?
      color == :black
    end

    def white?
      color == :white
    end

  end

  # class NetworkPlayer < Player
  #   def initialize(color, socket)
  #     @socket = socket
  #     @color = color
  #   end

  #   def get_move
  #     recv_move
  #   end

  #   def notify_move(m)
  #     send_move(m)
  #   end


  #   def send_move(m)
  #     @socket.puts "#{m.i} #{m.j} #{m.color}"
  #   end

  #   def recv_move
  #     s = @socket.gets.split
  #     Move.new(s[0].to_i, s[1].to_i, s[2].to_sym)
  #   end
  # end
  class LocalPlayer

    def handle_input(input)
      if input.triggered?
        board.make_move(input.cursor_position, color)
      end
    end

    def update

    end
  end

  # class RemotePlayer
  #   def initialize(color, network)

  #   end

  #   def handle_input(input)

  #   end

  #   def update
  #     if coords = read_network
  #       game.make_move(coords, color)
  #       notify_network
  #     end
  #   end
  # end

  # class BotPlayer
  #   def initialize(color)

  #   end

  #   def handle_input(input)

  #   end

  #   def update
  #     coords = compute_best_move
  #     game.make_move(coords, color)
  #   end
  # end
end





