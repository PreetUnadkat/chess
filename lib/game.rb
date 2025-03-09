require_relative 'player'
require_relative 'board'
class Game
  def initialize(board)
    @board = board
    @players = []
  end

  def add_player(player)
    @players << player
  end

  def play
    @players.each do |player|
      base_cord = nil
      loop do
        base_cord = player.ask_base
        break if possible_moves(base_cord) != []

        puts 'Invalid move. Please try again.'
      end
      target_cord = nil
      loop do
        target_cord = player.ask_target(base_cord)
        break if valid_base_cord?(target_cord)

        puts 'Invalid move. Please try again.'
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
end
board = Board.new
game = Game.new(board)
board.print
game.setup_players
game.play
