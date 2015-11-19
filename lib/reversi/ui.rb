
require 'ncursesw'

require 'reversi/network'
require 'reversi/board'
require 'reversi/player'
require 'reversi/game'


module Reversi
  class Menu
    attr_reader :win

    def initialize(menu_win=nil, &block)
      @ncurses_items = []
      @win = menu_win
      yield self
      @ncurses_menu = Ncurses::Menu.new_menu(@ncurses_items)
      @ncurses_menu.set_menu_win(@win)
    end

    def set_win(menu_win)
      @win = menu_win
      @ncurses_menu.set_menu_win(@win)
    end

    def item(text, action=nil)
      itm = Ncurses::Menu.new_item(text, '')
      proc = block_given? ? Proc.new : Proc.new { }
      itm.user_object = action || proc
      @ncurses_items << itm
    end

    def submenu(text, &block)
      item(text, Menu.new(win, &block))
    end

    def dynamic(&block)
      @dynamic = block
    end

    def post
      if @dynamic
        @ncurses_items.each { |i| Ncurses::Menu.free_item(i) }
        @dynamic.call(self)
        @ncurses_menu.set_menu_items(@ncurses_items)
      end
      @ncurses_menu.post_menu
    end

    def unpost
      @ncurses_menu.unpost_menu
    end

    def go_up
      @ncurses_menu.menu_driver(Ncurses::Menu::REQ_UP_ITEM)
    end

    def go_down
      @ncurses_menu.menu_driver(Ncurses::Menu::REQ_DOWN_ITEM)
    end

    def current_action
      @ncurses_menu.current_item.user_object
    end

    def call
      post
      loop do
        case getch
        when Ncurses::KEY_DOWN then go_down
        when Ncurses::KEY_UP   then go_up
        when 10 # ENTER key
          unpost
          current_action.call
          post
        when Ncurses::KEY_BACKSPACE then break
        else
        end
      end
      unpost
    end

    def getch
      (@win || Ncurses).getch
    end

    def destroy
      unpost
      @ncurses_items.each do |i|
        if i.user_object.kind_of? Menu
          i.user_object.destroy
        end
        Ncurses::Menu.free_item(i)
      end
      @ncurses_menu.free_menu
    end
  end


  class UI
    def initialize
      @main_screen = Ncurses.initscr
      Ncurses.cbreak
      Ncurses.noecho
      Ncurses.keypad(@main_screen, true)

      @menu_stack = []
    end

    def board_win
      @board_win ||= Ncurses.newwin(17, 33, 2, 5).tap do |win|
        win.keypad true
      end
    end

    def menu_win
      @menu_win ||= Ncurses.newwin(10, 33, 20, 5).tap do |win|
        win.keypad true
        win.box(0, 0)
      end
    end

    def get_input_on_board_win
      loop do
        board_win.getyx(y = [], x = [])
        i, j = y[0], x[0]

        case c = board_win.getch
        when Ncurses::KEY_LEFT  then board_win.move(i, j-4)
        when Ncurses::KEY_RIGHT then board_win.move(i, j+4)
        when Ncurses::KEY_UP    then board_win.move(i-2, j)
        when Ncurses::KEY_DOWN  then board_win.move(i+2, j)
        when 10
          return [i, j] # window coordinates
        else
        end
      end
    end

    def menu
      @menu ||= Menu.new(menu_win) do |m|
        m.item 'Local Game' do
          create_local_game
        end
        m.submenu 'Network Game' do |m|
          m.item 'Create Game' do
            create_network_game
          end

          m.submenu 'Join Game' do |m|
            m.dynamic do |m|
              peers = Network.discover_peers
              peers.each do |name, addr|
                m.item "#{name} | #{addr}" do
                  join_network_game(addr)
                end
              end
              m.item 'Join Custom address' do
                addr = get_network_address
                join_network_game(addr)
              end
            end
          end
        end
      end
    end

    def win2board_coords(i, j)
      [(i-1)/2, (j-2)/4]
    end

    def redraw_board(board)
      board_win.getyx(y = [], x = [])
      board.to_lines.each_with_index do |line, i|
        board_win.mvprintw(i, 0, line)
      end
      board_win.move(y[0], x[0])
      board_win.refresh
    end

    def run
      board_win.refresh
      #i, j = get_input_on_board_win
      menu.call
      destroy
      #puts "[#{i}, #{j}]"
    end

    def create_local_game
      b = Board.new

      p1 = Player.new(b, :black) do
        win2board_coords(*get_input_on_board_win)
      end

      p2 = Player.new(b, :white) do
        win2board_coords(*get_input_on_board_win)
      end

      g = Game.new(b, p1, p2) do |b|
        redraw_board(b)
      end

      redraw_board(b)
      board_win.move(1, 2)

      results = g.run

      menu_win.mvprintw(0, 0, results.inspect)
      menu_win.refresh
      menu_win.getch
    end

    def create_network_game
      menu_win.mvprintw(0, 0, "Enter the server name:")
      menu_win.move(2, 1)
      server_name = ""
      Ncurses.echo
      menu_win.getstr(server_name)
      Ncurses.noecho

      beacon = Network::Beacon.new(server_name)
      beacon.start

      menu_win.mvprintw(0, 0, "Waiting a player at '#{server_name}'")
      menu_win.refresh

      server = TCPServer.new '0.0.0.0', 5000
      server.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true)
      socket = server.accept

      beacon.stop
      beacon.close
      menu_win.erase
      menu_win.refresh

      b = Board.new

      local_player = Player.new(b, :black) do
        win2board_coords(*get_input_on_board_win)
      end

      network_player = NetworkPlayer.new(:white, socket)

      g = Game.new(b, local_player, network_player) do |b|
        redraw_board(b)
      end

      redraw_board(b)
      board_win.move(1, 2)

      results = g.run

      socket.close

      menu_win.mvprintw(0, 0, results.inspect)
      menu_win.refresh
      menu_win.getch
    end

    def join_network_game(addr)
      socket = TCPSocket.new addr, 5000

      b = Board.new

      local_player = Player.new(b, :white) do
        win2board_coords(*get_input_on_board_win)
      end

      network_player = NetworkPlayer.new(:black, socket)

      g = Game.new(b, local_player, network_player) do |b|
        redraw_board(b)
      end

      menu_win.erase
      menu_win.refresh

      redraw_board(b)
      board_win.move(1, 2)

      results = g.run

      socket.close

      menu_win.mvprintw(0, 0, results.inspect)
      menu_win.refresh
      menu_win.getch
    end

    def get_network_address
      menu_win.erase
      menu_win.mvprintw(0, 0, "Enter the server address:")
      menu_win.move(2, 1)
      address = ""
      Ncurses.echo
      menu_win.getstr(address)
      Ncurses.noecho
      address
    end

    def display_game_results

    end

    def destroy
      board_win.delwin
      menu.destroy
      menu_win.delwin
      Ncurses::endwin
    end
  end
end
