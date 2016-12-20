
require 'gosu'

module Reversi
  class Graphics
    attr_reader :window_width, :window_height, :board_size, :disk_radius

    BACKGROUND_COLOR = Gosu::Color.rgba(0x39A737FF)
    GRID_COLOR = Gosu::Color.rgba(0x241309FF)
    COLOR_WHITE = Gosu::Color::WHITE
    COLOR_BLACK = Gosu::Color::BLACK

    def initialize(w_width, w_height)
      @window_width = w_width
      @window_height = w_height
      @board_size = 320
      @disk_radius = 15
    end

    def fill_background
      Gosu.draw_rect(0, 0, 320, 320, BACKGROUND_COLOR)
    end

    def draw_black_disk(row, col)
      draw_disk(row, col, COLOR_BLACK)
    end

    def draw_white_disk(row, col)
      draw_disk(row, col, COLOR_WHITE)
    end

    def draw_disk(row, col, color)
      x, y = position_to_coords(row, col)
      draw_circle(x, y, disk_radius, color)
    end

    def draw_circle(x, y, r, color)
      resolution = 36
      da = 2 * Math::PI / resolution

      unit_circle_points = Array(0..resolution).map do |i|
        angle = da * i
        [Math.cos(angle), Math.sin(angle)]
      end

      unit_circle_points.each_cons(2) do |(x1, y1), (x2, y2)|
        draw_triangle(
          x, y, color,
          x + (x1 * r), y + (y1 * r), color,
          x + (x2 * r), y + (y2 * r), color
        )
      end
    end

    def draw_grid
      interval = board_size / 8
      line_width = 2

      9.times do |i|
        draw_horizontal_line(i * interval, line_width, GRID_COLOR)
        draw_vertical_line(i * interval, line_width, GRID_COLOR)
      end
    end

    def draw_horizontal_line(y, line_width, color)
      Gosu.draw_rect(0, y - line_width/2, board_size, line_width, color)
    end

    def draw_vertical_line(x, line_width, color)
      Gosu.draw_rect(x - line_width/2, 0, line_width, board_size, color)
    end

    def position_to_coords(row, col)
      interval = board_size / 8
      half_interval = interval / 2
      [interval * col + half_interval, interval * row + half_interval]
    end
  end
end
