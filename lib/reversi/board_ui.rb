
require 'ncursesw'
require 'reversi/board'

scr = Ncurses.initscr
Ncurses.cbreak
Ncurses.noecho


win = Ncurses.newwin(17, 33, 2, 5)


b = Reversi::Board.new

b.to_lines.each_with_index do |line, i|
  win.mvprintw(i, 0, line)
end

win.move(1, 2)
win.keypad true
win.refresh

while true

  c = win.getch

  win.getyx(y = [], x = [])

  i = y[0]
  j = x[0]

  case c
  when Ncurses::KEY_LEFT then win.move(i, j-4)
  when Ncurses::KEY_RIGHT then win.move(i, j+4)
  when Ncurses::KEY_UP then win.move(i-2, j)
  when Ncurses::KEY_DOWN then win.move(i+2, j)
  when ?b.ord
    win.getyx(y = [], x = [])

    i = y[0]
    j = x[0]
    b.place_black((i-1)/2, (j-2)/4)

    b.to_lines.each_with_index do |line, i|
      win.mvprintw(i, 0, line)
    end

    win.move(i, j)
  when ?w.ord
    win.getyx(y = [], x = [])

    i = y[0]
    j = x[0]
    b.place_white((i-1)/2, (j-2)/4)

    b.to_lines.each_with_index do |line, i|
      win.mvprintw(i, 0, line)
    end

    win.move(i, j)
  else
  end
  win.refresh
end

Ncurses.endwin
