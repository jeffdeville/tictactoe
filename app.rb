module TicTacToe
  class Board
    class InvalidMove < StandardError;
    end

    LEFT_DIAGONAL = [[0, 0], [1, 1], [2, 2]]
    RIGHT_DIAGONAL = [[2, 0], [1, 1], [0, 2]]

    def initialize
      @board = [[nil, nil, nil],
                [nil, nil, nil],
                [nil, nil, nil]]
      @errors = []
    end

    def to_s
      puts @board.map { |row| row.map { |e| e || " " }.join("|") }.join("\n")
    end

    def [](row, col)
      @board.fetch(row).fetch(col)
    end

    def []=(row, col, marker)
      assert_valid_move row, col
      @board[row][col] = marker
    end

    def draw?
      draw = @board.flatten.compact.length == 9
      yield if draw
      draw
    end

    def assert_valid_move(row, col)
      begin
        self[row, col]
      rescue IndexError
        raise InvalidMove, "Out of bounds, try another position"
      end
      raise InvalidMove, "Cell occupied, try another position" if self[row, col]
    end

    def winner?(row, col, current_player)
      win = intersecting_lines(row, col).any? do |line|
        line.all? { |row, col| self[row, col] == current_player }
      end
      yield if win
      win
    end

    def intersecting_lines(row, col)
      lines = []

      [LEFT_DIAGONAL, RIGHT_DIAGONAL].each do |line|
        lines << line if line.include?([row, col])
      end

      lines << (0..2).map { |c1| [row, c1] }
      lines << (0..2).map { |r1| [r1, col] }
      lines
    end
  end

  class Game
    def initialize
      @board = Board.new
      @players = [:X, :O].cycle
      @current_player = @players.next
    end

    def play
      loop do
        row, col = capture_move { |error| puts error }
        exit if @board.winner?(row, col, @current_player) { puts "#{@current_player} wins!" }
        exit if @board.draw? { puts "It's a draw!'" }
        @current_player = @players.next
      end
    end

    def display_board
      puts @board.to_s
    end

    def capture_move
      display_board
      print "\n>> "
      row, col = gets.split.map { |e| e.to_i }
      puts

      @board[row, col] = @current_player
      [row, col]
    rescue TicTacToe::Board::InvalidMove => error
      yield error.message if block_given?
      retry
    end
  end
end

TicTacToe::Game.new.play