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
      player.play
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
