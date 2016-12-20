

module Reversi
  class BoardRenderer
    def initialize(board)
      @board = board
    end

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

    def circles(arr)
      arr.map do |itm|
        case itm
        when :white then WHITE_CIRCLE
        when :black then BLACK_CIRCLE
        else '   '
        end
      end
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

  end
end
