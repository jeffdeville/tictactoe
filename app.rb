class Board
  def initialize
    @board = [[nil, nil, nil],
              [nil, nil, nil],
              [nil, nil, nil]]
  end

  def to_s
    puts @board.map { |row| row.map { |e| e || " " }.join("|") }.join("\n")
  end

  def fetch(x, y)
    @board[x][y]
  end

  def move(x, y, player)
    @board[x][y] = player
  end

  def draw?
    @board.flatten.compact.length == 9
  end
end

class Rules
  @@left_diagonal = [[0, 0], [1, 1], [2, 2]]
  @@right_diagonal = [[2, 0], [1, 1], [0, 2]]

  def initialize(board)
    @board = board
  end

  def valid_move?(row, col)
    begin
      @board.fetch(row, col)
    rescue IndexError
      puts "Out of bounds, try another position"
      return false
    end

    if @board.fetch(row, col)
      puts "Cell occupied, try another position"
      return false
    end
    true
  end

  def winner?(row, col, current_player)
    lines = []

    [@@left_diagonal, @@right_diagonal].each do |line|
      lines << line if line.include?([row, col])
    end

    lines << (0..2).map { |c1| [row, c1] }
    lines << (0..2).map { |r1| [r1, col] }

    lines.any? do |line|
      line.all? { |row, col| @board.fetch(row, col) == current_player }
    end
  end
end

class TicTacToe
  def initialize
    @board = Board.new
    @rules = Rules.new @board
    @players = [:X, :O].cycle
    @current_player = @players.next
  end

  def play
    loop do
      puts @board.to_s
      row, col = capture_move
      #print "\n>> "
      #row, col = gets.split.map { |e| e.to_i }
      #puts

      next unless @rules.valid_move? row, col

      @board.move row, col, @current_player

      if @rules.winner? row, col, @current_player
        puts "#{@current_player} wins!"
        exit
      end

      if @board.draw?
        puts "It's a draw!"
        exit
      end

      @current_player = @players.next
    end
  end

  def capture_move
    print "\n>> "
    row, col = gets.split.map { |e| e.to_i }
    puts
    [row, col]
  end
end

TicTacToe.new.play