

class StateManager
  attr_reader :states, :context

  def initialize(context, state_library)
    @states = []
    @context = context
    @state_library = state_library
  end

  def current
    states.last
  end

  def set(state, params)
    states.pop
    states.push(state, params)
  end

  def push(state, params)
    states.push(state_library[state].new(context))
    current.enter(params)
  end

  def pop
    current.exit if current
    states.pop
  end
end

class GameState
  attr_reader :context

  def initialize(context)
    @context = context
  end

  def enter(params = {})

  end

  def exit

  end

  def handle_input(input)

  end

  def update

  end

  def render(graphics)

  end
end

class MainMenu < GameState
# local game
#   human vs human
#   human vs comupter
#
# network game
#   create
#   join
#
# quit
end

class InGameMenu < GameState
# resume
# restart
# quit to main menu
# quit game
end


class MainPlay < GameState
  def enter
    @board = Board.new
    @first_player = LocalPlayer.new(:black)
    @second_player = LocalPlayer.new(:white)
  end

  def handle_input(input)
    first_player.handle_input(input)
  end

  def update
    if board.complete?
      states.set(:results_overview)
    end

    first_player.update
    second_player.update
  end

  def render(graphics)
    graphics.fill_background
    graphics.draw_grid

    board.cells.each_with_index do |row, i|
      row.each do |cell, j|
        if cell == :black
          graphics.draw_white_disk(i, j)
        elsif cell == :white
          graphics.draw_black_disk(i, j)
        end
      end
    end
  end
end

class ResultsOverview < GameState
# main menu
end


    # def run
    #   current_player = black_player
    #   other_player = white_player

    #   while board.moves.any?
    #     unless board.moves(current_player.color).empty?
    #       loop do
    #         m = current_player.get_move
    #         if board.valid_move?(m)
    #           board.make_move(m)
    #           other_player.notify_move(m)
    #           break
    #         end
    #       end

    #       redraw_board
    #     end

    #     current_player, other_player = other_player, current_player
    #   end

    #   return { black: board.black_count, white: board.white_count }
    # end
