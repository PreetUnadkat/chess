# here game will only be played and cached not saved or loaded or anything else there is record class for that!
# changes of every move will be stored in @cache and can be undone by undo method of board which will reaturn the board of the previous state!
require_relative 'player'
require_relative 'board'
require_relative 'move_checker'
class Game
  def initialize(board)
    @boardo = board
    @players = []
    @grid = @boardo.instance_variable_get(:@board)
    @options = []
    @cache = [] # format -> [start_cord, end_cord]
    @boardso = [0, 1]
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

        loop do
          @boardo.render_board

          @options = []

          base_cord = ask_baso(player)
          if base_cord == :undo
            puts 'undo in process'
            break
          end

          target_cord = ask_targeto(player)
          if target_cord == :reselecting # Custom return value to indicate re-selection
            puts 'Reselecting piece...'
            next
          end
          if target_cord == :undo
            puts 'undo in process'
            break
          end
          cache_adder(base_cord, target_cord)
          @boardo.move_piece(base_cord, target_cord)
          break
        end
      end

      loser = check_mate
      next unless loser

      puts "The loser is #{loser}"
      @boardo.render_board
      break
    end
  end

  def cache_adder(start_cord, end_cord)
    @cache << [start_cord, end_cord, @grid[end_cord[0]][end_cord[1]]]
  end

  def cache_remover
    last_log = @cache.pop
    # puts last_log.inspect
    result = @boardo.revive_board_config(last_log)
    puts 'Warning: revive_board_config returned nil!' if result.nil?
    @boardo.board = result
  end

  def ask_baso(player)
    base_cord = nil
    loop do
      base_cord = player.ask_base
      option_cmd = option_handler(base_cord)
      return option_cmd unless option_cmd == false

      checker = MoveChecker.new(@boardo, @boardo.board[base_cord[0]][base_cord[1]])
      @options = checker.real_possible_moves(player.color)
      # puts @options.inspect, 'YOLOLOL85'
      break unless @options == []

      puts 'Invalid move. Please try again.'
    end
    base_cord
  end

  def ask_targeto(player)
    loop do
      puts 'Options:'

      @options.each { |option| puts "#{(option[1] + 96 + 1).chr}#{8 - option[0]}" }
      @boardo.display_possible_moves(@options)

      target_cord = player.ask_target
      option_cmd = option_handler(target_cord)
      # puts option_cmd.inspect
      return option_cmd unless option_cmd == false
      return target_cord if @options.include?(target_cord)

      puts 'Invalid move. Please try again.'
    end
  end

  def option_handler(keyo)
    return false unless %w[s l u q re].include?(keyo)

    case keyo
    when 's'
      save_game
      true
    when 'l'
      load_game
      true
    when 'u'
      cache_remover
      :undo
    when 'q'
      exit
    when 're'
      puts '131OPopop'
      :reselecting
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
# puts 'Direct play'
board = Board.new
board.move_piece([7, 5], [5, 5])
board.move_piece([7, 6], [5, 6])
board.move_piece([7, 1], [5, 1])
board.move_piece([7, 2], [5, 2])

board.move_piece([7, 3], [5, 3])
board.move_piece([0, 1], [7, 5])
game = Game.new(board)
game.add_player(Player.new('Alice', 'W'))
game.add_player(Player.new('Bob', 'B'))
game.play
