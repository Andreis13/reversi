
require 'reversi/graphics'

module Reversi
  class Game < Gosu::Window
    attr_reader :states

    def initialize

      @states = StateManager.new(self, {
        # main_menu:        MainMenu,
        # in_game_menu:     InGameMenu,
        main_play:        MainPlay,
        # results_overview: ResultsOverview
      })
      @states.set(:main_play)

      @window_width = 320
      @window_height = 320
      super(@window_width, @window_height)

      @graphics = Graphics.new(@window_width, @window_height)
    end

    def start
      show
    end

    def update
      update_input_device
      states.current.handle_input
      states.current.update
    end

    def update_input_device

    end

    def draw
      states.current.render(graphics)
    end

    def needs_cursor?
      true
    end

  end
end
