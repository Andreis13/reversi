
require 'reversi/move'

module Reversi
  class Board
    WHITE_CIRCLE = " \u25cb "
    BLACK_CIRCLE = " \u25cf "

    BORDER = {
      tl_corner: "\u250C",
      bl_corner: "\u2514",
      tr_corner: "\u2510",
      br_corner: "\u2518",
      vert_pipe: "\u2502",
      horz_pipe: "\u2500\u2500\u2500",
      left_t:    "\u251C",
      right_t:   "\u2524",
      top_t:     "\u252C",
      bottom_t:  "\u2534",
      cross:     "\u253C"
    }

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
      compute_available_moves!
    end

    def place_white(i, j)
      place(i, j, :white)
    end

    def place_black(i, j)
      place(i, j, :black)
    end

    def place(i, j, type)
      return unless @cells[i][j] == :blank

      rays = get_rays(i, j, type)
      return if rays.all? { |r| r.empty? }

      rays.each do |ray|
        ray.each do |a, b|
          toggle(a, b)
        end
      end

      @cells[i][j] = type
    end

    def make_move(m)
      place(m.i, m.j, m.color)
      compute_available_moves!
    end

    def compute_available_moves!
      @moves = []
      all_coords.each do |i, j|
        next unless @cells[i][j] == :blank
        @moves << Move.new(i, j, :white) if get_rays(i, j, :white).any? { |r| !r.empty? }
        @moves << Move.new(i, j, :black) if get_rays(i, j, :black).any? { |r| !r.empty? }
      end
    end

    def all_coords
      (0..7).to_a.product((0..7).to_a)
    end

    def valid_move?(m)
      @moves.include?(m)
    end

    def moves(color = nil)
      if color
        @moves.select { |m| m.color == color }
      else
        @moves
      end
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

    def white_count
      @cells.flatten.count { |c| c == :white }
    end

    def black_count
      @cells.flatten.count { |c| c == :black }
    end

    def to_lines
      top = "#{BORDER[:tl_corner]}#{([BORDER[:horz_pipe]] * 8).join(BORDER[:top_t])}#{BORDER[:tr_corner]}"
      middle = "#{BORDER[:left_t]}#{([BORDER[:horz_pipe]] * 8).join(BORDER[:cross])}#{BORDER[:right_t]}"
      bottom = "#{BORDER[:bl_corner]}#{([BORDER[:horz_pipe]] * 8).join(BORDER[:bottom_t])}#{BORDER[:br_corner]}"

      lines = @cells.map { |line| "#{BORDER[:vert_pipe]}#{circles(line).join(BORDER[:vert_pipe])}#{BORDER[:vert_pipe]}" }

      lines_with_middle = lines.inject([]) do |acc, itm|
        acc << middle unless acc.empty?
        acc << itm
        acc
      end

      [top, lines_with_middle, bottom].flatten
    end


    def to_s
      to_lines.join("\n")
    end

    def circles(arr)
      arr.map do |itm|
        case itm
        when :white then WHITE_CIRCLE
        when :black then BLACK_CIRCLE
        else '   '
        end
      end
    end
  end
end
