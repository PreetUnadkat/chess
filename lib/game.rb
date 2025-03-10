require_relative 'player'
require_relative 'board'
require_relative 'move_checker'
class Game
  def initialize(board)
    @boardo = board
    @players = []
    @grid = @boardo.instance_variable_get(:@board)
    @options = []
  end

  def add_player(player)
    @players << player
  end

  def play
    while true
      @players.each do |player|
        base_cord = nil
        target_cord = nil
        @boardo.render_board
        loop do
          base_cord = player.ask_base
          checker = MoveChecker.new(@boardo, @grid[base_cord[0]][base_cord[1]])
          @options = checker.real_possible_moves
          break if @options != []

          puts 'Invalid move. Please try again.'
        end
        winner = check_mate
        if winner
          puts "The winner is #{winner}"
          break
        end
        loop do
          puts 'Options:'
          @options.each { |option| puts "#{(option[1] + 96 + 1).chr}#{8 - option[0]}" }
          target_cord = player.ask_target
          break if @options.include?(target_cord)

          puts 'Invalid move. Please try again.'
        end
        @boardo.move_piece(base_cord, target_cord)
      end
      winner = check_mate
      if winner
        puts "The winner is #{winner}"
        break
      end
    end
  end

  def setup_players
    2.times do |i|
      puts "Enter name for player #{i + 1}:"
      name = gets.chomp
      color = i.zero? ? 'W' : 'B'
      add_player(Player.new(name, color))
    end
  end

  def check_mate
    @players.each do |player|
      king = @boardo.find_king(player.color)
      checker = MoveChecker.new(@boardo, king)

      return player.name if checker.real_possible_moves == [] && (checker.check != [])
    end
    false
  end
end
board = Board.new
game = Game.new(board)
# board.render_board
game.setup_players
game.play
