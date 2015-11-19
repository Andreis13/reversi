
module Reversi
  class Game
    attr_reader :black_player, :white_player, :board
    def initialize(board, p1, p2, &block)
      @board = board
      @redraw_callback = block
      @black_player, @white_player = p1.black? ? [p1, p2] : [p2, p1]
    end

    def run
      current_player = black_player
      other_player = white_player

      while board.moves.any?
        unless board.moves(current_player.color).empty?
          loop do
            m = current_player.get_move
            if board.valid_move?(m)
              board.make_move(m)
              other_player.notify_move(m)
              break
            end
          end

          redraw_board
        end

        current_player, other_player = other_player, current_player
      end

      return { black: board.black_count, white: board.white_count }
    end

    def redraw_board
      @redraw_callback.call(@board)
    end
  end
end
