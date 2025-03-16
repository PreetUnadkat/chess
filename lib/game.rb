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
      break if check_mate

      @players.each do |player|
        base_cord = nil
        target_cord = nil
        @boardo.render_board
        loop do
          base_cord = player.ask_base
          checker = MoveChecker.new(@boardo, @grid[base_cord[0]][base_cord[1]])
          @options = checker.real_possible_moves(player.color)
          # puts @options.inspect, 'YOLOLOLO26'
          break if @options != []

          puts 'Invalid move. Please try again.'
        end
        # loser = check_mate
        # if loser
        #   puts "The lowser is #{loser}"
        #   break
        # end
        loop do
          puts 'Options:'
          # puts
          # puts @options.inspect, 'YOLOLOLO26'
          # puts @options[1].inspect, 'YOLOLOLO26'
          @options.each { |option| puts "#{option[1]}" }
          @options.each { |option| puts "#{(option[1] + 96 + 1).chr}#{8 - option[0]},'hi'" }
          @boardo.display_possible_moves(@options)

          target_cord = player.ask_target
          break if @options.include?(target_cord)

          puts 'Invalid move. Please try again.'
        end
        @boardo.move_piece(base_cord, target_cord)
      end
      loser = check_mate
      next unless loser

      puts "The lowser is #{loser}"
      @boardo.render_board
      break
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
      return player.name if checker.check_mate
    end
    false
  end
end
# board = Board.new
# game = Game.new(board)
# board.render_board
# game.setup_players
# game.play

puts '=========================================='
puts 'Direct play'
board = Board.new

board.move_piece([7, 6], [5, 6])
board.move_piece([7, 5], [5, 5])
# board.move_piece([0, 3], [4, 4])
# board.move_piece([0, 3], [4, 4])

game = Game.new(board)
game.add_player(Player.new('Alice', 'W'))
game.add_player(Player.new('Bob', 'B'))
game.play
