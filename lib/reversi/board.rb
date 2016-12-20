
require 'reversi/move'

module Reversi
  class Board


    OPPOSITE = {
      black: :white,
      white: :black
    }

    DIRECTIONS = [-1, 0, 1].product([-1, 0, 1]).reject { |e| e == [0, 0] }

    attr_reader :cells

    def initialize
      @cells = []
      8.times { @cells << [:blank] * 8 }
      @cells[3][3] = @cells[4][4] = :white
      @cells[3][4] = @cells[4][3] = :black
      current_player = :black
      compute_available_moves!
    end

    def make_move(color, row:, col:)
      return unless current_player == color && valid_move?(color, row: row, col: col)
      place(color, row: row, col: col)
      switch_players
    end

    def white_count
      @cells.flatten.count { |c| c == :white }
    end

    def black_count
      @cells.flatten.count { |c| c == :black }
    end

    private

    def switch_players
      current_player = current_player == :black ? :white : :black
    end

    def place(color, row:, col:)
      return unless @cells[row][col] == :blank

      rays = get_rays(row, col, color)
      return if rays.all? { |r| r.empty? }

      rays.each do |ray|
        ray.each do |a, b|
          toggle(a, b)
        end
      end

      @cells[i][j] = color
    end

    def all_coords
      (0..7).to_a.product((0..7).to_a)
    end

    def valid_move?(color, row:, col:)
      get_rays(row, col, color).any? { |r| !r.empty? }
    end

    def moves(color)
      @moves.select { |m| m.color == color }
    end

    def complete?
      (moves(:black).count + moves(:white).count) == 0
    end

    def get_rays(i, j, type)
      DIRECTIONS.map do |di, dj|
        get_ray(i, j, di, dj, type)
      end
    end

    def get_ray(i, j, di, dj, type)
      ray = []

      while true
        i += di
        j += dj

        return [] if out_of_range?(i, j) || @cells[i][j] == :blank
        break if @cells[i][j] == type

        ray << [i, j]
      end

      ray
    end

    def out_of_range?(i, j)
      i < 0 || i > 7 || j < 0 || j > 7
    end

    def toggle(i, j)
      @cells[i][j] = OPPOSITE[@cells[i][j]]
    end
  end
end
